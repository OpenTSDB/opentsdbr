\name{Timestamp}
\alias{Timestamp}
\title{Timestamps with suitable default formatting and timezone handling}
\usage{
  Timestamp(x, tz = "", origin = "1970-01-01 00:00:00",
    ...)
}
\arguments{
  \item{x}{epoch time, character, or anything else
  convertable via \link{as.POSIXct}}

  \item{tz}{character string (see link{timezones})}

  \item{origin}{character string (see \link{as.POSIXct})}

  \item{...}{further arguments to be passed to or from
  other methods (example: format)}
}
\description{
  Timestamps with suitable default formatting and timezone
  handling
}
\note{
  tz="" is equivalent to tz=Sys.timezone()
}

