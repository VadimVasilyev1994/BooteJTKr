% Generated manually; regenerate with roxygen2 via devtools::document().
\name{gamma_fit}
\alias{gamma_fit}
\title{Fit a 3-parameter gamma distribution by maximum likelihood}
\usage{
gamma_fit(x)
}
\arguments{
\item{x}{Numeric vector (the null tau values).}
}
\value{
A numeric vector \code{c(shape, loc, scale)}.
}
\description{
Reproduces \code{scipy.stats.gamma.fit} (shape, location, scale) as used by the original \code{CalcP}. Optimisation is over shape > 0, scale > 0 and location < min(x).
}
