#' Read a BooteJTK time-series file
#'
#' Reads a tab-delimited file whose header row begins with \code{#} or \code{ID}
#' followed by time-point labels (e.g. \code{ZT0}, \code{CT4}, or bare numbers).
#' Remaining rows are a series ID followed by one value per time point; missing
#' values may be \code{NA}.
#'
#' @param fn Path to the input file.
#'
#' @return A list with \code{header} (character vector of time labels),
#'   \code{ids} (character vector of series IDs) and \code{mat} (numeric matrix,
#'   series x time points).
#' @export
read_in <- function(fn) {
  lines <- readLines(fn)
  lines <- lines[nchar(trimws(lines)) > 0]
  header <- NULL
  ids <- character(0)
  rows <- list()
  for (ln in lines) {
    words <- strsplit(trimws(ln), "\\s+")[[1]]
    if (words[1] == "#" || words[1] == "ID") {
      header <- words[-1]
    } else {
      if (is.null(header)) stop("Header must start with '#' or 'ID'")
      ids <- c(ids, words[1])
      vals <- suppressWarnings(as.numeric(words[-1]))
      rows[[length(rows) + 1]] <- vals
    }
  }
  mat <- do.call(rbind, rows)
  rownames(mat) <- ids
  colnames(mat) <- header
  list(header = header, ids = ids, mat = mat)
}

#' Read a single-column list file
#'
#' @param fn Path to a file with one value per line.
#' @return A character vector of the lines.
#' @export
read_in_list <- function(fn) {
  ln <- readLines(fn)
  ln[nchar(trimws(ln)) > 0]
}

#' @keywords internal
.pop_sd <- function(x) {
  x <- x[is.finite(x)]
  n <- length(x)
  if (n == 0) return(NA_real_)
  if (n == 1) return(0)
  sqrt(mean((x - mean(x))^2))
}

#' @keywords internal
.score_at_percentile <- function(x, per) {
  x <- sort(x[is.finite(x)])
  if (length(x) < 5) return(NA_real_)
  i <- floor(per / 100 * length(x))   # 0-based index in the original
  x[i + 1]
}

#' @keywords internal
.IQR_FC <- function(x) {
  qlo <- .score_at_percentile(x, 25)
  qhi <- .score_at_percentile(x, 75)
  if (is.na(qlo) || is.na(qhi)) return(NA_real_)
  if (qhi == 0) return(0)
  if (qlo == 0) return(NA_real_)
  qhi / qlo
}

#' @keywords internal
.FC <- function(x) {
  x[!is.finite(x)] <- 0
  if (length(x) == 0) return(NA_real_)
  mmin <- min(x); mmax <- max(x)
  if (mmin == 0) -10000 else mmax / mmin
}

#' Summary statistics for one raw series
#'
#' Computes the descriptive columns BooteJTK reports for each series (mean,
#' population SD, max, min, amplitude, fold-change and IQR fold-change), using
#' the raw (un-folded) values and ignoring non-finite entries.
#'
#' @param x Numeric vector of raw values for one series.
#'
#' @return A named numeric vector: \code{Mean}, \code{Std_Dev}, \code{Max},
#'   \code{Min}, \code{Max_Amp}, \code{FC}, \code{IQR_FC}.
#' @export
series_stats <- function(x) {
  fin <- x[is.finite(x)]
  if (length(fin) > 0) {
    mmax <- max(fin); mmin <- min(fin); amp <- mmax - mmin
    smean <- mean(fin); sstd <- .pop_sd(fin)
  } else {
    mmax <- mmin <- amp <- smean <- sstd <- NA_real_
  }
  c(Mean = smean, Std_Dev = sstd, Max = mmax, Min = mmin,
    Max_Amp = amp, FC = .FC(x), IQR_FC = .IQR_FC(x))
}
