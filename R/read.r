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