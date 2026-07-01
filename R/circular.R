#' Circular mean on a bounded scale
#'
#' Reproduces \code{scipy.stats.circmean(samples, high, low)}. Values are mapped
#' onto the circle \eqn{[low, high)}, averaged as angles, and mapped back.
#'
#' @param x Numeric vector of samples.
#' @param high Upper bound of the circular scale (default 24).
#' @param low Lower bound of the circular scale (default 0).
#'
#' @return A single numeric value: the circular mean on the \code{[low, high)} scale.
#' @export
circ_mean <- function(x, high = 24, low = 0) {
  x <- x[is.finite(x)]
  if (length(x) == 0) return(NA_real_)
  ang <- (x - low) * 2 * pi / (high - low)
  S <- mean(sin(ang))
  C <- mean(cos(ang))
  res <- atan2(S, C)
  res <- res %% (2 * pi)
  res * (high - low) / (2 * pi) + low
}

#' Circular standard deviation on a bounded scale
#'
#' Reproduces \code{scipy.stats.circstd(samples, high, low)} (with
#' \code{normalize = FALSE}).
#'
#' @param x Numeric vector of samples.
#' @param high Upper bound of the circular scale (default 24).
#' @param low Lower bound of the circular scale (default 0).
#'
#' @return A single numeric value: the circular standard deviation.
#' @export
circ_std <- function(x, high = 24, low = 0) {
  x <- x[is.finite(x)]
  if (length(x) == 0) return(NA_real_)
  ang <- (x - low) * 2 * pi / (high - low)
  S <- mean(sin(ang))
  C <- mean(cos(ang))
  R <- sqrt(S^2 + C^2)
  sqrt(-2 * log(R)) * (high - low) / (2 * pi)
}
