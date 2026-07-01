% Generated manually; regenerate with roxygen2 via devtools::document().
\name{order_probs}
\alias{order_probs}
\title{Bootstrap a series into rank-order probabilities}
\usage{
order_probs(means, sds, ns, size)
}
\arguments{
\item{means}{Numeric vector of per-time-point means.}
\item{sds}{Numeric vector of per-time-point standard deviations.}
\item{ns}{Numeric vector of replicate counts (accepted for signature compatibility; not used).}
\item{size}{Number of bootstrap replicates.}
}
\value{
A list of distinct orderings; each element is \code{list(ranks, prob)}, with probabilities summing to 1.
}
\description{
Port of \code{dict_order_probs}/\code{dict_of_orders}. Draws \code{size} bootstrap replicates (each time point sampled from \code{Normal(mean_i, sd_i)}), converts each to a rank vector, and tallies how often each ordering occurs.
}
