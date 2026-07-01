% Generated manually; regenerate with roxygen2 via devtools::document().
\name{circ_std}
\alias{circ_std}
\title{Circular standard deviation on a bounded scale}
\usage{
circ_std(x, high = 24, low = 0)
}
\arguments{
\item{x}{Numeric vector of samples.}
\item{high}{Upper bound of the circular scale (default 24).}
\item{low}{Lower bound of the circular scale (default 0).}
}
\value{
A single numeric value: the circular standard deviation.
}
\description{
Reproduces \code{scipy.stats.circstd(samples, high, low)} (with \code{normalize = FALSE}).
}
\examples{
circ_std(c(20, 22, 0, 2), high = 24, low = 0)
}
