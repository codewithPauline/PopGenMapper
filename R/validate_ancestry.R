# Validate inputs without dropping, renaming, or normalizing samples.
validate_ancestry <- function(ancestry, coordinates, id = "sample_id",
                              clusters = grep("^Cluster", names(ancestry),
                                              value = TRUE),
                              lon = "longitude", lat = "latitude",
                              tolerance = 1e-6) {
  fail <- function(message) stop(message, call. = FALSE)
  column_name <- function(x) {
    is.character(x) && length(x) == 1L && !is.na(x) && nzchar(x)
  }
  if (!all(vapply(list(id, lon, lat), column_name, logical(1)))) {
    fail("id, lon, and lat must each name one column.")
  }
  if (length(unique(c(id, lon, lat))) != 3L) {
    fail("id, lon, and lat must name different columns.")
  }
  for (x in list(ancestry, coordinates)) {
    if (!is.data.frame(x) || nrow(x) == 0L) {
      fail("Both inputs must be nonempty data frames.")
    }
    if (anyNA(names(x)) || any(!nzchar(names(x))) ||
        anyDuplicated(names(x))) {
      fail("Column names must be present and unique.")
    }
  }
  if (!is.character(clusters) || length(clusters) < 1L ||
      anyNA(clusters) || anyDuplicated(clusters) ||
      any(!nzchar(clusters)) || id %in% clusters) {
    fail("clusters must name unique ancestry columns, excluding the ID.")
  }
  if (!all(c(id, clusters) %in% names(ancestry)) ||
      !all(c(id, lon, lat) %in% names(coordinates))) {
    fail("Required ID, ancestry, or coordinate columns are missing.")
  }
  if (!is.numeric(tolerance) || length(tolerance) != 1L ||
      !is.finite(tolerance) || tolerance < 0 || tolerance >= 1) {
    fail("tolerance must be a finite number in [0, 1).")
  }
  for (ids in list(ancestry[[id]], coordinates[[id]])) {
    if (!is.character(ids) || anyNA(ids) || any(!nzchar(trimws(ids))) ||
        anyDuplicated(ids)) {
      fail("Sample IDs must be unique, nonempty character strings without NA.")
    }
    if (any(ids != trimws(ids))) {
      fail("Sample IDs contain leading or trailing whitespace.")
    }
  }
  if (!setequal(ancestry[[id]], coordinates[[id]])) {
    fail("Sample IDs do not match between ancestry and coordinates.")
  }
  if (!all(vapply(ancestry[clusters], is.numeric, logical(1)))) {
    fail("Ancestry columns must be numeric.")
  }
  q <- as.matrix(ancestry[clusters])
  if (any(!is.finite(q)) || any(q < 0 | q > 1)) {
    fail("Ancestry proportions must be finite and within [0, 1].")
  }
  if (any(abs(rowSums(q) - 1) > tolerance)) {
    fail("Ancestry proportions must sum to one within tolerance for each sample.")
  }
  if (!is.numeric(coordinates[[lon]]) || !is.numeric(coordinates[[lat]])) {
    fail("Longitude and latitude must be numeric.")
  }
  if (any(!is.finite(coordinates[[lon]])) ||
      any(!is.finite(coordinates[[lat]])) ||
      any(abs(coordinates[[lon]]) > 180) ||
      any(abs(coordinates[[lat]]) > 90)) {
    fail("Coordinates must be finite decimal degrees within longitude/latitude bounds.")
  }
  aligned <- coordinates[match(ancestry[[id]], coordinates[[id]]), ,
                         drop = FALSE]
  rownames(aligned) <- NULL
  list(ancestry = ancestry, coordinates = aligned, clusters = clusters,
       id = id, lon = lon, lat = lat)
}
