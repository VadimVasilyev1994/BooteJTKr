% Generated manually; regenerate with roxygen2 via devtools::document().
\name{emp_p}
\alias{emp_p}
\title{Empirical p-value against a null distribution}
\usage{
emp_p(taus, null)
}
\arguments{
\item{taus}{Numeric vector of observed statistics.}
\item{null}{Numeric vector of null statistics.}
}
\value{
Empirical p-values for \code{taus}.
}
\description{
Port of \code{empP}: \code{(sum(null >= t) + 1) / (length(null) + 1)}.
}
