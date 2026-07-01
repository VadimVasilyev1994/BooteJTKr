#' @keywords internal
.OUT_COLS <- c("ID", "Waveform", "PeriodMean", "PeriodStdDev",
               "PhaseMean", "PhaseStdDev", "NadirMean", "NadirStdDev",
               "Mean", "Std_Dev", "Max", "Min", "Max_Amp", "FC", "IQR_FC",
               "NumBoots", "TauMean", "TauStdDev")

#' Run the BooteJTK engine on prepared data
#'
#' Core engine shared by the real-data and null runs. For each series it
#' bootstraps the per-time-point summaries, matches every distinct ordering to
#' the reference bank, and assembles the BooteJTK output row. Results are sorted
#' by descending \code{abs(TauMean)}, matching the original.
#'
#' @param d_data Named list of \code{list(means, sds, ns)} per series.
#' @param new_header Numeric folded time points.
#' @param triples Matrix of (period, phase, width) rows.
#' @param refs Reference waveforms from \code{\link{make_references}}.
#' @param size Number of bootstraps.
#' @param raw_mat Numeric matrix of raw values (series x time points) for the
#'   descriptive columns; rows named by series ID.
#' @param waveform Waveform label recorded in the output (default
#'   \code{"cosine"}).
#'
#' @return A data frame with the standard BooteJTK columns.
#' @export
boote_jtk_engine <- function(d_data, new_header, triples, refs, size,
                             raw_mat, waveform = "cosine") {
  ids <- names(d_data)
  rows <- vector("list", length(ids))
  for (gi in seq_along(ids)) {
    id <- ids[gi]
    dd <- d_data[[id]]
    ol <- order_probs(dd$means, dd$sds, dd$ns, size)
    sp <- get_stat_probs(ol, new_header, triples, refs, size)
    sstat <- series_stats(raw_mat[id, ])
    rows[[gi]] <- data.frame(
      ID = id, Waveform = waveform,
      PeriodMean = sp$out1[1], PeriodStdDev = sp$out1[2],
      PhaseMean = sp$out1[3], PhaseStdDev = sp$out1[4],
      NadirMean = sp$out1[5], NadirStdDev = sp$out1[6],
      Mean = sstat["Mean"], Std_Dev = sstat["Std_Dev"],
      Max = sstat["Max"], Min = sstat["Min"], Max_Amp = sstat["Max_Amp"],
      FC = sstat["FC"], IQR_FC = sstat["IQR_FC"],
      NumBoots = size,
      TauMean = sp$out2[1], TauStdDev = sp$out2[2],
      stringsAsFactors = FALSE, row.names = NULL)
  }
  res <- do.call(rbind, rows)
  res[order(-abs(res$TauMean)), , drop = FALSE]
}

#' @keywords internal
.prep_variance <- function(header, mat, period, variance, means, sds, ns,
                           null_ids) {
  if (variance == "precomputed") {
    if (is.null(means) || is.null(sds) || is.null(ns))
      stop("variance = 'precomputed' requires means, sds and ns matrices")
    gd <- get_data_multi(header, colnames(means), means, sds, ns, period)
    return(gd)
  }
  gd <- get_data2(header, mat, period)
  if (variance == "ebayes") {
    d_null <- if (!is.null(null_ids)) {
      sub <- gd$d_data[intersect(null_ids, names(gd$d_data))]
      sub
    } else list()
    gd$d_data <- eBayes(gd$d_data, d_null)
  }
  gd
}

#' Run BooteJTK on a data matrix
#'
#' Convenience wrapper that prepares per-time-point variance estimates, builds
#' the reference bank and runs the engine.
#'
#' @param mat Numeric matrix (series x time points), rows named by series ID.
#' @param header Character vector of time labels (one per column of \code{mat}).
#' @param periods,phases,widths Numeric search grids.
#' @param size Number of bootstraps.
#' @param waveform Waveform shape (default \code{"cosine"}).
#' @param variance One of \code{"ebayes"} (internal empirical-Bayes shrinkage,
#'   the default), \code{"none"} (use raw per-time-point SDs), or
#'   \code{"precomputed"} (supply \code{means}/\code{sds}/\code{ns}, e.g. from
#'   the limma/vash route).
#' @param means,sds,ns Optional matrices for \code{variance = "precomputed"}.
#' @param null_ids Optional character vector of series IDs used to estimate the
#'   empirical-Bayes prior.
#' @param seed Optional integer seed for reproducibility.
#'
#' @return A data frame of BooteJTK results.
#' @export
boote_jtk <- function(mat, header, periods, phases, widths, size,
                      waveform = "cosine", variance = c("ebayes", "none", "precomputed"),
                      means = NULL, sds = NULL, ns = NULL,
                      null_ids = NULL, seed = NULL) {
  variance <- match.arg(variance)
  if (!is.null(seed)) set.seed(seed)
  period <- as.numeric(periods[1])
  gd <- .prep_variance(header, mat, period, variance, means, sds, ns, null_ids)
  triples <- get_waveform_list(periods, phases, widths)
  refs <- make_references(gd$new_header, triples, waveform)
  boote_jtk_engine(gd$d_data, gd$new_header, triples, refs, size, mat, waveform)
}

#' Full BooteJTK + p-value pipeline
#'
#' End-to-end port of \code{BooteJTK-CalcP.py}: runs BooteJTK on the data,
#' generates a Gaussian null with the same header, runs BooteJTK on the null,
#' and assigns gamma and empirical p-values. Optionally writes output files
#' mirroring the original naming scheme.
#'
#' @param file Path to a BooteJTK input file (alternative to \code{mat}/\code{header}).
#' @param mat,header Data matrix and time labels (alternative to \code{file}).
#' @param periods,phases,widths Numeric search grids.
#' @param size Number of bootstraps.
#' @param prefix String inserted into output filenames.
#' @param n_null Number of null series to generate (default 1000).
#' @param variance Variance route; see \code{\link{boote_jtk}}.
#' @param means,sds,ns Optional precomputed variance matrices.
#' @param null_ids Optional IDs for the empirical-Bayes prior.
#' @param waveform Waveform shape (default \code{"cosine"}).
#' @param seed Optional integer seed.
#' @param out_dir Optional directory; if given, results are written to disk.
#'
#' @return A data frame: the BooteJTK results with \code{empP}, \code{GammaP}
#'   and \code{GammaBH} columns, sorted by descending \code{abs(TauMean)}.
#' @export
run_booteJTK <- function(file = NULL, mat = NULL, header = NULL,
                         periods, phases, widths, size,
                         prefix = "", n_null = 1000,
                         variance = c("ebayes", "none", "precomputed"),
                         means = NULL, sds = NULL, ns = NULL,
                         null_ids = NULL, waveform = "cosine",
                         seed = NULL, out_dir = NULL) {
  variance <- match.arg(variance)
  if (!is.null(file)) {
    d <- read_in(file)
    mat <- d$mat; header <- d$header
  }
  if (is.null(mat) || is.null(header)) stop("Provide either 'file' or 'mat' + 'header'")
  if (!is.null(seed)) set.seed(seed)

  message("Running BooteJTK on data (", nrow(mat), " series)")
  res <- boote_jtk(mat, header, periods, phases, widths, size, waveform,
                   variance, means, sds, ns, null_ids)

  message("Generating and scoring ", n_null, " null series")
  null_mat <- matrix(stats::rnorm(n_null * length(header)),
                     nrow = n_null, ncol = length(header),
                     dimnames = list(paste0("wnoise_", seq_len(n_null) - 1), header))
  null_res <- boote_jtk(null_mat, header, periods, phases, widths, size, waveform,
                        variance = if (variance == "precomputed") "ebayes" else variance)

  res <- calc_p(res, as.numeric(null_res$TauMean))

  if (!is.null(out_dir)) {
    dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
    endstr <- sprintf("_%s_boot%d-rep.txt", prefix, as.integer(size))
    base <- if (!is.null(file)) sub("\\.txt$", "", basename(file)) else "BooteJTK"
    fn_out <- file.path(out_dir, paste0(base, endstr))
    utils::write.table(res, sub("\\.txt$", "_GammaP.txt", fn_out),
                       sep = "\t", quote = FALSE, row.names = FALSE, na = "nan")
    attr(res, "outfile") <- sub("\\.txt$", "_GammaP.txt", fn_out)
  }
  res
}
