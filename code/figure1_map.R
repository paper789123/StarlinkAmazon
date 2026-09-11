# Figure 1: Starlink adoption, mobile coverage, and DETER degradation.
#
# This helper reads compact submission-local RDS inputs and constructs the map
# displayed in the submission HTML.

stopifnot(
  exists("DATA_DIR"),
  exists("mun_legal_amazon_geometry")
)

figure1_mobile = readRDS(file.path(
  DATA_DIR, "processed", "figure1_mobile_coverage.RDS"
))
figure1_deter = readRDS(file.path(
  DATA_DIR, "processed", "figure1_deter_2022_2024.RDS"
))
figure1_starlink = readRDS(file.path(
  DATA_DIR, "processed", "starlink_normalyr.RDS"
)) %>%
  dplyr::ungroup() %>%
  dplyr::filter(year %in% c(2022L, 2024L))

# This is the panel-matched 772-unit geography. In particular, it dissolves
# Mojui dos Campos into Santarem before joining the municipal panel values.
figure1_mun = readRDS(mun_legal_amazon_geometry) %>%
  sf::st_make_valid() %>%
  sf::st_transform(4674) %>%
  dplyr::mutate(codmun = as.numeric(codmun)) %>%
  dplyr::select(codmun)
stopifnot(
  nrow(figure1_mun) == 772L,
  dplyr::n_distinct(figure1_mun$codmun) == 772L
)

figure1_mun = dplyr::bind_rows(
  figure1_mun %>% dplyr::mutate(year = 2022L),
  figure1_mun %>% dplyr::mutate(year = 2024L)
) %>%
  dplyr::left_join(figure1_starlink, by = c("codmun", "year")) %>%
  dplyr::mutate(starlink = tidyr::replace_na(starlink, 0))

# The legend uses quintiles of 2024 municipal adoption, as stated in the paper.
figure1_breaks = stats::quantile(
  figure1_mun$starlink[figure1_mun$year == 2024L],
  probs = seq(0, 1, 0.2),
  na.rm = TRUE,
  names = FALSE
)
stopifnot(all(diff(figure1_breaks) > 0))
figure1_labels = c(
  sprintf("[%.1f - %.1f]", figure1_breaks[1], figure1_breaks[2]),
  sprintf("(%.1f - %.1f]", figure1_breaks[2], figure1_breaks[3]),
  sprintf("(%.1f - %.1f]", figure1_breaks[3], figure1_breaks[4]),
  sprintf("(%.1f - %.1f]", figure1_breaks[4], figure1_breaks[5]),
  sprintf("(%.1f - %.1f]", figure1_breaks[5], figure1_breaks[6])
)
figure1_palette = stats::setNames(
  c("#FFFFFF", "#D8D8D8", "#AEAEAE", "#5F5F5F", "#2B2B2B"),
  figure1_labels
)
figure1_mun = figure1_mun %>%
  dplyr::mutate(
    starlink_bin = cut(
      starlink,
      breaks = figure1_breaks,
      labels = figure1_labels,
      include.lowest = TRUE,
      right = TRUE
    ),
    starlink_bin = factor(starlink_bin, levels = figure1_labels)
  )

make_figure1_panel = function(year_value, panel_label, degr_linewidth) {
  ggplot(figure1_mun %>% dplyr::filter(year == year_value)) +
    geom_sf(
      aes(fill = starlink_bin),
      color = "grey20",
      linewidth = 0.05,
      alpha = 0.8
    ) +
    scale_fill_manual(
      name = "Starlink per 1,000",
      values = figure1_palette,
      limits = figure1_labels,
      drop = FALSE,
      na.value = "#E0E0E0",
      guide = guide_legend(order = 1)
    ) +
    ggnewscale::new_scale_fill() +
    geom_sf(
      data = figure1_mobile,
      aes(fill = "Mobile"),
      alpha = 0.9,
      color = NA
    ) +
    scale_fill_manual(
      name = NULL,
      values = c("Mobile" = "blue"),
      breaks = "Mobile",
      guide = guide_legend(
        order = 2,
        override.aes = list(alpha = 0.9, color = NA)
      )
    ) +
    ggnewscale::new_scale_fill() +
    geom_sf(
      data = figure1_deter %>% dplyr::filter(year == year_value),
      aes(fill = "Degradation"),
      alpha = 0.5,
      color = "red",
      linewidth = degr_linewidth
    ) +
    scale_fill_manual(
      name = NULL,
      values = c("Degradation" = "red"),
      breaks = "Degradation",
      guide = guide_legend(
        order = 3,
        override.aes = list(alpha = 0.9, color = NA)
      )
    ) +
    coord_sf(datum = NA) +
    annotate(
      "text", x = -73, y = 5, label = panel_label,
      size = 3.5, hjust = 0
    ) +
    theme_minimal() +
    theme(
      text = element_text(size = 11),
      legend.text = element_text(size = 10.5),
      legend.title = element_text(size = 11),
      legend.key.height = grid::unit(5.5, "mm"),
      legend.key.width = grid::unit(7, "mm"),
      legend.box.spacing = grid::unit(1, "mm"),
      legend.margin = margin(0, 0, 0, 0),
      plot.margin = margin(0, 0, 0, 0)
    )
}

figure1_panel_2022 = make_figure1_panel(2022L, "(a) 2022", 0.10)
figure1_panel_2024 = make_figure1_panel(2024L, "(b) 2024", 0.05)
figure1_legend = ggpubr::get_legend(
  figure1_panel_2024 + theme(legend.position = "right")
)
figure1_panels = ggpubr::ggarrange(
  figure1_panel_2022 + theme(legend.position = "none"),
  figure1_panel_2024 + theme(legend.position = "none"),
  ncol = 1,
  nrow = 2
)
figure1_map = ggpubr::ggarrange(
  figure1_panels,
  figure1_legend,
  ncol = 2,
  widths = c(1, 0.23)
)
