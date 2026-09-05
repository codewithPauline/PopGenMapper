# Entirely fictional samples and coordinates, independent of research records.
example_ancestry <- function() {
  list(
    ancestry = data.frame(
      sample_id = sprintf("DEMO_%02d", 1:6),
      Cluster1 = c(0.9, 0.7, 0.5, 0.3, 0.1, 0.2),
      Cluster2 = c(0.1, 0.3, 0.5, 0.7, 0.9, 0.8)
    ),
    coordinates = data.frame(
      sample_id = sprintf("DEMO_%02d", 1:6),
      longitude = c(-86, -85.5, -85, -84.5, -84, -83.5),
      latitude = c(38, 38.5, 39, 39.5, 40, 40.5)
    )
  )
}
