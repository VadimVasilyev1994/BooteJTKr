#' Solve trigamma(y) = x
#'
#' Newton iteration used by the empirical-Bayes shrinkage, ported from the
#' original \code{solve_trigamma}.
#'
#' @param x A positive numeric scalar.
#'
#' @return The value \code{y} such that \code{trigamma(y) == x}.
#' @keywords internal
solve_trigamma <- function(x) {
  tetragamma <- function(z) psigamma(z, deriv = 2)
  y <- 0.5 + 1 / x
  d <- 1e6
  repeat {
    d <- trigamma(y) * (1 - trigamma(y) / x) / tetragamma(y)
    y <- y + d
    if (!(-d / y > 1e-8)) break
  }
  y
}

#' Internal empirical-Bayes variance shrinkage
#'
#' Self-contained port of the original BooteJTK \code{eBayes} routine, which
#' implements the Smyth (2004) empirical-Bayes variance moderation. Per-time-point
#' standard deviations are shrunk toward a pooled prior; replicate counts are then
#' set to 1, matching the original (which does this so downstream bootstrapping
#' treats the moderated SD as exact).
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
  s2 <- s[keep]
  dg2 <- dg[keep]
  G <- length(dg2)

  z <- 2 * log(s2)
  digamma_ <- function(v) digamma(v)
  e <- z - digamma_(dg2 / 2) + log(dg2 / 2)
  emean <- mean(e, na.rm = TRUE)
  d0 <- 2 * solve_trigamma(
    mean((e - emean)^2 * G / (G - 1) - trigamma(dg2 / 2), na.rm = TRUE)
  )
  s0 <- sqrt(exp(emean + digamma_(d0 / 2) - log(d0 / 2)))

  posterior_s <- function(d0, s0, s, d) sqrt((d0 * s0^2 + d * s^2) / (d0 + d))

  for (key in names(d_data)) {
    sds <- d_data[[key]][[2]]
    ns  <- d_data[[key]][[3]]
    d_data[[key]][[2]] <- mapply(function(si, di) posterior_s(d0, s0, si, di),
                                 sds, ns)
    d_data[[key]][[3]] <- rep(1, length(sds))
  }
  attr(d_data, "d0") <- d0
  attr(d_data, "s0") <- s0
  d_data
}
