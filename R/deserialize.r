parse_asii <- function(content) {
    require(lubridate)
    require(stringr)
    require(data.table)
    records <- fread(content, sep=" ")
    tag_hint <- as.character(records[1, -(1:3), with=FALSE])
    tag_names <- str_replace(tag_hint, "=.*", "")
    setnames(records, c("metric", "timestamp", "value", tag_names))
    records <- as.data.frame(records)
    records <- transform(records,
        timestamp = with_tz(Timestamp(as.numeric(timestamp)), Sys.timezone()),
        value = as.numeric(value)
    )
    extract_tag_value <- function(x) str_extract(x, "([^=]+)$")
    tag_data <- lapply(records[,tag_names], extract_tag_value)
    records[,tag_names] <- tag_data
    records <- data.table(records, key=c("timestamp", "metric", tag_names))
    return(records)
}