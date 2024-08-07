% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/comexstat2.R
\name{comex_check}
\alias{comex_check}
\title{Check Consistency Between Comex Data and Conference Files}
\usage{
comex_check(data)
}
\arguments{
\item{data}{Comexstat dataset to be checked.}
}
\value{
No direct return value. The function prints a message indicating whether the check passed or if there are mismatches between the data and conference files. If mismatches are found, a table displaying the discrepancies is printed and an error is raised.
}
\description{
This function verifies the consistency between downloaded Comex data and the corresponding conference files provided by the official source (MDIC). It checks if the aggregated totals for specific columns match between the two sources.
}
\details{
This function performs the following checks:
\enumerate{
\item \strong{Aggregation:} Aggregates the Comex data by \code{year} and \code{direction} and calculates sums for relevant columns.
\item \strong{Comparison:} Compares the aggregated sums from the Comex data with the totals in the conference files.
\item \strong{Mismatch Reporting:} If any mismatches are found, a table highlighting the differences is printed to the console.
\item \strong{Error Handling:} If mismatches exist, the function raises an error to stop further analysis.
}
}
