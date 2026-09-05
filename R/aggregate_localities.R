aggregate_localities <- function(data, membership, locality = "locality_id",
                                 site_coordinates = NULL) {
  x <- checked_plot_data(data)
  fail <- function(msg) stop(msg, call. = FALSE)
  if (!is.character(locality) || length(locality) != 1L ||
      is.na(locality) || !nzchar(locality) ||
      locality %in% c(x$id, x$clusters, x$lon, x$lat)) {
    fail("locality must be a distinct, nonempty column name.")
  }
  if (!is.data.frame(membership) || anyDuplicated(names(membership)) ||
      !all(c(x$id, locality) %in% names(membership))) {
    fail("membership must contain the sample ID and locality columns.")
  }
  ids <- membership[[x$id]]
  sites <- membership[[locality]]
  valid_ids <- function(z) {
    is.character(z) && !anyNA(z) && all(nzchar(z)) &&
      all(trimws(z) == z)
  }
  if (!valid_ids(ids) || anyDuplicated(ids) ||
      !setequal(ids, x$ancestry[[x$id]])) {
    fail("membership must match every sample ID exactly once.")
  }
  if (!valid_ids(sites)) fail("Locality IDs must be nonempty character strings.")
  sites <- sites[match(x$ancestry[[x$id]], ids)]
  levels <- unique(sites)
  q <- as.matrix(x$ancestry[x$clusters])
  means <- t(vapply(levels, function(s) colMeans(q[sites == s, , drop = FALSE]),
                     numeric(ncol(q))))
  # vapply simplifies K=1 differently; construct an explicit matrix.
  means <- matrix(means, nrow = length(levels), ncol = ncol(q))
  ancestry <- data.frame(levels, means, check.names = FALSE)
  names(ancestry) <- c(locality, x$clusters)
  if (is.null(site_coordinates)) {
    positions <- lapply(levels, function(s) {
      z <- unique(x$coordinates[sites == s, c(x$lon, x$lat), drop = FALSE])
      if (nrow(z) != 1L) {
        fail("Samples within a locality have different coordinates; supply site_coordinates explicitly.")
      }
      z
    })
    coords <- do.call(rbind, positions)
    coords[[locality]] <- levels
  } else {
    coords <- site_coordinates
  }
  out <- validate_ancestry(ancestry, coords, id = locality,
                          clusters = x$clusters, lon = x$lon, lat = x$lat)
  out$sample_counts <- data.frame(locality_id = levels,
                                  n_samples = as.integer(table(factor(sites, levels))))
  names(out$sample_counts)[1] <- locality
  out$membership <- data.frame(sample = x$ancestry[[x$id]], locality = sites)
  names(out$membership) <- c(x$id, locality)
  out
}
