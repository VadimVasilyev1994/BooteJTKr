\name{BooteJTKr-package}
\alias{BooteJTKr-package}
\alias{BooteJTKr}
\docType{package}
\title{BooteJTKr: Bootstrapped empirical JTK_CYCLE in pure R}
\description{
A pure-R reimplementation of BooteJTK. The typical entry point is
\code{\link{run_booteJTK}}, which runs the full data + null + p-value pipeline.
\code{\link{boote_jtk}} runs the engine on a single matrix without the
null/p-value step.
}
\details{
Because bootstrapping and tie-breaking use random numbers, output matches the
original Python implementation in distribution rather than bit-for-bit; the
deterministic descriptive columns are identical. Set \code{seed} for
reproducible runs.
}
\keyword{internal}
