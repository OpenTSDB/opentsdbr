#' Query a Time Series Daemon (TSD)
#'
#' @param   metric      character string
#' @param   start       POSIXt or subclass
#' @param   tags        character vector
#' @param   end         POSIXt or subclass
#' @param   agg         character string ("sum" or "avg")
#' @param   rate        logical
#' @param   downsample  character string (ex: "1h-avg")
#' @param   hostname    character string
#' @param   port        integer
#' @param   verbose     logical
#' @param   ...         further arguments
#' @return              a data.frame
#' @export
tsd_get <- function(
    metric,
    start,
    tags,
    end,
    agg = "avg",
    rate = FALSE,
    downsample = NULL,
    hostname = 'localhost', 
    port = 4242, 
    verbose = FALSE,
    ...
) { 
    require(stringr)
    require(httr)
    url <- sprintf("http://%s:%d/q", hostname, port)
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
    query <- list(start=format_tsdb(Timestamp(start)), m=m)
    if (!missing(end)) {
        query <- c(query, end=format_tsdb(Timestamp(end)))
    }
    query <- c(query, ascii="")
    time_to_query <- system.time(response <- GET(url, query=query))[3]
    if (verbose) message(format(time_to_query, digits=3), "s to fetch ", URLdecode(response$url))
    stopifnot(response$status_code == '200')
    time_to_deserialize <- system.time({
        txt <- content(response, as="text")
        deserialized <- deserialize_content(txt, tags=tags)
        windowed <- subset(deserialized, timestamp >= start & timestamp <= end) # trim excess
    })[3]
    if (verbose) message(format(time_to_deserialize, digits=3), "s to deserialize ", nrow(windowed), " datapoints")
    return(windowed)
}