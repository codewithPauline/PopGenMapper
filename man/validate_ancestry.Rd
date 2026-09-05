\name{validate_ancestry}
\alias{validate_ancestry}
\title{Validate and Align Ancestry and Coordinate Tables}
\usage{
validate_ancestry(
  ancestry, coordinates, id = "sample_id",
  clusters = grep("^Cluster", names(ancestry), value = TRUE),
  lon = "longitude", lat = "latitude", tolerance = 1e-6
)
}
\arguments{
\item{ancestry}{Nonempty data frame with unique character sample IDs and numeric ancestry columns.}
\item{coordinates}{Nonempty data frame with the same sample IDs and numeric coordinates in decimal degrees.}
\item{id}{Shared sample ID column name.}
\item{clusters}{Character vector of ancestry column names. Defaults to columns beginning with Cluster. At least one is required.}
\item{lon}{Longitude column name.}
\item{lat}{Latitude column name.}
\item{tolerance}{Finite nonnegative row-sum tolerance smaller than one.}
}
\description{Checks IDs, proportions, and coordinate bounds. Reorders coordinates
to match the ancestry table using sample identifiers.}
\details{No samples are dropped, and proportions are not normalized. IDs must
be unique character strings without surrounding whitespace. Proportions must
be finite, within zero and one, and sum to one within the chosen tolerance.
The function checks geographic bounds but does not infer or transform a CRS.
Repeated coordinate pairs are allowed; locality aggregation is not performed.
}
\value{A list containing the original ancestry table, aligned coordinate table,
and the selected column names in \code{clusters}, \code{id}, \code{lon}, and
\code{lat}. Invalid input raises an error.}
\examples{
demo <- example_ancestry()
checked <- validate_ancestry(demo$ancestry, demo$coordinates)
checked$coordinates
}
