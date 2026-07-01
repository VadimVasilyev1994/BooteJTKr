#' BooteJTKr: Bootstrapped empirical JTK_CYCLE in pure R
#'
#' A pure-R reimplementation of BooteJTK. The typical entry point is
#' \code{\link{run_booteJTK}}, which runs the full data + null + p-value
#' pipeline. \code{\link{boote_jtk}} runs the engine on a single matrix without
#' the null/p-value step.
#'
#' @section Pipeline:
#' \enumerate{
#'   \item \code{\link{read_in}} parses the time-series file.
#'   \item \code{\link{get_data2}} folds replicates into per-time-point means,
#'     SDs and counts; \code{\link{eBayes}} optionally moderates the SDs.
#'   \item \code{\link{order_probs}} bootstraps each series into rank-ordering
#'     probabilities.
#'   \item \code{\link{get_waveform_list}} / \code{\link{make_references}} build
#'     the reference waveform bank; \code{\link{get_stat_probs}} matches
#'     orderings to references with \code{\link{kendall_tau}} and summarises tau,
#'     phase, period and nadir.
#'   \item \code{\link{calc_p}} assigns gamma and empirical p-values.
#' }
#'
#' @section Note on reproducibility:
#' Because bootstrapping and tie-breaking use random numbers, output matches the
#' original Python implementation in distribution rather than bit-for-bit; the
#' deterministic descriptive columns are identical. Set \code{seed} for
#' reproducible runs.
#'
#' @keywords internal
"_PACKAGE"
