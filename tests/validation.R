library(PopGenMapper)

expect_error <- function(expr, pattern) {
  message <- tryCatch({ force(expr); NULL },
                      error = function(e) conditionMessage(e))
  stopifnot(!is.null(message), grepl(pattern, message, fixed = TRUE))
}
demo <- example_ancestry()
q <- demo$ancestry
xy <- demo$coordinates
result <- validate_ancestry(q, xy[6:1, ])
stopifnot(identical(result$coordinates, xy),
          identical(result$ancestry, q),
          identical(result$clusters, c("Cluster1", "Cluster2")))

bad <- q; bad$sample_id[2] <- bad$sample_id[1]
expect_error(validate_ancestry(bad, xy), "unique")
bad <- xy; bad$sample_id[1] <- "UNKNOWN"
expect_error(validate_ancestry(q, bad), "do not match")
bad <- q; bad$Cluster1[1] <- NA_real_
expect_error(validate_ancestry(bad, xy), "finite")
bad <- q; bad$Cluster1[1] <- -0.1
expect_error(validate_ancestry(bad, xy), "within [0, 1]")
bad <- q; bad$Cluster1[1] <- 0.5
expect_error(validate_ancestry(bad, xy), "sum to one")
bad <- xy; bad$longitude[1] <- 181
expect_error(validate_ancestry(q, bad), "bounds")
bad <- q; bad$sample_id[1] <- " DEMO_01"
expect_error(validate_ancestry(bad, xy), "whitespace")
bad <- q; bad$Cluster1 <- as.character(bad$Cluster1)
expect_error(validate_ancestry(bad, xy), "numeric")
expect_error(validate_ancestry(q, xy, clusters = character()), "clusters")
expect_error(validate_ancestry(q, xy, tolerance = NA_real_), "tolerance")
expect_error(validate_ancestry(q[FALSE, ], xy), "nonempty")
bad <- q; bad$Cluster1 <- 1; bad$Cluster2 <- NULL
stopifnot(length(validate_ancestry(bad, xy)$clusters) == 1L)
bad <- q; names(bad)[2:3] <- c("A", "B")
stopifnot(identical(validate_ancestry(bad, xy, clusters = c("A", "B"))$clusters,
                    c("A", "B")))
bad <- xy; bad$latitude[1] <- Inf
expect_error(validate_ancestry(q, bad), "finite")
bad <- q; bad$sample_id <- seq_len(nrow(bad))
expect_error(validate_ancestry(bad, xy), "character")
