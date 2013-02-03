Timestamp <- function(x, tz="UTC", origin="1970-01-01 00:00:00", ...) {
	if (is.numeric(x)) {
		x <- as.POSIXct(x, tz=tz, origin=origin)
	} else if (inherits(x, "POSIXt")) {
		x <- as.POSIXct(x)
	}
	class(x) <- c('Timestamp', class(x))
	return(x)
}

format_iso8601 <- function(x, tz="", ...) {
	format.POSIXct(x, format="%Y-%m-%dT%H:%M:%S%z", tz=tz, usetz=FALSE)
}

format_tsdb <- function(x, tz="", usetz=FALSE, ...) {
	format.POSIXct(x, format="%Y/%m/%d-%H:%M:%S", tz=tz, usetz=FALSE)
}

format_default <- function(x, tz="", ...) {
	format.POSIXct(x, format="%Y-%m-%d %H:%M:%S %Z", tz=tz, usetz=FALSE)
}

format.Timestamp <- format_default
