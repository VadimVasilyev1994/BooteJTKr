#' @keywords internal
.get_matches <- function(ranks, triples, refs, new_header) {
  n <- nrow(triples)
  res <- matrix(NA_real_, nrow = n, ncol = 6)
  imax <- which.max(ranks); imin <- which.min(ranks)
  maxloc <- new_header[imax]; minloc <- new_header[imin]
  for (k in seq_len(n)) {
    period <- triples[k, 1]; phase <- triples[k, 2]; width <- triples[k, 3]
    nadir <- (phase + width) %% period
    tau <- farctanh(kendall_tau(refs[[k]], ranks))
    if (is.na(tau)) tau <- -Inf
    if (tau >= 0) {
      res[k, ] <- c(tau, period, phase, nadir, maxloc, minloc)
    } else {
      res[k, ] <- c(abs(tau), period, nadir, phase, maxloc, minloc)
    }
  }
  res
}

#' @keywords internal
.pick_best_match <- function(res) {
  taus <- res[, 1]
  mask <- taus == max(taus)
  if (sum(mask) == 1) return(res[which(mask), ])
  res <- res[mask, , drop = FALSE]

  phases <- abs(res[, 3] - res[, 5])
  mask <- phases == min(phases)
  if (sum(mask) == 1) return(res[which(mask), ])
  res <- res[mask, , drop = FALSE]

  diffs <- abs(res[, 4] - res[, 6])
  mask <- diffs == min(diffs)
  if (sum(mask) == 1) return(res[which(mask), ])
  res <- res[mask, , drop = FALSE]

  res[sample.int(nrow(res), 1), ]
}

#' Compute tau / phase / period statistics for one series' bootstrap
#'
#' Port of \code{get_stat_probs}. For every distinct bootstrap ordering it finds
#' the best-matching reference (highest Fisher-transformed |tau|, breaking ties
#' on phase then nadir then at random), accumulates the bootstrap-weighted
#' distributions of tau, period, phase and nadir, and returns their means and
#' standard deviations (circular for phase and nadir).
#'
#' @param order_list Output of \code{\link{order_probs}}.
#' @param new_header Numeric folded time points.
#' @param triples Matrix of (period, phase, width) rows.
#' @param refs Reference waveforms from \code{\link{make_references}}.
#' @param size Number of bootstraps (used to weight the empirical spread).
#'
#' @return A list with \code{out1} = c(PeriodMean, PeriodStdDev, PhaseMean,
#'   PhaseStdDev, NadirMean, NadirStdDev), \code{out2} = c(TauMean, TauStdDev),
#'   and the weighted distributions \code{d_tau}, \code{d_per}, \code{d_ph},
#'   \code{d_na}.
#' @export
get_stat_probs <- function(order_list, new_header, triples, refs, size) {
  d_tau <- list(); d_per <- list(); d_ph <- list(); d_na <- list()
  add <- function(d, key, val) {
    k <- as.character(key)
    d[[k]] <- (if (is.null(d[[k]])) 0 else d[[k]]) + val
    d
  }
  rs <- vector("list", length(order_list))
  for (m in seq_along(order_list)) {
    ranks <- order_list[[m]]$ranks
    prob  <- order_list[[m]]$prob
    res <- .get_matches(ranks, triples, refs, new_header)
    best <- .pick_best_match(res)

    d_tau <- add(d_tau, best[1], prob)
    d_per <- add(d_per, best[2], prob)
    d_ph  <- add(d_ph,  best[3], prob)
    d_na  <- add(d_na,  best[4], prob)

    reps <- as.integer(round(size * prob))
    if (reps > 0) rs[[m]] <- matrix(best, nrow = reps, ncol = length(best), byrow = TRUE)
  }
  rs <- do.call(rbind, rs)

  m_tau <- mean(rs[, 1]); s_tau <- .pop_sd(rs[, 1])
  m_per <- mean(rs[, 2]); s_per <- .pop_sd(rs[, 2])
  m_ph  <- circ_mean(rs[, 3], 24, 0); s_ph <- circ_std(rs[, 3], 24, 0)
  m_na  <- circ_mean(rs[, 4], 24, 0); s_na <- circ_std(rs[, 4], 24, 0)

  list(out1 = c(m_per, s_per, m_ph, s_ph, m_na, s_na),
       out2 = c(m_tau, s_tau),
       d_tau = d_tau, d_per = d_per, d_ph = d_ph, d_na = d_na)
}
