% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fct_map.R
\name{calc_risk}
\alias{calc_risk}
\title{calc_risk}
\usage{
calc_risk(I, n, population, scaling_factor = 10/14)
}
\arguments{
\item{I}{Infection rate}

\item{n}{Event size}

\item{population}{Size of population to predict in}

\item{scaling_factor}{Scaling factor, for averaging noisy case data}
}
\value{
Vector of risk values
}
\description{
calc_risk
}
