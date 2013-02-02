\name{tsd_get}
\alias{tsd_get}
\title{Query a Time Series Daemon (TSD)}
\usage{
  tsd_get(metric, start, tags, end = Timestamp(now()),
    downsample = "1m-avg", hostname = "localhost",
    port = 4242, ...)
}
\arguments{
  \item{metric}{character string}

  \item{start}{POSIXt or subclass}

  \item{tags}{character vector}

  \item{end}{POSIXt or subclass}

  \item{downsample}{character string}

  \item{port}{integer}

  \item{...}{further arguments}
}
\value{
  a data.table
}
\description{
  Query a Time Series Daemon (TSD)
}

