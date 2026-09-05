ancestry_basemap <- function(database = c("state", "world"), regions = ".") {
  if (!requireNamespace("sf", quietly = TRUE) ||
      !requireNamespace("maps", quietly = TRUE)) {
    stop("Install sf and maps to load a basemap.", call. = FALSE)
  }
  database <- match.arg(database)
  if (!is.character(regions) || !length(regions) || anyNA(regions)) {
    stop("regions must be a character vector of map region patterns.", call. = FALSE)
  }
  m <- maps::map(database, regions = regions, fill = TRUE, plot = FALSE)
  out <- sf::st_as_sf(m)
  # maps databases store longitude/latitude in degrees.
  sf::st_crs(out) <- "OGC:CRS84"
  out
}
