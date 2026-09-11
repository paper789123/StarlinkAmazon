options(warn = 1)

library(dplyr)
library(tibble)
library(sf)
library(terra)
library(exactextractr)
library(future)
library(future.apply)

args = commandArgs(trailingOnly = TRUE)
if (length(args) != 1L || !args[[1]] %in% c("6", "12")) {
  stop("Usage: Rscript spei_copernicus_era5.R {6|12}")
}
scale_months = as.integer(args[[1]])

script_arg = grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (!length(script_arg)) stop("Run this file with Rscript.")
code_dir = dirname(normalizePath(
  sub("^--file=", "", script_arg[[1]]),
  winslash = "/",
  mustWork = TRUE
))
data_dir = normalizePath(
  Sys.getenv(
    "STARLINK_SPEI_DATA_DIR",
    unset = file.path(code_dir, "../data")
  ),
  winslash = "/",
  mustWork = TRUE
)
processed_dir = normalizePath(
  Sys.getenv(
    "STARLINK_SPEI_OUTPUT_DIR",
    unset = file.path(data_dir, "processed")
  ),
  winslash = "/",
  mustWork = TRUE
)
default_zip_candidates = file.path(
  data_dir,
  "raw/Copernicus",
  c(
    "SPEI-12_Amazon_2017_2025.zip",
    "SPEI-12_Amazon_2016_2025.zip", # earlier compact archive
    "SPEI-6-12_Amazon_1940_2025.zip" # legacy shared archive
  )
)
default_zip = default_zip_candidates[file.exists(default_zip_candidates)][1]
zip_path = Sys.getenv("STARLINK_COPERNICUS_SPEI_ZIP", unset = default_zip)
stopifnot(file.exists(zip_path), dir.exists(processed_dir))

# The archive contains one NetCDF per index-month. GDAL can address these files
# through /vsizip/, but its NetCDF driver emits NCpathcvt errors when it requests
# auxiliary metadata from a compressed member. Extract only the 17 endpoint
# files needed for this analysis to a disposable directory instead of unpacking
# the full historical archive.
archive = unzip(zip_path, list = TRUE) |>
  as_tibble() |>
  transmute(member = Name) |>
  filter(grepl(paste0("^SPEI", scale_months, "_"), member)) |>
  mutate(
    year_month = sub(
      paste0("^SPEI", scale_months,
             "_genlogistic_global_era5_moda_ref1991to2020_"),
      "",
      member
    ),
    year_month = substr(year_month, 1L, 6L),
    year = as.integer(substr(year_month, 1L, 4L)),
    month = as.integer(substr(year_month, 5L, 6L))
  ) |>
  arrange(year, month)

stopifnot(
  nrow(archive) >= 108L,
  !anyNA(archive[c("year", "month")]),
  !anyDuplicated(archive[c("year", "month")]),
  min(archive$year) <= 2017L,
  max(archive$year) == 2025L,
  max(archive$month[archive$year == 2025L]) == 12L
)

calendar_tasks = archive |>
  filter(year >= 2017L, year <= 2024L, month == 12L) |>
  mutate(anchor = "dec", panel_year = year)
prodes_tasks = archive |>
  filter(year >= 2017L, year <= 2025L, month == 7L) |>
  mutate(anchor = "jul", panel_year = year)
tasks = bind_rows(calendar_tasks, prodes_tasks) |>
  arrange(anchor, panel_year)
stopifnot(
  nrow(calendar_tasks) == 8L,
  nrow(prodes_tasks) == 9L,
  nrow(tasks) == 17L
)

selected_dir = tempfile(paste0("copernicus_spei", scale_months, "_"))
dir.create(selected_dir, recursive = TRUE)
on.exit(unlink(selected_dir, recursive = TRUE, force = TRUE), add = TRUE)
unzip(zip_path, files = tasks$member, exdir = selected_dir)
tasks$path = file.path(selected_dir, tasks$member)
stopifnot(all(file.exists(tasks$path)))

mun_path = Sys.getenv(
  "STARLINK_SPEI_MUN_ZONE_RDS",
  unset = file.path(processed_dir, "mun_zone.RDS")
)
stopifnot(file.exists(mun_path))
mun = readRDS(mun_path) |>
  select(codmun) |>
  arrange(codmun)
stopifnot(nrow(mun) == 772L, n_distinct(mun$codmun) == 772L)
target_crs = st_crs(mun)$wkt
bbox_wgs84 = st_bbox(st_transform(mun, 4326)) + c(-0.5, -0.5, 0.5, 0.5)

summarize_valid = function(values, coverage_area) {
  valid = is.finite(values) & is.finite(coverage_area) & coverage_area > 0
  if (!any(valid)) return(NA_real_)
  sum(values[valid] * coverage_area[valid]) / sum(coverage_area[valid])
}

extract_one = function(index) {
  library(dplyr)
  library(tibble)
  library(sf)
  library(terra)
  library(exactextractr)

  raster = rast(tasks$path[[index]]) |>
    crop(ext(bbox_wgs84))
  # The NetCDF metadata defines -9999 as the only fill value. Do not truncate
  # finite extreme values: they are part of the provider's fitted index and are
  # reported in the cross-source diagnostics.
  raster[raster <= -9990] = NA
  raster = project(raster, target_crs)

  municipal_spei = exact_extract(
    raster,
    mun,
    summarize_valid,
    coverage_area = TRUE,
    progress = FALSE
  )

  out = tibble(
    codmun = as.numeric(mun$codmun),
    year = tasks$panel_year[[index]],
    anchor = tasks$anchor[[index]],
    spei = as.numeric(municipal_spei)
  )
  stopifnot(
    nrow(out) == 772L,
    all(is.finite(out$spei)),
    all(out$spei > -100 & out$spei < 100)
  )
  out
}

max_workers = as.integer(Sys.getenv("SPEI_COPERNICUS_MAX_WORKERS", unset = "3"))
stopifnot(is.finite(max_workers), max_workers >= 1L)
options(future.globals.maxSize = 2 * 1024^3)
plan(multisession, workers = min(max_workers, nrow(tasks)))
on.exit(plan(sequential), add = TRUE)
started = Sys.time()
anchors = future_lapply(
  seq_len(nrow(tasks)),
  extract_one,
  future.seed = TRUE,
  future.packages = c("dplyr", "tibble", "sf", "terra", "exactextractr")
) |>
  bind_rows()
plan(sequential)

value_dec = paste0("spei", scale_months, "_dec")
value_jul = paste0("spei", scale_months, "_jul")
normalyr = anchors |>
  filter(anchor == "dec") |>
  transmute(codmun, year, !!value_dec := spei) |>
  arrange(codmun, year)
prodesyr = anchors |>
  filter(anchor == "jul") |>
  transmute(codmun, year, !!value_jul := spei) |>
  arrange(codmun, year)

stopifnot(
  nrow(normalyr) == 772L * 8L,
  nrow(prodesyr) == 772L * 9L,
  !anyDuplicated(normalyr[c("codmun", "year")]),
  !anyDuplicated(prodesyr[c("codmun", "year")]),
  all(is.finite(normalyr[[value_dec]])),
  all(is.finite(prodesyr[[value_jul]]))
)

for (object_name in c("normalyr", "prodesyr")) {
  object = get(object_name)
  attr(object, "source") = "Copernicus ERA5-Drought"
  attr(object, "dataset_doi") = "10.24381/9bea5e16"
  attr(object, "data_basis") = "ERA5 reanalysis"
  attr(object, "pet_method") = "Penman-Monteith"
  attr(object, "scale_months") = scale_months
  attr(object, "reference_period") = "1991-2020"
  attr(object, "anchor_month") = if (object_name == "normalyr") 12L else 7L
  assign(object_name, object)
}

normal_path = file.path(
  processed_dir,
  paste0("spei", scale_months, "_copernicus_era5_normalyr.RDS")
)
prodes_path = file.path(
  processed_dir,
  paste0("spei", scale_months, "_copernicus_era5_prodesyr.RDS")
)
saveRDS(normalyr, normal_path)
saveRDS(prodesyr, prodes_path)

cat("SPEI_COPERNICUS_EXTRACTION_OK\n")
cat("scale", scale_months, "\n")
cat("archive_members", nrow(archive), "anchor_files", nrow(tasks), "\n")
cat("calendar_rows", nrow(normalyr), "prodes_rows", nrow(prodesyr), "\n")
cat("calendar_range", paste(range(normalyr[[value_dec]]), collapse = ","), "\n")
cat("prodes_range", paste(range(prodesyr[[value_jul]]), collapse = ","), "\n")
cat("calendar_below_minus10", sum(normalyr[[value_dec]] < -10), "\n")
cat("prodes_below_minus10", sum(prodesyr[[value_jul]] < -10), "\n")
cat("elapsed_minutes", as.numeric(difftime(Sys.time(), started, units = "mins")), "\n")
cat("normal_path", normal_path, "\n")
cat("prodes_path", prodes_path, "\n")
