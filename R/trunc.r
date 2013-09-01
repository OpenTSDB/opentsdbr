#' trunc_seconds
#' 
#' Returns a function that truncates POSIXct times to start of nearest interval
#'
#' @param	n 		interval length, in seconds
#' @export
trunc_seconds <- function(n) {
	function(x) as.POSIXct(x - as.numeric(x) %% n)
}