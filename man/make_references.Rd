% Generated manually; regenerate with roxygen2 via devtools::document().
\name{make_references}
\alias{make_references}
\title{Pre-compute reference waveforms for all triples}
\usage{
make_references(header, triples, waveform = "cosine")
}
\arguments{
\item{header}{Numeric vector of (folded) time points.}
\item{triples}{Matrix of (period, phase, width) rows, e.g. from \code{\link{get_waveform_list}}.}
\item{waveform}{Waveform shape (default \code{"cosine"}).}
}
\value{
A list with one numeric reference vector per row of \code{triples}; \code{attr(., "keys")} holds the matrix of triples.
}
\description{
Port of \code{make_references}: returns a list of reference waveforms keyed by triple.
}
