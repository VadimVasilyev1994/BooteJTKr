#' Estimate per-time-point variances with limma/voom + vash (optional)
#'
#' Optional variance-shrinkage backend, faithfully ported from the original
#' \code{Limma_voom_vash_script.R}. For each unique (period-folded) time point it
#' applies \code{limma::vooma} (microarray) or \code{limma::voom} (RNA-seq) to
#' obtain precision weights, then moderates the resulting standard deviations
#' with \code{vashr::vash}. The output matches the means/SDs/Ns tables consumed
#' by \code{variance = "precomputed"} in \code{\link{boote_jtk}}.
#'
#' This backend requires the \pkg{limma} (Bioconductor) and \pkg{vashr}
#' (GitHub: mengyin/vashr) packages, which are \emph{not} dependencies of the
#' core package. If they are unavailable the function stops with guidance; the
#' built-in \code{variance = "ebayes"} route needs no external packages.
#'
#' @param mat Numeric matrix (series x time points), rows named by series ID.
#' @param header Character vector of time labels.
#' @param period Period used for folding.
#' @param rnaseq Logical; use \code{voom} (TRUE) or \code{vooma} (FALSE).
#'
#' @return A list of \code{means}, \code{sds} and \code{ns} matrices (series x
#'   unique time points) and \code{header2} (their time labels), suitable for
#'   passing to \code{\link{boote_jtk}} with \code{variance = "precomputed"}.
#' @export
variance_limma_vash <- function(mat, header, period, rnaseq = FALSE) {
  if (!requireNamespace("limma", quietly = TRUE) ||
      !requireNamespace("vashr", quietly = TRUE)) {
    stop("variance_limma_vash() needs the 'limma' (Bioconductor) and 'vashr' ",
         "(github: mengyin/vashr) packages. Install them where Bioconductor is ",
         "reachable, or use variance = 'ebayes' (no external dependencies).")
  }
  tx <- as.numeric(sub("^(ZT|CT|X)", "", header))
  while (any(duplicated(tx))) tx[duplicated(tx)] <- tx[duplicated(tx)] + period
  folded <- tx %% period
  t2 <- sort(unique(folded))
  MAX <- max(table(folded))

  f_changeNA <- function(x) {
    sd_ <- stats::median(apply(x, 1, function(y) stats::sd(y, na.rm = TRUE)), na.rm = TRUE)
    m_ <- mean(apply(x, 2, function(z) mean(z, na.rm = TRUE)), na.rm = TRUE)
    sm <- stats::sd(apply(x, 2, function(z) mean(z, na.rm = TRUE)), na.rm = TRUE)
    t(apply(x, 1, function(z) {
      if (is.na(mean(z, na.rm = TRUE))) z <- stats::rnorm(length(z), m_, sm)
      else if (any(is.na(z))) z[is.na(z)] <- stats::rnorm(sum(is.na(z)), mean(z, na.rm = TRUE), sd_)
      z
    }))
  }

  E_all <- NULL; W_all <- NULL; times <- c()
  for (h in t2) {
    cols <- which(folded == h)
    ser <- mat[, cols, drop = FALSE]
    times <- c(times, rep(h, nrow(mat)))
    ser <- f_changeNA(ser)
    vm <- if (rnaseq) limma::voom(ser) else limma::vooma(ser)
    E <- vm$E; W <- vm$weights
    if (is.null(dim(E))) { E <- matrix(E, ncol = 1); W <- matrix(W, ncol = 1) }
    while (ncol(E) < MAX) { E <- cbind(E, NA_real_); W <- cbind(W, NA_real_) }
    E_all <- rbind(E_all, E); W_all <- rbind(W_all, W)
  }

  sds_pre <- 1 / sqrt(W_all[, 1])
  na_pre <- is.na(sds_pre)
  sds_pre[na_pre] <- stats::runif(sum(na_pre), 1, length(sds_pre))
  df_vash <- {
    cnt <- apply(E_all, 1, function(z) sum(!is.na(z)))
    as.integer(names(sort(table(cnt), decreasing = TRUE))[1])
  }
  sds_post <- vashr::vash(sds_pre, df = df_vash)$sd.post

  ids <- rownames(mat)
  long <- data.frame(ID = rep(ids, length(t2)), Time = times,
                     Mean = apply(E_all, 1, function(z) mean(z, na.rm = TRUE)),
                     SD = sds_post, N = apply(E_all, 1, length),
                     stringsAsFactors = FALSE)
  cast <- function(val) {
    m <- tapply(long[[val]], list(long$ID, long$Time), function(z) z[1])
    m[ids, as.character(t2), drop = FALSE]
  }
  list(means = cast("Mean"), sds = cast("SD"), ns = cast("N"),
       header2 = as.character(t2))
}
