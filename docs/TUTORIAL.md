# From sample tables to a projected ancestry map

This example uses invented samples and locations. It does not expose research data.

## 1. Install

```r
install.packages(c("remotes", "sf", "maps"))
remotes::install_github("codewithPauline/PopGenMapper")
library(PopGenMapper)
```

## 2. Validate individuals

```r
d <- example_ancestry()
d$coordinates$longitude <- rep(c(-85, -84, -83), each = 2)
d$coordinates$latitude <- rep(c(38, 39, 40), each = 2)
x <- validate_ancestry(d$ancestry, d$coordinates)
```

For your own CSV files, read IDs as character columns so leading zeros survive.
Pass explicit cluster names when columns do not begin with Cluster.

## 3. Assign localities and inspect sample counts

```r
membership <- data.frame(
  sample_id = d$ancestry$sample_id,
  locality_id = rep(c("A", "B", "C"), each = 2)
)
sites <- aggregate_localities(x, membership)
sites$sample_counts
```

Each individual has equal weight in its locality mean. If locality members
have different coordinates, supply your chosen site_coordinates table explicitly.

## 4. Use consistent colors

```r
palette <- c(Cluster1 = "#0072B2", Cluster2 = "#D55E00")
plot_ancestry_bar(x, palette = palette)
```

## 5. Add a projected basemap

```r
states <- ancestry_basemap("state", c("ohio", "indiana", "kentucky"))
plot_ancestry_projected(sites, states, crs = 5070, palette = palette)
```

Samples are interpreted as WGS84 longitude/latitude. The supplied boundary CRS
must be declared correctly. Both layers are transformed into the selected
projected CRS. EPSG:5070 is for this contiguous-U.S. example, not a global default.

## 6. Export

```r
pdf("locality-ancestry.pdf", width = 10, height = 8)
plot_ancestry_projected(
  sites, states, crs = 5070, palette = palette,
  main = "Locality ancestry", label_cex = 0.8
)
dev.off()
```

The map displays supplied ancestry estimates. Neither pie colors nor apparent
geographic transitions independently establish species boundaries or migration.
