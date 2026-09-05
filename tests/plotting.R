library(PopGenMapper)
expect_error <- function(expr, pattern) {
  msg <- tryCatch({ force(expr); NULL }, error = conditionMessage)
  stopifnot(!is.null(msg), grepl(pattern, msg, fixed = TRUE))
}
demo <- example_ancestry()
x <- validate_ancestry(demo$ancestry, demo$coordinates)
palette <- c(Cluster2 = "#D55E00", Cluster1 = "#0072B2")
grDevices::pdf(tempfile(fileext = ".pdf"), width = 9, height = 6)
before <- graphics::par("mar")
bars <- plot_ancestry_bar(x, palette = palette,
                          order = rev(x$ancestry$sample_id))
stopifnot(identical(bars$order, rev(x$ancestry$sample_id)),
          identical(unname(bars$proportions[1, ]), c(0.2, 0.8)),
          identical(graphics::par("mar"), before))
pies <- plot_ancestry_map(x, palette = palette)
stopifnot(identical(bars$colors, pies$colors),
          length(pies$sectors) == 6L,
          abs(pies$sectors[[1]][[1]]$fraction - 0.9) < 1e-12,
          identical(graphics::par("mar"), before))
# Corrupting an already validated object must still fail.
bad <- x; bad$ancestry$Cluster1[1] <- -1
expect_error(plot_ancestry_bar(bad), "within [0, 1]")
expect_error(plot_ancestry_bar(x, order = "DEMO_01"), "every sample")
expect_error(plot_ancestry_map(x, radius = 0), "radius")
expect_error(plot_ancestry_map(x, palette = c("red", "blue")), "named")
expect_error(plot_ancestry_map(x, palette = c(Cluster1 = "nonsense", Cluster2 = "blue")), "Invalid")
bad <- x; bad$coordinates$latitude[1] <- 89
expect_error(plot_ancestry_map(bad), "regional extent")
called <- FALSE
plot_ancestry_map(x, draw_basemap = function() { called <<- TRUE })
stopifnot(called)
# K=1 and zero-size sectors are supported.
one <- demo$ancestry; one$Cluster1 <- 1; one$Cluster2 <- NULL
single <- validate_ancestry(one, demo$coordinates)
p <- plot_ancestry_map(single)
stopifnot(length(p$colors) == 1L, p$sectors[[1]][[1]]$fraction == 1)
zero <- x; zero$ancestry[1, c("Cluster1", "Cluster2")] <- c(1, 0)
p <- plot_ancestry_map(zero)
stopifnot(is.null(p$sectors[[1]][[2]]))
grDevices::dev.off()
