\name{tsd_req}
\alias{tsd_req}
\title{Query a Time Series Daemon (TSD)}
\usage{
  tsd_get(metric, interval, tags = NULL, agg = "avg",
    rate = FALSE, downsample = NULL,
    hostname = "localhost", port = 4242, verbose = FALSE,
    trim = FALSE, ...)
}
\arguments{
  \item{metric}{character string}

  \item{interval}{see \link{lubridate::interval}}

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
  data.table keyed by "timestamp"
}
\description{
  Query a Time Series Daemon (TSD)
}

