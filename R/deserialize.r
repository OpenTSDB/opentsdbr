deserialize_tags <- function(tag_strings, tag_keys) { 
    require(stringr)
    pattern_for <- function(key) str_c(key, "=([^ ]+)", collapse="")
    tag_matrix <- sapply(tag_keys, function(key) str_match(tag_strings, pattern_for(key))[,-1])
    as.data.frame(tag_matrix)
}

deserialize_metrics <- function(metric_matrix) {
    require(lubridate)
    with_utc <- data.frame(
        metric = metric_matrix[,1],
        timestamp = Timestamp(as.numeric(metric_matrix[,2])),
        value = as.numeric(metric_matrix[,3])
    )
    transform(with_utc, timestamp=with_tz(timestamp, Sys.timezone()))
}

deserialize_records <- function(records, tag_keys) {
    require(stringr)
    parts <- str_split_fixed(records, " ", n=4)
    metric_data <- deserialize_metrics(parts[,1:3])
    if (missing(tag_keys)) {
        return(metric_data)
    } else {
        tag_data <- deserialize_tags(parts[,4], tag_keys)
        return(cbind(metric_data, tag_data))
    }
}

deserialize_content <- function(content, tags) {
    require(stringr)
    cleaned <- str_trim(content)
    records <- unlist(str_split(cleaned, "\n"))
    deserialize_records(records, tag_keys=tags)
}