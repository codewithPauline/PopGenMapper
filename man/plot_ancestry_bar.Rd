\name{plot_ancestry_bar}
\alias{plot_ancestry_bar}
\title{Draw an Individual Ancestry Barplot}
\usage{
plot_ancestry_bar(data, palette = NULL, order = NULL,
                 main = "Individual ancestry", labels = TRUE)
}
\arguments{
\item{data}{Result of \code{validate_ancestry()}. Inputs are checked again.}
\item{palette}{Named character vector of colors, covering all clusters.
The default uses the Dark 3 HCL palette in cluster-column order.}
\item{order}{Character vector containing each sample ID exactly once.
Defaults to input ancestry order.}
\item{main}{Plot title.}
\item{labels}{Logical: display sample IDs.}
}
\description{Draws a stacked bar for each individual using base R graphics.}
\details{For consistent colors across different cluster-column orders, pass the
same named palette to both plotting functions. For very large sample sets,
disable labels or use a wider graphics device. No cluster alignment is inferred.}
\value{Invisibly returns a list with sample \code{order}, \code{colors},
bar \code{positions}, and the reordered \code{proportions} matrix.}
\examples{
demo <- example_ancestry()
x <- validate_ancestry(demo$ancestry, demo$coordinates)
plot_ancestry_bar(x)
}
