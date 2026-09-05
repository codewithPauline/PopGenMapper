\name{plot_ancestry_map}
\alias{plot_ancestry_map}
\title{Draw Regional Geographic Ancestry Pies}
\usage{
plot_ancestry_map(data, palette = NULL, radius = 0.035,
                 main = "Geographic ancestry", labels = TRUE,
                 draw_basemap = NULL)
}
\arguments{
\item{data}{Result of \code{validate_ancestry()}. Inputs are checked again.}
\item{palette}{Named character vector of colors covering every cluster.
The default uses the Dark 3 HCL palette in cluster-column order.}
\item{radius}{Pie radius as a fraction of the shorter plot dimension;
must be greater than zero and at most 0.1.}
\item{main}{Plot title.}
\item{labels}{Logical: display sample IDs above pies.}
\item{draw_basemap}{Optional function with no required arguments that adds
a longitude/latitude basemap to the existing plot without resetting its limits
or aspect ratio. NULL draws a coordinate grid only.}
}
\description{Draws one ancestry pie per individual at its geographic coordinates.}
\details{This function uses a regional longitude/latitude display with aspect
correction at mean sample latitude. It does not transform a coordinate reference
system. Extents exceeding 60 degrees or latitudes at or beyond 85 degrees are
rejected; dateline-crossing data are unsupported. Duplicate coordinate pairs
produce an overlap warning; no automatic locality aggregation is performed.
Pies are circular in device space. Accepted row-sum rounding differences are
closed to a full circle for drawing; the input data are not modified.
Labels may overlap in dense datasets. Export to a larger device or disable them.
The default background is a coordinate grid, not a geographic boundary dataset.}
\value{Invisibly returns a list of sample \code{ids}, named \code{colors},
drawn \code{sectors}, and the pie \code{radius} in longitude and latitude units.}
\examples{
demo <- example_ancestry()
x <- validate_ancestry(demo$ancestry, demo$coordinates)
plot_ancestry_map(x)
}
