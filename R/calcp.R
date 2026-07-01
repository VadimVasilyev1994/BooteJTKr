#' Fit a 3-parameter gamma distribution by maximum likelihood
#'
#' Reproduces \code{scipy.stats.gamma.fit} (shape, location, scale) as used by
#' the original \code{CalcP}. The default BooteJTK pipeline does not use the
#' optional constrained refit, so this maximum-likelihood fit is the operative
#' one. Optimisation is over shape > 0, scale > 0 and location < min(x).
#'
#' @param x Numeric vector (the null tau values).
#'
#' @return A numeric vector \code{c(shape, loc, scale)}.
#' @export
gamma_fit <- function(x) {
  x <- x[is.finite(x)]
  mx <- min(x)
  # Method-of-moments start (loc just below the minimum).
  v <- stats::var(x); m <- mean(x)
  a0 <- max((m - (mx - 1e-3))^2 / v, 0.1)
  scale0 <- v / max(m - (mx - 1e-3), 1e-6)
  loc0 <- mx - 1e-3

  negll <- function(par) {
    a <- par[1]; loc <- par[2]; scale <- par[3]
    if (a <= 0 || scale <= 0 || loc >= mx) return(1e10)
    ll <- stats::dgamma(x - loc, shape = a, scale = scale, log = TRUE)
    if (any(!is.finite(ll))) return(1e10)
    -sum(ll)
  }
  fit <- stats::optim(c(a0, loc0, scale0), negll,
                      method = "Nelder-Mead",
                      control = list(maxit = 5000, reltol = 1e-12))
  # A short polish improves agreement with scipy's optimiser.
  fit <- stats::optim(fit$par, negll, method = "Nelder-Mead",
                      control = list(maxit = 5000, reltol = 1e-12))
  c(shape = fit$par[1], loc = fit$par[2], scale = fit$par[3])
}

#' Gamma survival probability
#'
#' @param x Numeric vector of observed statistics.
#' @param params \code{c(shape, loc, scale)}, e.g. from \code{\link{gamma_fit}}.
#' @return Survival probabilities \code{P(X > x)}.
#' @export
gamma_sf <- function(x, params) {
  stats::pgamma(x - params[2], shape = params[1], scale = params[3],
                lower.tail = FALSE)
}

#' Empirical p-value against a null distribution
#'
#' Port of \code{empP}: \code{(sum(null >= t) + 1) / (length(null) + 1)}.
#'
#' @param taus Numeric vector of observed statistics.
#' @param null Numeric vector of null statistics.
#' @return Empirical p-values for \code{taus}.
#' @export
emp_p <- function(taus, null) {
  vapply(taus, function(t) (sum(null >= t) + 1) / (length(null) + 1), numeric(1))
}

#' Assign gamma and empirical p-values to a BooteJTK result table
#'
#' Port of \code{CalcP.main} for the default (non-refit) path. Fits a gamma to
#' the null \code{TauMean} values, computes the gamma survival p-value and the
#' empirical p-value for each series, takes their element-wise minimum as
#' \code{GammaP}, and adds a Benjamini-Hochberg correction \code{GammaBH}.
#'
#' @param jtk Data frame of BooteJTK results (must contain \code{TauMean}).
#' @param null_taus Numeric vector of null \code{TauMean} values.
#'
#' @return \code{jtk} with added columns \code{empP}, \code{GammaP},
#'   \code{GammaBH}.
#' @export
calc_p <- function(jtk, null_taus) {
  params <- gamma_fit(null_taus)
  keys <- as.numeric(jtk$TauMean)

  empP <- emp_p(keys, null_taus)
  gammaP <- gamma_sf(keys, params)
  finalP <- pmin(empP, gammaP)

  jtk$empP <- empP
  jtk$GammaP <- finalP
  jtk$GammaBH <- stats::p.adjust(finalP, method = "BH")
  attr(jtk, "gamma_params") <- params
  jtk
}
