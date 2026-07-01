# BooteJTKr 0.1.0

* Initial pure-R port of BooteJTK (Python/Cython original by A. L. Hutchison).
* Core engine (bootstrap, Kendall tau-b matching, reference waveforms, circular
  statistics, empirical-Bayes shrinkage, gamma/empirical p-values) uses base R
  only; validated against scipy to machine precision.
* Optional limma/voom + vash variance backend via `variance_limma_vash()`.
