% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/process.R
\name{ncms}
\alias{ncms}
\title{Reads and merges all comexstat files with information about  NCM}
\usage{
ncms()
}
\value{
data.frame/tibble
}
\description{
Reads and merges all comexstat files with information about  NCM
}
\details{
reads the following files:  ncm, ncm_cgce, ncm_cuci, ncm_isic, ncm_unidade then joins them into a single tibble
}
\examples{
ncms()
}
