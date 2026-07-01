#' Solve trigamma(y) = x
#'
#' Newton iteration used by the empirical-Bayes shrinkage, ported from the
#' original \code{solve_trigamma}, with guards so a degenerate or out-of-range
#' target returns \code{Inf} (an infinite prior degrees of freedom) instead of
#' diverging to \code{NaN}.
#'
#' @param x A numeric scalar.
#'
#' @return The value \code{y} such that \code{trigamma(y) == x}, or \code{Inf}
#'   when \code{x} is non-positive or non-finite.
#' @keywords internal
solve_trigamma <- function(x) {
  if (!is.finite(x) || x <= 0) return(Inf)
  tetragamma <- function(z) psigamma(z, deriv = 2)
  y <- 0.5 + 1 / x
  for (iter in seq_len(50)) {
    tg <- trigamma(y)
    d <- tg * (1 - tg / x) / tetragamma(y)
    y <- y + d
    if (!is.finite(y) || y <= 0) return(Inf)
    if (-d / y < 1e-8) break
  }
  y
}

#' Internal empirical-Bayes variance shrinkage
#'
#' Self-contained port of the original BooteJTK \code{eBayes} routine, which
#' implements the Smyth (2004) empirical-Bayes variance moderation. Per-time-point
#' standard deviations are shrunk toward a pooled prior; replicate counts are then
#' set to 1, matching the original.
#'
#' The prior is estimated from the pooled per-time-point variances across all
#' series in the call, so it is only well determined when many series are present
#' (transcriptome-scale). Two guards make it robust when that assumption is
#' stretched: if the between-series spread of log-variances does not exceed the
#' sampling spread, the prior degrees of freedom is taken as infinite (all SDs
#' shrink to the common prior SD, the correct Smyth limit); and if the prior
#' still cannot be estimated (e.g. every SD is zero), the input SDs are returned
#' unshrunk with a warning.
#'
#' @param d_data A named list; each element is \code{list(means, sds, ns)} with
#'   equal-length numeric vectors (one entry per time point).
#' @param d_null Optional named list in the same format, used to estimate the
#'   prior from a designated set of (non-cycling) series. If empty, the prior is
#'   estimated from \code{d_data} itself.
#'
#' @return \code{d_data} with moderated \code{sds} and \code{ns} set to 1.
#' @export
eBayes <- function(d_data, d_null = list()) {
  src <- if (length(d_null) > 0) d_null else d_data
  dg <- unlist(lapply(src, function(e) e[[3]]), use.names = FALSE)
  s  <- unlist(lapply(src, function(e) e[[2]]), use.names = FALSE)

  keep <- s != 0 & !is.na(s)
  s2 <- s[keep]; dg2 <- dg[keep]
  G <- length(dg2)

  if (G < 2) {
    warning("eBayes: too few non-zero variances to estimate a prior; ",
            "returning unshrunk SDs.")
    return(d_data)
  }

  z <- 2 * log(s2)
  e <- z - digamma(dg2 / 2) + log(dg2 / 2)
  emean <- mean(e, na.rm = TRUE)
  target <- mean((e - emean)^2 * G / (G - 1) - trigamma(dg2 / 2), na.rm = TRUE)

  if (!is.finite(target) || target <= 0) {
    d0 <- Inf
    s0 <- sqrt(exp(emean))                       # infinite-prior limit
  } else {
    d0 <- 2 * solve_trigamma(target)
    s0 <- if (is.finite(d0))
            sqrt(exp(emean + digamma(d0 / 2) - log(d0 / 2)))
          else sqrt(exp(emean))
  }

  if (!is.finite(s0)) {
    warning("eBayes: prior SD could not be estimated; returning unshrunk SDs.")
    return(d_data)
  }

  posterior_s <- function(d0, s0, s, d) {
    if (!is.finite(d0)) return(s0)               # all shrink to the common prior SD
    sqrt((d0 * s0^2 + d * s^2) / (d0 + d))
  }

  for (key in names(d_data)) {
    sds <- d_data[[key]][[2]]; ns <- d_data[[key]][[3]]
    d_data[[key]][[2]] <- mapply(function(si, di) {
      if (!is.finite(si) || si == 0) si <- s0    # keep degenerate points sensible
      posterior_s(d0, s0, si, di)
    }, sds, ns)
    d_data[[key]][[3]] <- rep(1, length(sds))
  }
  attr(d_data, "d0") <- d0; attr(d_data, "s0") <- s0
  d_data
}
