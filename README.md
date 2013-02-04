opentsdbr
========

This package provides a read-only interface from [R] to [OpenTSDB]. We're using it internally for data analysis on the [BEACON] project at UC Berkeley. It's not optimized, and only uses HTTP, but could serve as a reference implementation (or straw man) for a faster and/or more fully featured API.

Seeking comment!

Install directly from GitHub using devtools:

    if (!require("devtools")) install.packages("devtools")
    library("devtools")
    install_github("opentsdbr", "holstius")

Example usage:

    library(opentsdbr)
    metric <- "SHT15_temp_Celsius"
    start <- ISOdate(2013, 02, 02, 00, tz="America/Los_Angeles")
    tags <- c(site = "*")
    
    # Hit the TSD (defaults to localhost:4242)
    # Optional: pass verbose=TRUE to see url and timings
    result <- tsd_get(metric, start, tags, downsample="10m-avg")
    
    # Return value is a data.frame; data.table shows head and tail
    library(data.table)
    data.table(result)
                     metric           timestamp    value       site
      1: SHT15_temp_Celsius 2013-02-02 00:05:35 26.50858 UHall575AB
      2: SHT15_temp_Celsius 2013-02-02 00:15:37 26.50114 UHall575AB
      3: SHT15_temp_Celsius 2013-02-02 00:25:41 26.78675 UHall575AB
      4: SHT15_temp_Celsius 2013-02-02 00:35:46 26.37500 UHall575AB
      5: SHT15_temp_Celsius 2013-02-02 00:45:50 26.67035 UHall575AB
     ---                                                           
    240: SHT15_temp_Celsius 2013-02-03 16:07:33 30.83301 UHall575AB
    241: SHT15_temp_Celsius 2013-02-03 16:17:35 30.60807 UHall575AB
    242: SHT15_temp_Celsius 2013-02-03 16:27:39 31.02158 UHall575AB
    243: SHT15_temp_Celsius 2013-02-03 16:37:41 30.87239 UHall575AB
    244: SHT15_temp_Celsius 2013-02-03 16:45:27 31.01333 UHall575AB
    
    # Convert to irregular time series
    library(zoo)
    z <- with(result, zoo(value, timestamp))
    
    # Filter and plot
    filtered <- rollapply(z, width=7, FUN=median)
    plot(merge(z, filtered))

[R]: http://r-project.org "R"
[OpenTSDB]: http://www.opentsdb.net "OpenTSDB"
[BEACON]: http://beacon.berkeley.edu "Beacon"