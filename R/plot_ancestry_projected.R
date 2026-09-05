plot_ancestry_projected <- function(data, basemap, crs, palette = NULL,
                                    radius = 0.035,
                                    main = "Projected geographic ancestry",
                                    labels = TRUE, label_cex = 0.75,
                                    land_color = "#E5EBD8",
                                    border_color = "#879485") {
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Install sf to use projected maps.", call. = FALSE)
  }
  x <- checked_plot_data(data)
  label_method <- "auto"
  if (!is.numeric(radius) || length(radius) != 1L || !is.finite(radius) ||
      radius <= 0 || radius > 0.1) stop("radius must be in (0, 0.1].", call. = FALSE)
  if (!is.logical(labels) || length(labels) != 1L || is.na(labels)) {
    stop("labels must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.numeric(label_cex) || length(label_cex) != 1L ||
      !is.finite(label_cex) || label_cex <= 0) {
    stop("label_cex must be positive and finite.", call. = FALSE)
  }
  if (!inherits(basemap, "sf") && !inherits(basemap, "sfc")) {
    stop("basemap must be an sf or sfc object with a declared CRS.", call. = FALSE)
  }
  if (is.na(sf::st_crs(basemap)) || length(sf::st_geometry(basemap)) == 0L ||
      any(sf::st_is_empty(basemap))) {
    stop("Basemap must contain nonempty geometries and a declared CRS.", call. = FALSE)
  }
  if (!all(as.character(sf::st_geometry_type(basemap)) %in%
           c("POLYGON", "MULTIPOLYGON"))) {
    stop("Basemap must contain polygon boundaries.", call. = FALSE)
  }
  target <- sf::st_crs(crs)
  if (is.na(target) || isTRUE(sf::st_is_longlat(target))) {
    stop("crs must specify a projected coordinate reference system.", call. = FALSE)
  }
  original_lon <- x$coordinates[[x$lon]]
  if (diff(range(original_lon)) > 180) {
    stop("Dateline-crossing sample extents are not supported.", call. = FALSE)
  }
  colors <- cluster_colors(x$clusters, palette)
  points <- sf::st_as_sf(x$coordinates, coords = c(x$lon, x$lat),
                         crs = "OGC:CRS84", remove = FALSE)
  points <- sf::st_transform(points, target)
  background <- sf::st_transform(sf::st_geometry(basemap), target)
  if (any(sf::st_is_empty(points)) || any(sf::st_is_empty(background))) {
    stop("Projection produced empty geometry; choose an appropriate regional CRS.", call. = FALSE)
  }
  xy <- sf::st_coordinates(points)
  if (any(!is.finite(xy))) stop("Projection produced nonfinite coordinates.", call. = FALSE)
  longitude <- xy[, 1]; latitude <- xy[, 2]
  if (anyDuplicated(data.frame(longitude, latitude))) {
    warning("Pies overlap at shared coordinates; aggregate localities explicitly.",
            call. = FALSE)
  }
  bbox <- sf::st_bbox(background)
  if (any(!is.finite(bbox))) stop("Basemap has nonfinite projected bounds.", call. = FALSE)
  xr <- range(c(bbox[c("xmin", "xmax")], longitude))
  yr <- range(c(bbox[c("ymin", "ymax")], latitude))
  pad <- max(diff(xr), diff(yr)) * 0.07
  if (pad == 0) stop("Projected extent has zero area.", call. = FALSE)
  old <- graphics::par(mar = c(2, 2, 4, 2) + 0.1)
  on.exit(graphics::par(old), add = TRUE)
  graphics::plot(0, 0, type = "n", xlim = xr + c(-pad, pad),
                 ylim = yr + c(-pad, pad), asp = 1, axes = FALSE,
                 xlab = "", ylab = "", main = main)
  u <- graphics::par("usr")
  graphics::rect(u[1], u[3], u[2], u[4], col = "#EAF3F8", border = NA)
  graphics::plot(background, add = TRUE, col = land_color,
                 border = border_color, lwd = 0.7)
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
                 label_positions = label_positions, crs = target,
                 projected_points = points, projected_basemap = background))
}
