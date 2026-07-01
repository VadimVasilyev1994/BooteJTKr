% Generated manually; regenerate with roxygen2 via devtools::document().
\name{get_stat_probs}
\alias{get_stat_probs}
\title{Compute tau / phase / period statistics for one series' bootstrap}
\usage{
get_stat_probs(order_list, new_header, triples, refs, size)
}
\arguments{
\item{order_list}{Output of \code{\link{order_probs}}.}
\item{new_header}{Numeric folded time points.}
\item{triples}{Matrix of (period, phase, width) rows.}
\item{refs}{Reference waveforms from \code{\link{make_references}}.}
\item{size}{Number of bootstraps (used to weight the empirical spread).}
}
\value{
A list with \code{out1} = c(PeriodMean, PeriodStdDev, PhaseMean, PhaseStdDev, NadirMean, NadirStdDev), \code{out2} = c(TauMean, TauStdDev), and weighted distributions \code{d_tau}, \code{d_per}, \code{d_ph}, \code{d_na}.
}
\description{
Port of \code{get_stat_probs}. For every distinct bootstrap ordering it finds the best-matching reference (highest Fisher-transformed |tau|, breaking ties on phase then nadir then at random) and summarises the bootstrap-weighted distributions.
}
