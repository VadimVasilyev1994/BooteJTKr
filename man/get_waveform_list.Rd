% Generated manually; regenerate with roxygen2 via devtools::document().
\name{get_waveform_list}
\alias{get_waveform_list}
\title{Build the list of (period, phase, width) reference triples}
\usage{
get_waveform_list(periods, phases, widths)
}
\arguments{
\item{periods}{Numeric vector of candidate periods.}
\item{phases}{Numeric vector of candidate phases.}
\item{widths}{Numeric vector of candidate widths/asymmetries.}
}
\value{
A numeric matrix with three columns (period, phase, width).
}
\description{
Faithful port of \code{get_waveform_list}, including the phase/nadir mirror-pair de-duplication of the original.
}
