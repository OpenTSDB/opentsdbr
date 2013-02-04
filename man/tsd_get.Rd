\name{tsd_get}
\alias{tsd_get}
\title{Query a Time Series Daemon (TSD)}
\usage{
  tsd_get(metric, start, tags, end = Timestamp(now()),
    agg = "avg", rate = FALSE, downsample = NULL,
    hostname = "localhost", port = 4242, ...)
}
\arguments{
  \item{metric}{character string}

  \item{start}{POSIXt or subclass}

  \item{tags}{character vector}

  \item{end}{POSIXt or subclass}

  \item{agg}{character string ("sum" or "avg")}

  \item{rate}{logical}

  \item{downsample}{character string}

  \item{hostname}{character string}

  \item{port}{integer}

  \item{...}{further arguments}
}
\value{
  a data.frame
}
\description{
  Query a Time Series Daemon (TSD)
}

