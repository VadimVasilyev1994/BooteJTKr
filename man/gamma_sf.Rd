% Generated manually; regenerate with roxygen2 via devtools::document().
\name{gamma_sf}
\alias{gamma_sf}
\title{Gamma survival probability}
\usage{
gamma_sf(x, params)
}
\arguments{
\item{x}{Numeric vector of observed statistics.}
\item{params}{\code{c(shape, loc, scale)}, e.g. from \code{\link{gamma_fit}}.}
}
\value{
Survival probabilities \code{P(X > x)}.
}
\description{
Computes the gamma survival function, matching \code{scipy.stats.gamma.sf}.
}
