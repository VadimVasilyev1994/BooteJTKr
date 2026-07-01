% Generated manually; regenerate with roxygen2 via devtools::document().
\name{boote_jtk}
\alias{boote_jtk}
\title{Run BooteJTK on a data matrix}
\usage{
boote_jtk(mat, header, periods, phases, widths, size, waveform = "cosine",
  variance = c("ebayes", "none", "precomputed"), means = NULL, sds = NULL,
  ns = NULL, null_ids = NULL, seed = NULL)
}
\arguments{
\item{mat}{Numeric matrix (series x time points), rows named by series ID.}
\item{header}{Character vector of time labels (one per column of \code{mat}).}
\item{periods}{Numeric search grid of periods.}
\item{phases}{Numeric search grid of phases.}
\item{widths}{Numeric search grid of widths/asymmetries.}
\item{size}{Number of bootstraps.}
\item{waveform}{Waveform shape (default \code{"cosine"}).}
\item{variance}{One of \code{"ebayes"} (default), \code{"none"}, or \code{"precomputed"}.}
\item{means}{Optional means matrix for \code{variance = "precomputed"}.}
\item{sds}{Optional SD matrix for \code{variance = "precomputed"}.}
\item{ns}{Optional count matrix for \code{variance = "precomputed"}.}
\item{null_ids}{Optional character vector of series IDs used to estimate the empirical-Bayes prior.}
\item{seed}{Optional integer seed for reproducibility.}
}
\value{
A data frame of BooteJTK results.
}
\description{
Convenience wrapper that prepares per-time-point variance estimates, builds the reference bank and runs the engine.
}
