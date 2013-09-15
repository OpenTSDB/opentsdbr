\name{read.tsdb}
\alias{read.tsdb}
\title{read.tsdb}
\usage{
  read.tsdb(file, with_tz = "UTC", verbose = FALSE)
}
\arguments{
  \item{file}{file (must be compatible with
  data.table::fread)}

  \item{verbose}{logical}
}
\description{
  Reads a file in OpenTSDB ASCII format. The returned
  object inherits from data.table.
}

