% Generated manually; regenerate with roxygen2 via devtools::document().
\name{read_in_list}
\alias{read_in_list}
\title{Read a single-column list file}
\usage{
read_in_list(fn)
}
\arguments{
\item{fn}{Path to a file with one value per line.}
}
\value{
A character vector of the lines.
}
\description{
Reads a file with one value per line, dropping blank lines.
}
