\name{aggregate.tsdb}
\alias{aggregate.tsdb}
\title{aggregate.tsdb}
\usage{
  aggregate.tsdb(x, by = list(), FUN = list(),
    seconds = 60, ..., simplify = TRUE)
}
\arguments{
  \item{by}{(optional) named list of grouping variable(s)}

  \item{FUN}{named list of statistics or functions}

  \item{seconds}{temporal resolution (to which timestamps
  are truncated)}

  \item{...}{further arguments to `[.data.table`}

  \item{simplify}{logical; drop unused columns
  (unimplemented)}
}
\description{
  Aggregate a 'data.tsdb' object
}
\examples{
\dontrun{
require(zoo)
require(lubridate)
data(co2)
x <- ISOdate(1959, 01, 01, 00) + dyears(index(as.zoo(co2)) - 1959)
co2 <- as.tsdb(data.frame(timestamp=x, value=as.numeric(co2)))
aggregate(co2, seconds=60 * 60 * 24 * 365 * 5)
}
}

