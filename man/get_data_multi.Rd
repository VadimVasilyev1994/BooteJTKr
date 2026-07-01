% Generated manually; regenerate with roxygen2 via devtools::document().
\name{get_data_multi}
\alias{get_data_multi}
\title{Assemble per-time-point summaries from separate means/SDs/Ns}
\usage{
get_data_multi(header, header2, means, sds, ns, period)
}
\arguments{
\item{header}{Character vector of time labels from the raw data.}
\item{header2}{Character vector of time labels from the means/SDs/Ns tables.}
\item{means}{Numeric matrix of means (series x unique time points).}
\item{sds}{Numeric matrix of standard deviations.}
\item{ns}{Numeric matrix of replicate counts.}
\item{period}{Period used for folding.}
}
\value{
A list with \code{d_data} and \code{new_header} as in \code{\link{get_data2}}.
}
\description{
Port of \code{get_data_multi}, used by the limma/vash route where variance shrinkage has already produced separate means, SD and count tables. Columns are aligned to the data header by folded time.
}
