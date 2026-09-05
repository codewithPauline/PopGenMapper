# Run from the repository root after installing PopGenMapper.
library(PopGenMapper)
dir.create("results", showWarnings = FALSE)
demo <- example_ancestry()
x <- validate_ancestry(demo$ancestry, demo$coordinates)
palette <- c(Cluster1 = "#0072B2", Cluster2 = "#D55E00")
grDevices::svg("results/ancestry-barplot.svg", width = 10, height = 6)
plot_ancestry_bar(x, palette, main = "PopGenMapper | Synthetic ancestry")
grDevices::dev.off()
grDevices::svg("results/ancestry-map.svg", width = 9, height = 7)
plot_ancestry_map(x, palette, main = "PopGenMapper | Fictional locations")
grDevices::dev.off()

demo$coordinates$longitude <- rep(c(-85, -84, -83), each = 2)
demo$coordinates$latitude <- rep(c(38, 39, 40), each = 2)
x <- validate_ancestry(demo$ancestry, demo$coordinates)
membership <- data.frame(sample_id = demo$ancestry$sample_id,
                         locality_id = rep(c("A", "B", "C"), each = 2))
sites <- aggregate_localities(x, membership)
grDevices::svg("results/locality-map.svg", width = 9, height = 7)
plot_ancestry_map(sites, palette, main = "PopGenMapper | Fictional localities")
grDevices::dev.off()

if (requireNamespace("sf", quietly = TRUE) && requireNamespace("maps", quietly = TRUE)) {
  states <- ancestry_basemap("state", c("ohio", "indiana", "kentucky"))
  grDevices::png("results/projected-map.png", width = 1200, height = 900, res = 130)
  plot_ancestry_projected(sites, states, crs = 5070, palette = palette,
                          main = "PopGenMapper | Synthetic locality ancestry")
  graphics::mtext("Fictional samples | Boundaries: maps package | EPSG:5070",
                   side = 1, line = 0.2, cex = 0.7)
  grDevices::dev.off()
  grDevices::png("results/ancestry-barplot.png", width = 1200, height = 750, res = 130)
  plot_ancestry_bar(x, palette, main = "PopGenMapper | Synthetic individual ancestry")
  grDevices::dev.off()
}
