#' Query a Time Series Daemon (TSD)
#'
#' @param   metric      character string
#' @param   start       POSIXt or subclass
#' @param   end         POSIXt or subclass
#' @param   tags        character vector
#' @param   agg         character string ("sum" or "avg")
#' @param   rate        logical
#' @param   downsample  character string (example: "1h-avg")
#' @param   hostname    character string
#' @param   port        integer
#' @param   verbose     logical
#' @param   trim        logical
#' @param   ...         further arguments
#' @return              a data.frame
#' @export
tsd_get <- function(
    metric,
    start,
    end,
    tags,
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
    txt <- tsd_get_ascii(metric, start, end, tags, agg, rate, downsample, hostname, port, verbose)
    # Write to temporary file, then read back (workaround for bug in fread())
    tempfn <- tempfile()
    cat(txt, file=tempfn)
    data <- read.tsdb(tempfn, verbose=verbose)
    file.remove(tempfn)
    if (trim) {
        data <- subset(data, timestamp >= start) # trim excess returned by OpenTSDB
        if (!missing(end)) 
            data <- subset(data, timestamp <= end)
    }
    return(as.tsdb(data))
}

#' read.tsdb
#' 
#' Reads a file in OpenTSDB ASCII format. The returned object inherits from data.table.
#'
#' @param file      file (must be compatible with data.table::fread)
#' @param verbose   logical
#'
#' @export
read.tsdb <- function(file, with_tz="UTC", verbose=FALSE) {
    require(lubridate)
    require(stringr)
    require(data.table)
    records <- data.table::fread(file, sep=" ")
    tag_hint <- as.character(records[1, -(1:3), with=FALSE])
    tag_names <- str_replace(tag_hint, "=.*", "")
    setnames(records, c("metric", "timestamp", "value", tag_names))
    records <- as.data.frame(records)
    records <- transform(records,
        timestamp = Timestamp(as.numeric(timestamp), tz="UTC"),
        value = as.numeric(value)
    )
    if (with_tz != "UTC") {
        records <- transform(records,
            timestamp = lubridate::with_tz(timestamp, with_tz)
        ) 
    }
    extract_tag_value <- function(x) str_extract(x, "([^=]+)$")
    tag_data <- lapply(records[,tag_names], extract_tag_value)
    records[,tag_names] <- tag_data
    records <- data.table(records, key=c("timestamp", "metric", tag_names))
    return(as.tsdb(records))
}

tsd_get_ascii <- function(
    metric,
    start,
    end,
    tags,
    agg = "avg",
    rate = FALSE,
    downsample = NULL,
    hostname = 'localhost', 
    port = 4242, 
    verbose = FALSE,
    ...
) { 
    require(httr)
    params <- tsd_query_params(metric, start, end, tags, agg, rate, downsample)
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
    start,
    end,
    tags,
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
    if (!missing(tags)) {
        m <- str_c(m, "{", str_c(apply(cbind(names(tags), tags), 1, str_c, collapse="="), collapse=","), "}")
    }
    params <- list(start=format_tsdb(Timestamp(start)), m=m)
    if (!missing(end)) {
        params <- c(params, end=format_tsdb(Timestamp(end)))
    }
    params <- c(params, ascii="")
    return(params)
}