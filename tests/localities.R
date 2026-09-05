library(PopGenMapper)
err <- function(expr, pattern) {
  msg <- tryCatch({ force(expr); NULL }, error = conditionMessage)
  stopifnot(!is.null(msg), grepl(pattern, msg, fixed = TRUE))
}
d <- example_ancestry()
d$coordinates$longitude <- rep(c(-85, -84, -83), each = 2)
d$coordinates$latitude <- rep(c(38, 39, 40), each = 2)
x <- validate_ancestry(d$ancestry, d$coordinates)
m <- data.frame(sample_id = d$ancestry$sample_id,
                locality_id = rep(c("A", "B", "C"), each = 2))
s <- aggregate_localities(x, m[6:1, ])
stopifnot(isTRUE(all.equal(s$ancestry$Cluster1, c(.8, .4, .15))),
          identical(s$sample_counts$n_samples, rep(2L, 3)),
          identical(s$coordinates$locality_id, c("A", "B", "C")))
err(aggregate_localities(x, m[-1, ]), "every sample")
bad <- m; bad$sample_id[1] <- bad$sample_id[2]
err(aggregate_localities(x, bad), "every sample")
bad <- m; bad$locality_id[1] <- NA_character_
err(aggregate_localities(x, bad), "Locality IDs")
x2 <- x; x2$coordinates$latitude[1] <- 38.1
err(aggregate_localities(x2, m), "different coordinates")
centers <- s$coordinates[3:1, ]
s2 <- aggregate_localities(x2, m, site_coordinates = centers)
stopifnot(identical(s2$coordinates, s$coordinates))
# K=1 preserves dimensions and locality means.
one <- d$ancestry; one$Cluster1 <- 1; one$Cluster2 <- NULL
s1 <- aggregate_localities(validate_ancestry(one, d$coordinates), m)
stopifnot(identical(s1$ancestry$Cluster1, rep(1, 3)))
# All individuals in one locality and an explicit location.
all_one <- m; all_one$locality_id <- "A"
single <- aggregate_localities(x, all_one, site_coordinates = centers[centers$locality_id == "A", ])
stopifnot(nrow(single$ancestry) == 1, single$sample_counts$n_samples == 6,
          isTRUE(all.equal(single$ancestry$Cluster1, mean(d$ancestry$Cluster1))))
grDevices::pdf(tempfile(fileext = ".pdf"), width = 9, height = 7)
p <- plot_ancestry_map(s)
stopifnot(nrow(p$label_positions) == 3,
          identical(rownames(p$label_positions), c("A", "B", "C")))
p2 <- plot_ancestry_map(s)
stopifnot(identical(p$label_positions, p2$label_positions))
stopifnot(is.null(plot_ancestry_map(s, labels = FALSE)$label_positions))
err(plot_ancestry_map(s, label_cex = NA_real_), "label_cex")
# Dense fixture: the layout is deterministic and boxes are separated.
layout <- getFromNamespace("place_map_labels", "PopGenMapper")
a <- layout(c(.45, .5, .55), c(.5, .5, .5), rep(.1, 3), rep(.035, 3), .025, .025)
stopifnot(!any(a$crowded), identical(a, layout(c(.45, .5, .55), c(.5, .5, .5),
                                             rep(.1, 3), rep(.035, 3), .025, .025)))
for (i in 1:2) for (j in (i + 1):3) {
  b <- a$boxes
  stopifnot(b[i, 2] <= b[j, 1] || b[j, 2] <= b[i, 1] ||
            b[i, 4] <= b[j, 3] || b[j, 4] <= b[i, 3])
}
grDevices::dev.off()
