#' @keywords internal
.fold_times <- function(header, period) {
  vapply(header, function(h) {
    hs <- sub("^(ZT|CT)", "", h)
    as.numeric(hs) %% period
  }, numeric(1), USE.NAMES = FALSE)
}

#' Collapse replicates into per-time-point summaries
#'
#' Port of the original \code{get_data2}. Header labels are folded modulo the
#' period; for each header position the values sharing that folded time are
#' pooled to give a mean, a population standard deviation and a replicate count.
#' As in the original, the returned vectors have one entry per header column (so
#' positions sharing a folded time carry identical summaries), which preserves
#' the replicate structure used by the bootstrap.
#'
#' @param header Character vector of time labels.
#' @param mat Numeric matrix (series x time points).
#' @param period Period used for folding.
#'
#' @return A list with \code{d_data} (named list of
#'   \code{list(means, sds, ns)} per series) and \code{new_header} (numeric
#'   folded times).
#' @export
get_data2 <- function(header, mat, period) {
  new_h <- .fold_times(header, period)
  col_idx <- lapply(new_h, function(t) which(new_h == t))

  d_data <- vector("list", nrow(mat))
  names(d_data) <- rownames(mat)
  for (g in seq_len(nrow(mat))) {
    vals <- mat[g, ]
    means <- numeric(length(new_h))
    sds   <- numeric(length(new_h))
    ns    <- numeric(length(new_h))
    for (i in seq_along(new_h)) {
      pts <- vals[col_idx[[i]]]
      ns[i]    <- sum(is.finite(pts))
      means[i] <- if (any(is.finite(pts))) mean(pts[is.finite(pts)]) else NaN
      sds[i]   <- .pop_sd(pts)
    }
    d_data[[g]] <- list(means = means, sds = sds, ns = ns)
  }
  list(d_data = d_data, new_header = new_h)
}

#' Assemble per-time-point summaries from separate means/SDs/Ns files
#'
#' Port of \code{get_data_multi}, used by the limma/vash route where the
#' variance shrinkage has already produced separate means, standard-deviation
#' and replicate-count tables. Columns are aligned to the data header by folded
#' time.
#'
#' @param header Character vector of time labels from the raw data.
#' @param header2 Character vector of time labels from the means/SDs/Ns files.
#' @param means,sds,ns Numeric matrices (series x unique time points) with row
#'   names as series IDs.
#' @param period Period used for folding.
#'
#' @return A list with \code{d_data} and \code{new_header} as in
#'   \code{\link{get_data2}}.
#' @export
get_data_multi <- function(header, header2, means, sds, ns, period) {
  new_h <- .fold_times(header, period)
  h2 <- .fold_times(header2, period)
  seen <- vapply(new_h, function(h) match(h, h2), integer(1))

  ids <- rownames(means)
  d_data <- vector("list", nrow(means)); names(d_data) <- ids
  for (j in seq_len(nrow(means))) {
    m  <- as.numeric(means[j, ])[seen]
    s  <- as.numeric(sds[j, ])[seen]
    nn <- as.numeric(ns[j, ])[seen]
    d_data[[j]] <- list(means = m, sds = s, ns = nn)
  }
  list(d_data = d_data, new_header = new_h)
}
