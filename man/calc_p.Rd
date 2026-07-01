% Generated manually; regenerate with roxygen2 via devtools::document().
\name{calc_p}
\alias{calc_p}
\title{Assign gamma and empirical p-values to a BooteJTK result table}
\usage{
calc_p(jtk, null_taus)
}
\arguments{
\item{jtk}{Data frame of BooteJTK results (must contain \code{TauMean}).}
\item{null_taus}{Numeric vector of null \code{TauMean} values.}
}
\value{
\code{jtk} with added columns \code{empP}, \code{GammaP}, \code{GammaBH}.
}
\description{
Port of \code{CalcP.main} for the default path. Fits a gamma to the null \code{TauMean} values, computes gamma and empirical p-values, takes their element-wise minimum as \code{GammaP}, and adds a Benjamini-Hochberg correction.
}
