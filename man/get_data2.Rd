% Generated manually; regenerate with roxygen2 via devtools::document().
\name{get_data2}
\alias{get_data2}
\title{Collapse replicates into per-time-point summaries}
\usage{
get_data2(header, mat, period)
}
\arguments{
\item{header}{Character vector of time labels.}
\item{mat}{Numeric matrix (series x time points).}
\item{period}{Period used for folding.}
}
\value{
A list with \code{d_data} (named list of \code{list(means, sds, ns)} per series) and \code{new_header} (numeric folded times).
}
\description{
Port of the original \code{get_data2}. Header labels are folded modulo the period; for each header position the values sharing that folded time are pooled to give a mean, a population standard deviation and a replicate count.
}
