# BooteJTKr

A **pure-R** reimplementation of [BooteJTK](https://github.com/alanlhutchison/BooteJTK)
(originally Python + Cython), a bootstrapped expansion of empirical JTK_CYCLE
(eJTK) for detecting rhythmic signals in time-series data.

The core engine depends on **base R only** (no Bioconductor, no compiled code).
An optional limma/voom + vash variance-shrinkage backend is provided but not
required.

## Install

```r
# from GitHub
# install.packages("remotes")
remotes::install_github("VadimVasilyev1994/BooteJTKr")
library(BooteJTKr)
```

Or from a local clone:

```r
install.packages("path/to/BooteJTKr", repos = NULL, type = "source")
```

## Quick start

```r
f <- system.file("extdata", "TestInput4.txt", package = "BooteJTKr")

res <- run_booteJTK(
  file    = f,
  periods = 24,                 # period(s) to search
  phases  = seq(0, 22, by = 2), # candidate phases
  widths  = seq(2, 22, by = 2), # candidate asymmetries (widths)
  size    = 25,                 # number of bootstraps
  n_null  = 1000,               # Gaussian null series for the gamma fit
  variance = "ebayes",          # internal empirical-Bayes shrinkage (default)
  seed    = 1
)

head(res[, c("ID", "PhaseMean", "TauMean", "empP", "GammaP", "GammaBH")])
```

`run_booteJTK()` returns the result table sorted by descending `abs(TauMean)`,
with `empP`, `GammaP` and `GammaBH` (Benjamini-Hochberg) columns. Pass
`out_dir =` to also write a `*_GammaP.txt` file.

## Input format

Tab-delimited. The header row starts with `#` or `ID`, followed by time-point
labels (`ZT0`, `CT4`, or bare numbers). Each subsequent row is a series ID
followed by one value per time point; missing values are `NA`.

## Variance routes (`variance =`)

* `"ebayes"` (default) — self-contained Smyth (2004) empirical-Bayes shrinkage
  of per-time-point SDs. No external packages.
* `"none"` — use the raw per-time-point SDs.
* `"precomputed"` — supply `means`, `sds`, `ns` matrices, e.g. from
  `variance_limma_vash()`. That backend needs `limma` (Bioconductor) and
  `vashr` (GitHub: mengyin/vashr), and is only usable where those install.

## Relationship to the original

Every statistical primitive (Kendall tau-b, circular mean/SD, the
empirical-Bayes `polygamma` solve, and the 3-parameter gamma fit) was validated
against the exact SciPy/NumPy functions the original calls. Deterministic
outputs (the descriptive columns) are bit-identical; bootstrap-driven columns
match in distribution (set `seed` for reproducibility within R).

The original's optional constrained gamma refit (the `mpfit`/`arbfit` code) is
disabled by default in the Python pipeline and is not ported.

## License

MIT (the original BooteJTK is also MIT).
