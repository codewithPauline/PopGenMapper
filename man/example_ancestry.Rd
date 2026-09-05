\name{example_ancestry}
\alias{example_ancestry}
\title{Fictional Population Ancestry Example}
\usage{example_ancestry()}
\description{Creates six fictional samples with two ancestry proportions and
fictional geographic coordinates. No research data are used.}
\value{A list with two data frames: \code{ancestry} and \code{coordinates}.}
\examples{
demo <- example_ancestry()
validate_ancestry(demo$ancestry, demo$coordinates)
}
