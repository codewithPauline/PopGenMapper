# Greedy deterministic placement in normalized plot coordinates.
# Candidate boxes avoid all pie bounding boxes and earlier labels when possible.
place_map_labels <- function(x, y, widths, heights, rx, ry) {
  n <- length(x)
  boxes <- matrix(numeric(), ncol = 4)
  pie_boxes <- cbind(x - rx, x + rx, y - ry, y + ry)
  overlap <- function(a, b) {
    pmax(0, pmin(a[2], b[, 2]) - pmax(a[1], b[, 1])) *
      pmax(0, pmin(a[4], b[, 4]) - pmax(a[3], b[, 3]))
  }
  positions <- matrix(NA_real_, nrow = n, ncol = 2)
  crowded <- logical(n)
  for (i in seq_len(n)) {
    candidates <- list()
    for (ring in c(1, 1.6, 2.4, 3.5)) {
      for (angle in seq(pi / 2, pi / 2 + 2 * pi, length.out = 17)[-17]) {
        cx <- x[i] + cos(angle) * (rx + widths[i] / 2 + 0.012) * ring
        cy <- y[i] + sin(angle) * (ry + heights[i] / 2 + 0.012) * ring
        cx <- max(widths[i] / 2, min(1 - widths[i] / 2, cx))
        cy <- max(heights[i] / 2, min(1 - heights[i] / 2, cy))
        box <- c(cx - widths[i] / 2, cx + widths[i] / 2,
                 cy - heights[i] / 2, cy + heights[i] / 2)
        collisions <- sum(overlap(box, pie_boxes)) + sum(overlap(box, boxes))
        candidates[[length(candidates) + 1L]] <- list(
          xy = c(cx, cy), box = box, score = collisions)
      }
    }
    scores <- vapply(candidates, function(z) z$score, numeric(1))
    best <- candidates[[which.min(scores)]]
    positions[i, ] <- best$xy
    crowded[i] <- best$score > 1e-12 || widths[i] > 1 || heights[i] > 1
    boxes <- rbind(boxes, best$box)
  }
  list(positions = positions, boxes = boxes, crowded = crowded)
}
