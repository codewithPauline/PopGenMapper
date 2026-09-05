library(PopGenMapper)
if (requireNamespace("sf", quietly = TRUE)) {
  d <- example_ancestry()
  x <- validate_ancestry(d$ancestry, d$coordinates)
  poly <- sf::st_polygon(list(matrix(c(-88,36, -81,36, -81,42, -88,42, -88,36),
                                     ncol = 2, byrow = TRUE)))
  b <- sf::st_sfc(poly, crs = 4326)
  grDevices::pdf(tempfile(fileext = ".pdf"), width = 9, height = 7)
  p <- plot_ancestry_projected(x, b, 5070)
  expected <- sf::st_transform(sf::st_as_sf(d$coordinates,
                               coords = c("longitude", "latitude"), crs = 4326), 5070)
  stopifnot(isTRUE(all.equal(sf::st_coordinates(p$projected_points),
                             sf::st_coordinates(expected))),
            p$crs == sf::st_crs(5070),
            identical(p$ids, d$ancestry$sample_id))
  err <- function(expr) stopifnot(inherits(tryCatch({force(expr); NULL}, error = identity), "error"))
  err(plot_ancestry_projected(x, b, 4326))
  err(plot_ancestry_projected(x, sf::st_set_crs(b, NA), 5070))
  err(plot_ancestry_projected(x, b, 5070, radius = 0))
  p2 <- plot_ancestry_projected(x, sf::st_transform(b, 3857), 5070)
  stopifnot(isTRUE(all.equal(sf::st_coordinates(p2$projected_points),
                             sf::st_coordinates(p$projected_points))))
  grDevices::dev.off()
}
