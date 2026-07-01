% Generated manually; regenerate with roxygen2 via devtools::document().
\name{run_booteJTK}
\alias{run_booteJTK}
\title{Full BooteJTK + p-value pipeline}
\usage{
run_booteJTK(file = NULL, mat = NULL, header = NULL, periods, phases, widths,
  size, prefix = "", n_null = 1000, variance = c("ebayes", "none", "precomputed"),
  means = NULL, sds = NULL, ns = NULL, null_ids = NULL, waveform = "cosine",
  seed = NULL, out_dir = NULL)
}
\arguments{
\item{file}{Path to a BooteJTK input file (alternative to \code{mat}/\code{header}).}
\item{mat}{Data matrix (alternative to \code{file}).}
\item{header}{Time labels (alternative to \code{file}).}
\item{periods}{Numeric search grid of periods.}
\item{phases}{Numeric search grid of phases.}
\item{widths}{Numeric search grid of widths/asymmetries.}
\item{size}{Number of bootstraps.}
\item{prefix}{String inserted into output filenames.}
\item{n_null}{Number of null series to generate (default 1000).}
\item{variance}{Variance route; see \code{\link{boote_jtk}}.}
\item{means}{Optional precomputed means matrix.}
\item{sds}{Optional precomputed SD matrix.}
\item{ns}{Optional precomputed count matrix.}
\item{null_ids}{Optional IDs for the empirical-Bayes prior.}
\item{waveform}{Waveform shape (default \code{"cosine"}).}
\item{seed}{Optional integer seed.}
\item{out_dir}{Optional directory; if given, results are written to disk.}
}
\value{
A data frame: the BooteJTK results with \code{empP}, \code{GammaP} and \code{GammaBH} columns, sorted by descending \code{abs(TauMean)}.
}
\description{
End-to-end port of \code{BooteJTK-CalcP.py}: runs BooteJTK on the data, generates a Gaussian null with the same header, runs BooteJTK on the null, and assigns gamma and empirical p-values.
}
\examples{
\dontrun{
f <- system.file("extdata", "TestInput4.txt", package = "BooteJTKr")
res <- run_booteJTK(file = f, periods = 24, phases = seq(0, 22, 2),
                    widths = seq(2, 22, 2), size = 25, n_null = 1000,
                    variance = "ebayes", seed = 1)
}
}
