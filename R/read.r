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
        metric = factor(metric),
        timestamp = Timestamp(as.numeric(timestamp), tz="UTC"),
        value = as.numeric(value)
    )
    if (with_tz != "UTC") {
        records <- transform(records,
            timestamp = lubridate::with_tz(timestamp, with_tz)
        ) 
    }
    extract_tag_value <- function(x) factor(str_extract(x, "([^=]+)$"))
    tag_data <- lapply(records[,tag_names], extract_tag_value)
    records[,tag_names] <- tag_data
    records <- data.table(records, key=c("timestamp", "metric", tag_names))
    return(as.tsdb(records))
}

#' read.tsdb_json
#' 
#' Reads a file in OpenTSDB ASCII format. The returned object inherits from data.table.
#'
#' @param file      file (must be compatible with data.table::fread)
#' @param verbose   logical
#'
#' @export
read.tsdb_json <- function(file, with_tz="UTC", verbose=FALSE) {
  require(lubridate)
  require(stringr)
  require(data.table)
  require(rjson)

  result_df <- NULL

  docs <- fromJSON(file=file, method='C')
  if (length(docs) <= 0) {
    warning("The response doesn't have time series data. Please check the '", file, "' file.")
    stop()
  }

  for (series_index in 1:length(docs)) {
    doc <- docs[[series_index]]

    col_names <- c('metric', 'timestamp', 'value')
    col_types <- c('character', 'double', 'numeric')

    tag_keys <- names(doc$tags)
    tag_vals <- c()
    if (length(tag_keys) > 0) {
      for (i in 1:length(tag_keys)) {
        tag_key <- tag_keys[[i]]
        tag_vals <- c(tag_vals, doc$tags[[i]])
        col_names <- c(col_names, tag_key)
        col_types <- c(col_types, 'character')
      }
    }

    if (is.null(result_df)) {
      result_df <- read.table(text = "", colClasses = col_types, col.names = col_names)
    }

    timestamps <- names(doc$dps)
    for (i in 1:length(timestamps)) {
      timestamp = timestamps[[i]]
      value = doc$dps[timestamp]
      result_df[nrow(result_df) + 1,] <- c(doc$metric, timestamp, value, tag_vals)
    }
  }

  result_df <- transform(result_df, timestamp = Timestamp(as.numeric(timestamp), tz="UTC"), value = as.numeric(value))
  if (with_tz != "UTC") {
    result_df <- transform(result_df, timestamp = lubridate::with_tz(timestamp, with_tz)) 
  }
  return(as.tsdb(result_df))
}