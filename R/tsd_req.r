#' Query a Time Series Daemon (TSD)
#'
#' @param   metric      character string
#' @param   interval    see \link{lubridate::interval}
#' @param   tags        character vector
#' @param   agg         character string ("sum" or "avg")
#' @param   rate        logical
#' @param   downsample  character string (example: "1h-avg")
#' @param   hostname    character string
#' @param   port        integer
#' @param   verbose     logical
#' @param   trim        logical
#' @param   ...         further arguments
#' 
#' @return              data.table keyed by "timestamp"
#' 
#' @export
tsd_req <- function(
  metric,
  interval,
  tags = NULL,
  agg = "avg",
  rate = FALSE,
  downsample = NULL,
  hostname = 'localhost', 
  port = 4242, 
  verbose = FALSE,
  trim = FALSE,
  ...
) { 
  require(data.table)
  require(lubridate)
  stopifnot(is.interval(interval))
  txt <- tsd_request(metric, interval, tags, agg, rate, downsample, hostname, port, verbose)
  data <- parse_json_response(txt)
  if (trim) {
    data <- subset(data, timestamp >= start) # trim excess returned by OpenTSDB
    if (!missing(end)) 
      data <- subset(data, timestamp <= end)
  }
  return(as.tsdb(data))
}

parse_json_response <- function (
  txt
) {
  # Write to temporary file, then read back (workaround for bug in fread())
  tempfn <- tempfile()
  cat(txt, file=tempfn)
  data <- read.tsdb_json(tempfn, verbose=verbose)
  file.remove(tempfn)
  return(data)
}

tsd_request <- function(
  metric,
  interval,
  tags = NULL,
  agg = "avg",
  rate = FALSE,
  downsample = NULL,
  hostname = 'localhost', 
  port = 4242, 
  verbose = FALSE,
  ...
) { 
  require(httr)
  body <- tsd_query_body(metric, interval, tags, agg, rate, downsample)
  url <- sprintf("http://%s:%s/api/query", hostname, port)
  elapsed <- system.time(response <- POST(url, body=body, encode=c("json")))[3]
  if (verbose) {
    message(format(elapsed, digits=3), "s to fetch ", URLdecode(response$url))
  }
  if (response$status_code != '200') {
    warning("Response code ", response$status_code)
    warning("Response msg ", response)
    warning("URL: ", response$url)
    stop()
  }
  txt <- content(response, as="text")
  attr(txt, "url") <- response$url
  return(txt)
}

tsd_query_body <- function(
  metric,
  interval,
  tags = NULL,
  agg = "avg",
  rate = FALSE,
  downsample = NULL,
  ...
) {
  require(stringr)
  start <- as.numeric(interval@start) * 1000
  params <- c('{', '"start":', start)
  end <- interval@start + interval@.Data
  if (!missing(end)) {
    params <- c(params, ',"end":', as.numeric(end) * 1000)
  }
  params <- c(params, ',"queries":[{')
  params <- c(params, '"metric":"', metric, '"')
  params <- c(params, ',"aggregator":"', agg, '"')
  if (rate)
    params <- c(params, ',"rate":true')
  if (!is.null(downsample))
    params <- c(params, ',"downsample":"', downsample, '"')
  if (!is.null(tags)) {
    params <- c(params, ',"tags":', str_c("{", str_c(apply(cbind('"', names(tags), '":"', tags, '"'), 1, str_c, collapse=""), collapse=","), "}"))
  }
  params <- c(params, '}]')
  params <- c(params, '}')
  return(paste(params, collapse=''))
}