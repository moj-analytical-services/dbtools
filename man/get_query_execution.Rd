% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wrap.R
\name{get_query_execution}
\alias{get_query_execution}
\title{Fetch query execution details.}
\usage{
get_query_execution(query_id)
}
\arguments{
\item{query_id}{Athena query execution ID}
}
\value{
List with the get_query_execution response.
}
\description{
Fetch query execution details.
}
\examples{
`res <- dbtools::get_query_execution(query_id='query-execution-id')`
}
\seealso{
https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/athena.html#Athena.Client.get_query_execution
}
