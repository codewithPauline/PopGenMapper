\name{ancestry_basemap}
\alias{ancestry_basemap}
\title{Load Map Boundaries as Simple Features}
\usage{ancestry_basemap(database = c("state", "world"), regions = ".")}
\arguments{
\item{database}{The maps package state (United States) or world database.}
\item{regions}{Region-name regular expressions passed to maps::map.}
}
\description{Loads polygon boundaries from the optional maps package and converts
them to an sf object with longitude/latitude CRS OGC:CRS84. No network download is used.}
\value{An sf polygon object.}
\details{Requires sf and maps. These are general-purpose display boundaries,
not survey-grade data or authoritative representations of disputed borders.
Use your own sf boundary data when greater accuracy is required.}
\examples{
if (requireNamespace("sf", quietly = TRUE) &&
    requireNamespace("maps", quietly = TRUE)) {
  states <- ancestry_basemap("state", c("ohio", "indiana", "kentucky"))
}
}
