% Generated manually; regenerate with roxygen2 via devtools::document().
\name{eBayes}
\alias{eBayes}
\title{Internal empirical-Bayes variance shrinkage}
\usage{
eBayes(d_data, d_null = list())
}
\arguments{
\item{d_data}{A named list; each element is \code{list(means, sds, ns)} with equal-length numeric vectors (one entry per time point).}
\item{d_null}{Optional named list in the same format, used to estimate the prior from a designated set of (non-cycling) series. If empty, the prior is estimated from \code{d_data} itself.}
}
\value{
\code{d_data} with moderated \code{sds} and \code{ns} set to 1.
}
\description{
Self-contained port of the original BooteJTK \code{eBayes} routine, implementing Smyth (2004) empirical-Bayes variance moderation. Per-time-point standard deviations are shrunk toward a pooled prior; replicate counts are then set to 1.
}
