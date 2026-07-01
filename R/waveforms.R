#' Generate an asymmetric base reference waveform
#'
#' Reproduces \code{generate_base_reference} from the original BooteJTK Cython
#' module. Given the (period-folded) time points in \code{header}, a period,
#' phase and width/asymmetry, it returns the waveform sampled at those times.
#' The \code{cosine} form is an asymmetric cosine whose rise occupies a fraction
#' of the cycle set by \code{width}; \code{trough}, \code{impulse} and
#' \code{step} reproduce the other shapes offered by the original.
#'
#' @param header Numeric vector of (folded) time points.
#' @param waveform One of \code{"cosine"}, \code{"trough"}, \code{"impulse"},
#'   \code{"step"}.
#' @param period Period of the waveform.
#' @param phase Phase (peak location) of the waveform.
#' @param width Width/asymmetry parameter.
#'
#' @return Numeric vector of waveform values, one per element of \code{header}.
#' @export
generate_base_reference <- function(header, waveform = "cosine",
                                     period = 24, phase = 0, width = 12) {
  ZTs <- as.numeric(header)
  coef <- 2 * pi / period
  w <- width * coef
  tpoints <- (ZTs - phase) * coef

  cosine <- function(x, w) {
    x <- x %% (2 * pi)
    w <- w %% (2 * pi)
    if (x <= w) cos(x / (w / pi))
    else cos((x + 2 * (pi - w)) * pi / (2 * pi - w))
  }
  trough <- function(x, w) {
    x <- x %% (2 * pi)
    w <- w %% (2 * pi)
    if (x <= w) 1 + -x / w
    else (x - w) / (2 * pi - w)
  }
  impulse <- function(x, w) {
    w <- 3 * pi / 4
    x <- x %% (2 * pi)
    d <- min(x, abs(2 * pi - x))
    max(-2 * d / w + 1, 0)
  }
  step <- function(x, w) {
    w <- pi
    x <- x %% (2 * pi)
    if (x < w) 1 else 0
  }

  f_wav <- switch(waveform,
                  cosine = cosine, trough = trough,
                  impulse = impulse, step = step,
                  stop("Unknown waveform: ", waveform))
  vapply(tpoints, function(tp) f_wav(tp, w), numeric(1))
}

#' Build the list of (period, phase, width) reference triples
#'
#' Faithful port of \code{get_waveform_list}. For each period it scans the
#' phase * width grid, computes the nadir as \code{(phase + width) \%\% period},
#' and de-duplicates phase/nadir mirror pairs exactly as the original does.
#'
#' @param periods,phases,widths Numeric vectors of search values.
#'
#' @return A numeric matrix with three columns (period, phase, width).
#' @export
get_waveform_list <- function(periods, phases, widths) {
  lper <- length(periods); lpha <- length(phases); lwid <- length(widths)
  n_keep <- as.integer(lper * lpha * lwid / 2)
  triples <- matrix(0, nrow = n_keep, ncol = 3)

  for (ip in seq_along(periods)) {
    period <- periods[ip]
    j <- 0L
    pairs <- replicate(as.integer(lpha * lwid / 2), c(0, 0), simplify = FALSE)
    for (phase in phases) {
      for (width in widths) {
        nadir <- (phase + width) %% period
        pair <- c(nadir, phase)
        already <- any(vapply(pairs, function(p) identical(as.numeric(p), as.numeric(pair)), logical(1)))
        if (!already) {
          j <- j + 1L
          pairs[[j]] <- c(phase, nadir)
          idx <- (ip - 1L) * lper + j
          triples[idx, ] <- c(period, phase, width)
        }
      }
    }
  }
  triples
}

#' Pre-compute reference waveforms for all triples
#'
#' Port of \code{make_references}: returns a list of waveforms keyed by triple.
#'
#' @param header Numeric vector of (folded) time points.
#' @param triples Matrix of (period, phase, width) rows, e.g. from
#'   \code{\link{get_waveform_list}}.
#' @param waveform Waveform shape (default \code{"cosine"}).
#'
#' @return A list with one numeric reference vector per row of \code{triples};
#'   \code{attr(., "keys")} holds the matrix of triples for lookup.
#' @export
make_references <- function(header, triples, waveform = "cosine") {
  refs <- lapply(seq_len(nrow(triples)), function(i) {
    generate_base_reference(header, waveform,
                            triples[i, 1], triples[i, 2], triples[i, 3])
  })
  attr(refs, "keys") <- triples
  refs
}
