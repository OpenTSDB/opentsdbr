opentsdbr
========

This package provides a read-only interface from [R] to [OpenTSDB]. We're using it internally for data analysis on the [BEACON] project at UC Berkeley. It's not optimized, and only uses HTTP, but could serve as a reference implementation (or straw man) for a faster and/or more fully featured API.

Seeking comment!

Installation
------------

Install directly from GitHub using [remotes]:

    if (!require("remotes")) install.packages("remotes")
    remotes::install_github("OpenTSDB/opentsdbr")

Example usage
-------------

    library(opentsdbr)
    
    metric <- "SHT15_temp_Celsius"
    start <- interval(ymd_hms("2013-02-02 00:00:00"), ymd_hms("2013-02-02 23:59:59"), tz="America/Los_Angeles")
    
    # Query the TSD (defaults to localhost:4242)
    # Optional: pass verbose=TRUE to see url and timings
    (result <- tsd_get(metric, start, tags=c(site="*"), downsample="10m-avg"))
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

    # Query the TSD through the opentsdb v2 endpoint which means that now it supports non-ascii tags such as UTF-8.
    (result <- tsd_req(metric, start, tags=c(site="*"), downsample="10m-avg"))

    # Convert to irregular time series, filter, and plot
    library(zoo)
    z <- with(result, zoo(value, timestamp))
    filtered <- rollapply(z, width=7, FUN=median)
    plot(merge(z, filtered))

[R]: http://r-project.org "R"
[OpenTSDB]: http://www.opentsdb.net "OpenTSDB"
[BEACON]: http://beacon.berkeley.edu "Beacon"
[remotes]: https://github.com/r-lib/remotes "remotes"
