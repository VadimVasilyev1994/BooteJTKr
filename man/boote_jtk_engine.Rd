% Generated manually; regenerate with roxygen2 via devtools::document().
\name{boote_jtk_engine}
\alias{boote_jtk_engine}
\title{Run the BooteJTK engine on prepared data}
\usage{
boote_jtk_engine(d_data, new_header, triples, refs, size, raw_mat, waveform = "cosine")
}
\arguments{
\item{d_data}{Named list of \code{list(means, sds, ns)} per series.}
\item{new_header}{Numeric folded time points.}
\item{triples}{Matrix of (period, phase, width) rows.}
\item{refs}{Reference waveforms from \code{\link{make_references}}.}
\item{size}{Number of bootstraps.}
\item{raw_mat}{Numeric matrix of raw values (series x time points) for the descriptive columns; rows named by series ID.}
\item{waveform}{Waveform label recorded in the output (default \code{"cosine"}).}
}
\value{
A data frame with the standard BooteJTK columns.
}
\description{
Core engine shared by the real-data and null runs. Results are sorted by descending \code{abs(TauMean)}.
}
