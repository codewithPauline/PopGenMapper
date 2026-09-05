\name{aggregate_localities}
\alias{aggregate_localities}
\title{Summarize Individual Ancestry by Explicit Locality}
\usage{
aggregate_localities(data, membership, locality = "locality_id",
                     site_coordinates = NULL)
}
\arguments{
\item{data}{Result of \code{validate_ancestry()}.}
\item{membership}{Data frame containing the input sample ID column and a
locality column. Every input sample must occur exactly once.}
\item{locality}{Name of the locality column, distinct from the input ID,
cluster, longitude, and latitude column names.}
\item{site_coordinates}{Optional data frame with one row per locality,
containing the locality column and input longitude/latitude columns.
Required if samples assigned to one locality have different coordinates.}
}
\description{Calculates the arithmetic mean of ancestry proportions within
each explicitly assigned locality, with equal weight per individual.}
\details{Localities are ordered by first appearance in the ancestry table.
No locality is inferred from sample-name substrings or spatial proximity.
With no site coordinates supplied, every sample in a locality must share the
same coordinate pair. Different localities may share a coordinate pair.
Coordinates are never silently averaged. This function should be applied
to individual-level inputs; repeated aggregation would reweight the data.}
\value{A validated list accepted by the plotting functions. Its ancestry
and coordinate rows represent localities. Additional \code{sample_counts}
and \code{membership} tables record group sizes and assignments.}
\examples{
demo <- example_ancestry()
demo$coordinates$longitude <- rep(c(-85, -84, -83), each = 2)
demo$coordinates$latitude <- rep(c(38, 39, 40), each = 2)
x <- validate_ancestry(demo$ancestry, demo$coordinates)
groups <- data.frame(sample_id = demo$ancestry$sample_id,
                     locality_id = rep(c("A", "B", "C"), each = 2))
sites <- aggregate_localities(x, groups)
sites$sample_counts
}
