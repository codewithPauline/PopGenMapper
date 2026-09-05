# Revalidate so hand-edited objects cannot silently bypass input checks.
checked_plot_data <- function(x) {
  required <- c("ancestry", "coordinates", "id", "clusters", "lon", "lat")
  if (!is.list(x) || !all(required %in% names(x))) {
    stop("data must be the result of validate_ancestry().", call. = FALSE)
  }
  validate_ancestry(x$ancestry, x$coordinates, id = x$id,
                   clusters = x$clusters, lon = x$lon, lat = x$lat)
}

cluster_colors <- function(clusters, palette) {
  if (is.null(palette)) {
    palette <- grDevices::hcl.colors(length(clusters), palette = "Dark 3")
    names(palette) <- clusters
  }
  if (!is.character(palette) || is.null(names(palette)) ||
      anyNA(names(palette)) || anyDuplicated(names(palette)) ||
      !all(clusters %in% names(palette))) {
    stop("palette must be a named color vector covering every cluster.", call. = FALSE)
  }
  palette <- palette[clusters]
  if (anyNA(palette)) stop("Palette colors cannot be NA.", call. = FALSE)
  tryCatch(grDevices::col2rgb(palette),
           error = function(e) stop("Invalid palette color.", call. = FALSE))
  palette
}

plot_ancestry_bar <- function(data, palette = NULL, order = NULL,
                              main = "Individual ancestry", labels = TRUE) {
  x <- checked_plot_data(data)
  ids <- x$ancestry[[x$id]]
  if (is.null(order)) order <- ids
  if (!is.character(order) || anyNA(order) || anyDuplicated(order) ||
      length(order) != length(ids) || !setequal(order, ids)) {
    stop("order must contain every sample ID exactly once.", call. = FALSE)
  }
  if (!is.logical(labels) || length(labels) != 1L || is.na(labels)) {
    stop("labels must be TRUE or FALSE.", call. = FALSE)
  }
  colors <- cluster_colors(x$clusters, palette)
  q <- as.matrix(x$ancestry[match(order, ids), x$clusters, drop = FALSE])
  old <- graphics::par(mar = c(if (labels) 7 else 3, 4, 4, 2) + 0.1)
  on.exit(graphics::par(old), add = TRUE)
  positions <- graphics::barplot(t(q), col = colors, border = "white",
                                 space = 0.08, ylim = c(0, 1),
                                 names.arg = if (labels) order else rep("", length(ids)),
                                 las = 2, cex.names = 0.8, main = main,
                                 ylab = "Ancestry proportion")
  graphics::legend("top", inset = c(0, -0.14), legend = names(colors),
                   fill = colors, border = NA, horiz = TRUE, bty = "n",
                   xpd = NA, cex = 0.85)
  invisible(list(order = order, colors = colors, positions = positions,
                 proportions = q))
}

plot_ancestry_map <- function(data, palette = NULL, radius = 0.035,
                              main = "Geographic ancestry", labels = TRUE,
                              draw_basemap = NULL, label_method = c("auto", "above"),
                              label_cex = 0.75) {
  label_method <- match.arg(label_method)
  if (!is.numeric(label_cex) || length(label_cex) != 1L ||
      !is.finite(label_cex) || label_cex <= 0) {
    stop("label_cex must be a positive finite number.", call. = FALSE)
  }
  x <- checked_plot_data(data)
  if (!is.numeric(radius) || length(radius) != 1L || !is.finite(radius) ||
      radius <= 0 || radius > 0.1) {
    stop("radius must be a finite fraction in (0, 0.1].", call. = FALSE)
  }
  if (!is.logical(labels) || length(labels) != 1L || is.na(labels)) {
    stop("labels must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.null(draw_basemap) && !is.function(draw_basemap)) {
    stop("draw_basemap must be NULL or a function with no required arguments.", call. = FALSE)
  }
  colors <- cluster_colors(x$clusters, palette)
  longitude <- x$coordinates[[x$lon]]
  latitude <- x$coordinates[[x$lat]]
  if (any(abs(latitude) >= 85) || diff(range(longitude)) > 60 ||
      diff(range(latitude)) > 60) {
    stop("Use a regional extent within 60 degrees and below 85 degrees latitude; global and dateline maps are unsupported.",
         call. = FALSE)
  }
  if (anyDuplicated(x$coordinates[c(x$lon, x$lat)])) {
    warning("Some individuals share coordinates; their pies overlap. No locality aggregation was applied.",
            call. = FALSE)
  }
  expand <- function(z) {
    spread <- max(diff(range(z)), 0.5)
    range(z) + c(-1, 1) * spread * 0.25
  }
  old <- graphics::par(mar = c(4, 4, 4, 2) + 0.1)
  on.exit(graphics::par(old), add = TRUE)
  graphics::plot(longitude, latitude, type = "n",
                 xlim = expand(longitude), ylim = expand(latitude),
                 asp = 1 / cos(mean(latitude) * pi / 180),
                 xlab = "Longitude (degrees)", ylab = "Latitude (degrees)",
                 main = main)
  graphics::grid(col = "#E3E8EB")
  if (!is.null(draw_basemap)) draw_basemap()
  # Use physical plot dimensions so pies stay circular on rectangular devices.
  usr <- graphics::par("usr")
  pin <- graphics::par("pin")
  r_in <- radius * min(pin)
  rx <- r_in * diff(usr[1:2]) / pin[1]
  ry <- r_in * diff(usr[3:4]) / pin[2]
  q <- as.matrix(x$ancestry[x$clusters])
  sectors <- vector("list", nrow(q))
  for (i in seq_len(nrow(q))) {
    # The accepted rounding tolerance is closed at 2*pi for drawing only.
    ends <- c(0, cumsum(q[i, ]))
    ends <- ends / ends[length(ends)] * 2 * pi
    pieces <- vector("list", ncol(q))
    for (j in seq_len(ncol(q))) {
      if (q[i, j] == 0) next
      theta <- seq(ends[j], ends[j + 1], length.out =
                     max(3L, ceiling(120 * q[i, j]) + 1L))
      px <- longitude[i] + c(0, cos(theta), 0) * rx
      py <- latitude[i] + c(0, sin(theta), 0) * ry
      graphics::polygon(px, py, col = colors[j], border = "white", lwd = 0.5)
      pieces[[j]] <- list(x = px, y = py, fraction = q[i, j])
    }
    sectors[[i]] <- pieces
  }
  label_positions <- NULL
  if (labels) {
    ids <- x$ancestry[[x$id]]
    if (label_method == "above") {
      label_positions <- cbind(longitude, latitude + ry * 1.35)
      graphics::text(label_positions, labels = ids, pos = 3, cex = label_cex)
    } else {
      dx <- diff(usr[1:2]); dy <- diff(usr[3:4])
      layout <- place_map_labels(
        (longitude - usr[1]) / dx, (latitude - usr[3]) / dy,
        graphics::strwidth(ids, cex = label_cex) / dx + 0.012,
        graphics::strheight(ids, cex = label_cex) / dy + 0.012,
        rx / dx, ry / dy)
      label_positions <- cbind(usr[1] + layout$positions[, 1] * dx,
                                usr[3] + layout$positions[, 2] * dy)
      graphics::segments(longitude, latitude, label_positions[, 1],
                          label_positions[, 2], col = "#707A80", lwd = 0.6)
      graphics::text(label_positions, labels = ids, cex = label_cex)
      if (any(layout$crowded)) {
        warning("Some labels could not be separated; use a larger device, smaller label_cex, or labels = FALSE.",
                call. = FALSE)
      }
    }
    rownames(label_positions) <- ids
  }
  graphics::legend("top", inset = c(0, -0.14), legend = names(colors),
                   fill = colors, border = NA, horiz = TRUE, bty = "n",
                   xpd = NA, cex = 0.85)
  invisible(list(ids = x$ancestry[[x$id]], colors = colors,
                 sectors = sectors, radius = c(longitude = rx, latitude = ry),
                 label_positions = label_positions))
}
