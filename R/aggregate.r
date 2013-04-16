#' aggregate.tsdb
#'
#' Aggregate a 'data.tsdb' object
#'
#' @param by		(optional) named list of grouping variable(s)
#' @param FUN		named list of statistics or functions
#' @param seconds	temporal resolution (to which timestamps are truncated)
#' @param ...		further arguments to `[.data.table`
#' @param simplify	logical; drop unused columns (unimplemented)
#'
#' @examples
#' \dontrun{
#' require(zoo)
#' require(lubridate)
#' data(co2)
#' timestamp <- ISOdate(1959, 01, 01, 00) + dyears(index(as.zoo(co2)) - 1959)
#' co2 <- as.tsdb(data.frame(timestamp=timestamp, value=as.numeric(co2)))
#' aggregate(co2, seconds=60 * 60 * 24 * 365 * 5)
#' }
#' @export
aggregate.tsdb <- function(
	x, 
	by = list(), 
	FUN = list(
		mean = mean(value, na.rm=TRUE),
		sd = sd(value, na.rm=TRUE),
		n = length(value, na.rm=TRUE)
	), 
	seconds = 60,
	..., 
	simplify = TRUE
) {
	by <- substitute(by)
	by$timestamp <- quote(trunc_seconds(seconds)(timestamp))
    x[,eval(substitute(FUN)),eval(by),...]
}