% Generated manually; regenerate with roxygen2 via devtools::document().
\name{circ_mean}
\alias{circ_mean}
\title{Circular mean on a bounded scale}
\usage{
circ_mean(x, high = 24, low = 0)
}
\arguments{
\item{x}{Numeric vector of samples.}
\item{high}{Upper bound of the circular scale (default 24).}
\item{low}{Lower bound of the circular scale (default 0).}
}
\value{
A single numeric value: the circular mean on the \code{[low, high)} scale.
}
\description{
Reproduces \code{scipy.stats.circmean(samples, high, low)}.
}
\examples{
circ_mean(c(20, 22, 0, 2), high = 24, low = 0)
}
