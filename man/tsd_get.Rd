\name{tsd_get}
\alias{tsd_get}
\title{Query a Time Series Daemon (TSD)}
\usage{
  tsd_get(metric, start, end, tags, agg = "avg",
    rate = FALSE, downsample = NULL,
    hostname = "localhost", port = 4242, verbose = FALSE,
    trim = FALSE, ...)
}
\arguments{
  \item{metric}{character string}

  \item{start}{POSIXt or subclass}

  \item{end}{POSIXt or subclass}

  \item{tags}{character vector}

  \item{agg}{character string ("sum" or "avg")}

  \item{rate}{logical}

  \item{downsample}{character string (example: "1h-avg")}

  \item{hostname}{character string}

  \item{port}{integer}

  \item{verbose}{logical}

  \item{trim}{logical}

  \item{...}{further arguments}
}
\value{
  a data.frame
}
\description{
  Query a Time Series Daemon (TSD)
}

