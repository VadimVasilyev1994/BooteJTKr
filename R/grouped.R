#' Run BooteJTK independently within each group (e.g. organ/tissue)
#'
#' Wrapper for multi-group designs (multiple organs, tissues, genotypes, ...)
#' where replicates should be folded \emph{within} a group but never pooled
#' across groups. Columns are partitioned by \code{group}; each group is then run
#' as a self-contained BooteJTK analysis on its own columns. This scopes the
#' replicate folding, the empirical-Bayes variance prior, the Gaussian null and
#' the Benjamini-Hochberg correction to each group, which is the statistically
#' appropriate unit. Groups may have different time designs and different
#' replicate counts.
#'
#' @param mat Numeric matrix (series x all columns), rows named by series ID.
#' @param header Character vector of time labels, one per column of \code{mat}.
#' @param group Vector (one per column of \code{mat}) identifying each column's
#'   group, e.g. organ.
#' @param periods,phases,widths Numeric search grids.
#' @param size Number of bootstraps.
#' @param n_null Number of null series per group (default 1000).
#' @param variance Variance route, \code{"ebayes"} (default) or \code{"none"}.
#' @param waveform Waveform shape (default \code{"cosine"}).
#' @param seed Optional integer seed.
#' @param shared_null If \code{TRUE} and all groups share an identical folded
#'   time design, score one null and reuse it for every group so p-values are
#'   directly comparable across groups. Defaults to \code{FALSE} (a matched null
#'   per group).
#'
#' @return A data frame: the per-group BooteJTK results row-bound together, with
#'   a leading \code{Group} column. \code{GammaBH} is corrected within each group.
#' @export
run_booteJTK_by_group <- function(mat, header, group, periods, phases, widths,
                                  size, n_null = 1000,
                                  variance = c("ebayes", "none"),
                                  waveform = "cosine", seed = NULL,
                                  shared_null = FALSE) {
  variance <- match.arg(variance)
  if (length(header) != ncol(mat)) stop("length(header) must equal ncol(mat)")
  if (length(group)  != ncol(mat)) stop("length(group) must equal ncol(mat)")
  if (!is.null(seed)) set.seed(seed)
  group <- as.factor(group)
  levs <- levels(group)

  fold1 <- function(h) as.numeric(sub("^(ZT|CT)", "", h)) %% as.numeric(periods[1])
  design_of <- function(cols) paste(sort(fold1(header[cols])), collapse = ",")
  designs <- vapply(levs, function(lv) design_of(which(group == lv)), character(1))

  score_null <- function(sub_h) {
    null_mat <- matrix(stats::rnorm(n_null * length(sub_h)), nrow = n_null,
                       dimnames = list(paste0("wn", seq_len(n_null)), sub_h))
    boote_jtk(null_mat, sub_h, periods, phases, widths, size,
              waveform = waveform, variance = variance)$TauMean
  }

  shared_taus <- NULL
  if (shared_null) {
    if (length(unique(designs)) != 1L)
      stop("shared_null = TRUE requires an identical folded time design in every group; ",
           "found: ", paste(unique(designs), collapse = " | "))
    shared_taus <- score_null(header[which(group == levs[1])])
  }

  res <- lapply(levs, function(lv) {
    cols <- which(group == lv)
    sub_h <- header[cols]
    sub_mat <- mat[, cols, drop = FALSE]
    scores <- boote_jtk(sub_mat, sub_h, periods, phases, widths, size,
                        waveform = waveform, variance = variance)
    null_taus <- if (shared_null) shared_taus else score_null(sub_h)
    out <- calc_p(scores, null_taus)          # BH within this group
    cbind(Group = lv, out, stringsAsFactors = FALSE)
  })
  do.call(rbind, res)
}
