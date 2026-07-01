% Generated manually; regenerate with roxygen2 via devtools::document().
\name{variance_limma_vash}
\alias{variance_limma_vash}
\title{Estimate per-time-point variances with limma/voom + vash (optional)}
\usage{
variance_limma_vash(mat, header, period, rnaseq = FALSE)
}
\arguments{
\item{mat}{Numeric matrix (series x time points), rows named by series ID.}
\item{header}{Character vector of time labels.}
\item{period}{Period used for folding.}
\item{rnaseq}{Logical; use \code{voom} (TRUE) or \code{vooma} (FALSE).}
}
\value{
A list of \code{means}, \code{sds} and \code{ns} matrices and \code{header2}, suitable for \code{\link{boote_jtk}} with \code{variance = "precomputed"}.
}
\description{
Optional variance-shrinkage backend, ported from \code{Limma_voom_vash_script.R}. Requires the \pkg{limma} (Bioconductor) and \pkg{vashr} (GitHub: mengyin/vashr) packages, which are not dependencies of the core package.
}
