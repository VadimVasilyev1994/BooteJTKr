% Generated manually; regenerate with roxygen2 via devtools::document().
\name{farctanh}
\alias{farctanh}
\title{Fisher (arctanh) transform with clamping}
\usage{
farctanh(x)
}
\arguments{
\item{x}{A numeric scalar (typically a tau value).}
}
\value{
The clamped arctanh of \code{x}.
}
\description{
Applies \code{atanh} after clamping the input to \eqn{[-0.99, 0.99]}, exactly as the original \code{farctanh} does.
}
\examples{
farctanh(0.5)
}
