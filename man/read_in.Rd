% Generated manually; regenerate with roxygen2 via devtools::document().
\name{read_in}
\alias{read_in}
\title{Read a BooteJTK time-series file}
\usage{
read_in(fn)
}
\arguments{
\item{fn}{Path to the input file.}
}
\value{
A list with \code{header} (time labels), \code{ids} (series IDs) and \code{mat} (numeric matrix, series x time points).
}
\description{
Reads a tab-delimited file whose header row begins with \code{#} or \code{ID} followed by time-point labels (e.g. \code{ZT0}, \code{CT4}, or bare numbers). Remaining rows are a series ID followed by one value per time point; missing values may be \code{NA}.
}
