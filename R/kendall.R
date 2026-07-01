#' Kendall's tau-b correlation
#'
#' Returns the tau-b statistic (ties-corrected), matching the value computed by
#' \code{scipy.stats.kendalltau} as used in the original BooteJTK. Base R's
#' \code{cor(method = "kendall")} already implements tau-b, so this is a thin,
#' NA-safe wrapper. The original code divides the (unused) p-value by two; only
#' the statistic itself feeds the downstream BooteJTK calculation, so no p-value
#' is returned here.
#'
#' @param x,y Numeric vectors of equal length.
#'
#' @return The tau-b statistic, or \code{NA_real_} if it is undefined.
#' @export
kendall_tau <- function(x, y) {
  if (length(x) == 0 || length(y) == 0) return(NA_real_)
  suppressWarnings(stats::cor(x, y, method = "kendall"))
}

#' Fisher (arctanh) transform with clamping
#'
#' Applies \code{atanh} after clamping the input to \eqn{[-0.99, 0.99]}, exactly
#' as the original \code{farctanh} does. This keeps the transformed tau finite.
#'
#' @param x A numeric scalar (typically a tau value).
#'
#' @return The clamped arctanh of \code{x}.
#' @export
farctanh <- function(x) {
  if (is.na(x)) return(NA_real_)
  if (x > 0.99) return(atanh(0.99))
  if (x < -0.99) return(atanh(-0.99))
  atanh(x)
}
