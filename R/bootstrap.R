#' Bootstrap a series into rank-order probabilities
#'
#' Port of \code{dict_order_probs}/\code{dict_of_orders}. Draws \code{size}
#' bootstrap replicates of the time series, each time point sampled
#' independently from \code{Normal(mean_i, sd_i)}, converts each replicate to a
#' rank vector, and tallies how often each distinct ordering occurs. Missing
#' standard deviations are replaced by the mean SD, as in the original.
#'
#' @param means,sds,ns Numeric vectors (one entry per time point). \code{ns} is
#'   accepted for signature compatibility but not used here.
#' @param size Number of bootstrap replicates.
#'
#' @return A list of distinct orderings; each element is
#'   \code{list(ranks = <integer vector>, prob = <numeric>)}, with probabilities
#'   summing to 1.
#' @export
order_probs <- function(means, sds, ns, size) {
  sds[!is.finite(sds)] <- mean(sds[is.finite(sds)])
  L <- length(means)
  s3 <- matrix(NA_real_, nrow = size, ncol = L)
  for (i in seq_len(L)) s3[, i] <- stats::rnorm(size, means[i], sds[i])

  rk <- t(apply(s3, 1, function(r) as.integer(rank(r))))
  keys <- apply(rk, 1, paste, collapse = ",")
  tab <- table(keys)
  uniq_keys <- names(tab)

  first_idx <- match(uniq_keys, keys)
  out <- lapply(seq_along(uniq_keys), function(k) {
    list(ranks = rk[first_idx[k], ],
         prob  = as.numeric(tab[k]) / size)
  })
  out
}
