% Generated manually; regenerate with roxygen2 via devtools::document().
\name{generate_base_reference}
\alias{generate_base_reference}
\title{Generate an asymmetric base reference waveform}
\usage{
generate_base_reference(header, waveform = "cosine", period = 24, phase = 0, width = 12)
}
\arguments{
\item{header}{Numeric vector of (folded) time points.}
\item{waveform}{One of \code{"cosine"}, \code{"trough"}, \code{"impulse"}, \code{"step"}.}
\item{period}{Period of the waveform.}
\item{phase}{Phase (peak location) of the waveform.}
\item{width}{Width/asymmetry parameter.}
}
\value{
Numeric vector of waveform values, one per element of \code{header}.
}
\description{
Reproduces \code{generate_base_reference} from the original BooteJTK Cython module: an asymmetric cosine (or trough/impulse/step) sampled at the given times.
}
