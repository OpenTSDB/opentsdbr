as.tsdb <- function(data) {
    
    # If it's already a data.tsdb object, then don't do anything
    if (inherits(data, "data.tsdb")) {
        return(data)
    }
    
    # Check for compatible type
    stopifnot(inherits(data, "data.frame"))
    stopifnot("timestamp" %in% names(data))
    
    # If it's not a data.table already, then promote it to a data.table
    if (!inherits(data, "data.table")) {
        data <- data.table(data)
        setkey(data, "timestamp")
    }
    
    # Promote to a data.tsdb object
    class(data) <- c("tsdb", class(data))

    return(data)    
}