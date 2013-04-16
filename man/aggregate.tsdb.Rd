\name{aggregate.tsdb}
\alias{aggregate.tsdb}
\title{aggregate.tsdb}
\usage{
  aggregate.tsdb(x, by = list(),
    FUN = list(mean = mean(value, na.rm = TRUE), sd = sd(value, na.rm = TRUE), n = length(value, na.rm = TRUE)),
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
}
}

