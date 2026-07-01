% Generated manually; regenerate with roxygen2 via devtools::document().
\name{series_stats}
\alias{series_stats}
\title{Summary statistics for one raw series}
\usage{
series_stats(x)
}
\arguments{
\item{x}{Numeric vector of raw values for one series.}
}
\value{
A named numeric vector: \code{Mean}, \code{Std_Dev}, \code{Max}, \code{Min}, \code{Max_Amp}, \code{FC}, \code{IQR_FC}.
}
\description{
Computes the descriptive columns BooteJTK reports for each series, using the raw (un-folded) values and ignoring non-finite entries.
}
