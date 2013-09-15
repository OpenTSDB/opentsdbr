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
tsd_get <- function(
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
    txt <- tsd_get_ascii(metric, interval, tags, agg, rate, downsample, hostname, port, verbose)
    data <- parse_ascii(txt)
    if (trim) {
        data <- subset(data, timestamp >= start) # trim excess returned by OpenTSDB
        if (!missing(end)) 
            data <- subset(data, timestamp <= end)
    }
    return(as.tsdb(data))
}

parse_ascii <- function (
  txt
) {
  # Write to temporary file, then read back (workaround for bug in fread())
  tempfn <- tempfile()
  cat(txt, file=tempfn)
  data <- read.tsdb(tempfn, verbose=verbose)
  file.remove(tempfn)
  return(data)
}

tsd_get_ascii <- function(
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
    params <- tsd_query_params(metric, interval, tags, agg, rate, downsample)
    url <- sprintf("http://%s:%s/q", hostname, port)
    elapsed <- system.time(response <- GET(url, query=params))[3]
    if (verbose) {
        message(format(elapsed, digits=3), "s to fetch ", URLdecode(response$url))
    }
    if (response$status_code != '200') {
        warning("Response code ", response$status_code)
        warning("URL: ", response$url)
        stop()
    }
    txt <- content(response, as="text")
    attr(txt, "url") <- response$url
    return(txt)
}

tsd_query_params <- function(
    metric,
    interval,
    tags = NULL,
    agg = "avg",
    rate = FALSE,
    downsample = NULL,
    ...
) {
    require(stringr)
    m_parts <- list(agg)
    if (!is.null(downsample))
        m_parts <- c(m_parts, downsample)
    if (rate)
        m_parts <- c(m_parts, "rate")
    m_parts <- c(m_parts, metric)
    m <- paste(m_parts, collapse=":")
    if (!is.null(tags)) {
        m <- str_c(m, "{", str_c(apply(cbind(names(tags), tags), 1, str_c, collapse="="), collapse=","), "}")
    }
    start <- interval@start
    end <- interval@start + interval@.Data
    params <- list(start=format_local(Timestamp(start)), m=m)
    if (!missing(end)) {
        params <- c(params, end=format_local(Timestamp(end)))
    }
    params <- c(params, ascii="")
    return(params)
}