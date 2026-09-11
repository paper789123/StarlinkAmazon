library(dplyr)

panel_dir = "projects/Starlink/submission/JEEM/data/"
normal = readRDS(paste0(panel_dir, "dataset_normalyr.RDS"))
prodes = readRDS(paste0(panel_dir, "dataset_prodesyr.RDS"))

# Read the declared contract from the construction script, then require the
# committed panel to match it exactly in both membership and order.
work_dataframe_path = paste0(
  "projects/Starlink/submission/JEEM/code/work_dataframe.Rmd"
)
work_lines = readLines(work_dataframe_path, encoding = "UTF-8", warn = FALSE)
contract_start = grep("^normal_panel_columns = c\\($", work_lines)
stopifnot(length(contract_start) == 1L)
contract_end = contract_start + which(
  work_lines[(contract_start + 1L):length(work_lines)] == ")"
)[[1]]
contract_env = new.env(parent = baseenv())
eval(parse(text = work_lines[contract_start:contract_end]), envir = contract_env)
normal_required = contract_env$normal_panel_columns

stopifnot(
  nrow(normal) == 772L * 8L,
  ncol(normal) == 99L,
  identical(names(normal), normal_required),
  n_distinct(normal$codmun) == 772L,
  !anyDuplicated(normal[c("codmun", "year")]),
  identical(sort(unique(as.integer(normal$year))), 2017:2024),
  !anyNA(normal$spei12_dec),
  !anyNA(normal$pre2022_fire_scar_intensity),
  nrow(prodes) == 772L * 9L,
  n_distinct(prodes$codmun) == 772L,
  !anyDuplicated(prodes[c("codmun", "year")]),
  identical(sort(unique(as.integer(prodes$year))), 2017:2025)
)

cat(
  "normal:", nrow(normal), "x", ncol(normal),
  "municipalities=", n_distinct(normal$codmun),
  "years=", paste(range(normal$year), collapse = "-"),
  "coordinate_basis=", attr(normal, "coordinate_basis"), "\n"
)
cat(
  "prodes:", nrow(prodes), "x", ncol(prodes),
  "municipalities=", n_distinct(prodes$codmun),
  "years=", paste(range(prodes$year), collapse = "-"),
  "coordinate_basis=", attr(prodes, "coordinate_basis"), "\n"
)
cat(
  "duplicate keys: normal=", anyDuplicated(normal[c("codmun", "year")]),
  "prodes=", anyDuplicated(prodes[c("codmun", "year")]), "\n"
)

monthly_names = unique(c(
  grep("month|mes", tolower(names(normal)), value = TRUE),
  grep("month|mes", tolower(names(prodes)), value = TRUE)
))
cat("monthly-named columns:", paste(monthly_names, collapse = ", "), "\n")

prodes_required = c(
  "codmun", "year", "uf", "microreg", "reg_sample",
  "coverarea", "starlink", "areamun", "area_forest",
  "dens", "lat", "lon", "dist_coast", "dist_brasilia",
  "way_road_pav", "way_rail", "tmax", "prcp", "geosat",
  "soyield_ful_mun_high", "pasture_suit_mun",
  "spei12_jul", "pre2022_fire_scar_intensity",
  "area_mun_prodes_defo", "area_mun_prodes_defo_ccut",
  "area_mun_prodes_defo_cces", "area_mun_prodes_defo_ccwv",
  "area_mun_prodes_defo_dpdp", "area_mun_prodes_defo_mine",
  "n_mun_prodes_defo", "n_mun_prodes_defo_ccut",
  "n_mun_prodes_defo_cces", "n_mun_prodes_defo_ccwv",
  "n_mun_prodes_defo_dpdp", "n_mun_prodes_defo_mine"
)
stopifnot(
  ncol(prodes) == length(prodes_required),
  identical(names(prodes), prodes_required),
  !anyNA(prodes$spei12_jul),
  !anyNA(prodes$pre2022_fire_scar_intensity)
)

forbidden_prodes = grep(
  "deter|police|offend|pm[0-9]|mort_|igni|disp_|^sh(m|21)?_|^area_(ti|uc|sett|ndpf|sicar|over_)",
  names(prodes),
  value = TRUE
)
stopifnot(length(forbidden_prodes) == 0L)
cat("PRODES compact-column contract: PASS (35 columns)\n")
cat("calendar compact-column contract: PASS (99 columns)\n")
