\name{plot_ancestry_projected}
\alias{plot_ancestry_projected}
\title{Plot Ancestry Pies over Projected Geographic Boundaries}
\usage{
plot_ancestry_projected(data, basemap, crs, palette = NULL,
                       radius = 0.035,
                       main = "Projected geographic ancestry",
                       labels = TRUE, label_cex = 0.75,
                       land_color = "#E5EBD8", border_color = "#879485")
}
\arguments{
\item{data}{Validated individual or locality ancestry data.}
\item{basemap}{Nonempty sf or sfc polygon boundaries with a declared CRS.}
\item{crs}{An explicit projected CRS accepted by sf::st_crs. Choose one
appropriate for the study region; no projection is suitable everywhere.}
\item{palette}{Named colors covering all ancestry clusters.}
\item{radius}{Pie radius fraction of the smaller device dimension, in (0, 0.1].}
\item{main}{Plot title.}
\item{labels}{Display automatically positioned sample or locality labels.}
\item{label_cex}{Positive finite label size.}
\item{land_color}{Polygon fill color.}
\item{border_color}{Polygon outline color.}
}
\description{Transforms WGS84 longitude/latitude samples and the supplied
boundaries to the same projected CRS before drawing device-circular pies.}
\details{Requires sf. The full basemap and sample extent is displayed; subset
the basemap first for regional detail. Empty or nonfinite projection results
are rejected. Dateline-crossing sample extents are not supported.
A blue background is decorative and does not assert mapped water coverage.
The function does not infer an appropriate projection or validate a CRS area
of use. Label placement may still require adjustment in dense maps.}
\value{Invisibly returns IDs, colors, sectors, radius in projected units,
label positions, target CRS, projected points and projected basemap.}
\examples{
if (requireNamespace("sf", quietly = TRUE) &&
    requireNamespace("maps", quietly = TRUE)) {
  d <- example_ancestry()
  x <- validate_ancestry(d$ancestry, d$coordinates)
  b <- ancestry_basemap("state", c("ohio", "indiana", "kentucky"))
  plot_ancestry_projected(x, b, crs = 5070)
}
}
