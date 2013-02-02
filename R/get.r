parse_tags <- function(tag_strings, tag_keys) {	
	require(stringr)
	pattern_for <- function(key) str_c(key, "=([^ ]+)", collapse="")
	tag_matrix <- sapply(tag_keys, function(key) str_match(tag_strings, pattern_for(key))[,-1])
	as.data.frame(tag_matrix)
}

parse_metrics <- function(metric_matrix) {
	require(lubridate)
	with_utc <- data.frame(
		metric = metric_matrix[,1],
		timestamp = Timestamp(as.numeric(metric_matrix[,2])),
		value = as.numeric(metric_matrix[,3])
	)
	transform(with_utc, timestamp=with_tz(timestamp, Sys.timezone()))
}

parse_records <- function(records, tag_keys) {
	require(stringr)
	parts <- str_split_fixed(records, " ", n=4)
	metric_data <- parse_metrics(parts[,1:3])
	if (missing(tag_keys)) {
		return(metric_data)
	} else {
		tag_data <- parse_tags(parts[,4], tag_keys)
		return(cbind(metric_data, tag_data))
	}
}

parse_content <- function(content, tags) {
	require(stringr)
	cleaned <- str_trim(content)
	records <- unlist(str_split(cleaned, "\n"))
	parse_records(records, tag_keys=tags)
}

#' Query a Time Series Daemon (TSD)
#'
#' @param metric		character string
#' @param start			POSIXt or subclass
#' @param tags			character vector
#' @param end			POSIXt or subclass
#' @param downsample	character string
#' @param port			integer
#' @param ...			further arguments
#' @return				a data.table
#' @export
tsd_get <- function(
	metric,
	start,
	tags,
	end = Timestamp(now()),
	downsample = "1m-avg",
	hostname = 'localhost', 
	port = 4242, 
	...
) {	
	require(data.table)
	require(stringr)
	require(httr)
	url <- sprintf("http://%s:%d/q", hostname, port)
	m <- str_c("avg", ":", metric)
	if (!missing(downsample))
		m <- str_c(m, downsample, ":")
	if (!missing(tags)) {
		mt <- cbind(names(tags), tags)
		str_c(apply(mt, 1, str_c, collapse="="), collapse=" ")
		m <- str_c(m, "{", str_c(apply(cbind(names(tags), tags), 1, str_c, collapse="="), collapse=" "), "}")
	}
	query <- list(m=m, ascii="")
	if (!is.character(start)) 
		start <- Timestamp(start)
	query <- c(query, start=format_tsdb(start, usetz=FALSE))
	if (!missing(end)) {
		if (!is.character(end)) 
			end <- Timestamp(end)
		query <- c(query, end=format_tsdb(end, usetz=FALSE))
	}
	response <- GET(url, query=query)
	message("url: ", response$url)
	stopifnot(response$status_code == '200')
	txt <- content(response, as="text")
	df <- parse_content(txt, tags=tags)
	df <- subset(df, timestamp >= start & timestamp <= end)	# trim excess
	return(df)
}