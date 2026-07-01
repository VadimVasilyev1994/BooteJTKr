% Generated manually; regenerate with roxygen2 via devtools::document().
\name{kendall_tau}
\alias{kendall_tau}
\title{Kendall's tau-b correlation}
\usage{
kendall_tau(x, y)
}
\arguments{
\item{x}{Numeric vector.}
\item{y}{Numeric vector of equal length to \code{x}.}
}
\value{
The tau-b statistic, or \code{NA_real_} if it is undefined.
}
\description{
Returns the tau-b statistic (ties-corrected), matching \code{scipy.stats.kendalltau} as used in the original BooteJTK. Base R's \code{cor(method = "kendall")} already implements tau-b, so this is a thin, NA-safe wrapper.
}
\examples{
kendall_tau(c(1, 2, 3, 4), c(2, 1, 4, 3))
}
