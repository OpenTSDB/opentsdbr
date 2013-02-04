opentsdb
========

This package provides a read-only interface from [R] to [OpenTSDB]. We're using it internally for data analysis on the [BEACON] project at UC Berkeley. It's not optimized, and only uses HTTP, but could serve as a reference implementation (or straw man) for a faster and/or more fully featured API.

Seeking comment.

Example usage:

    R> library(opentsdb)
    R> metric <- "SHT15_temp_Celsius"
    R> start <- ISOdate(2013, 02, 02, 00, tz="America/Los_Angeles")
    R> tags <- c(arduino = "*")
    R> result <- tsd_get(metric, start, tags, downsample="10m-avg")
    url: http://localhost:4242/q?start=2013/02/02-00:00:00&m=avg:10m-avg:SHT15_temp_Celsius{arduino=*}&ascii=
    
    R> library(data.table)
    R> data.table(result)
                     metric           timestamp    value    arduino
      1: SHT15_temp_Celsius 2013-02-01 12:05:46 30.92895 UHall575AB
      2: SHT15_temp_Celsius 2013-02-01 12:15:51 31.46789 UHall575AB
      3: SHT15_temp_Celsius 2013-02-01 12:25:55 31.22088 UHall575AB
      4: SHT15_temp_Celsius 2013-02-01 12:35:57 31.67000 UHall575AB
      5: SHT15_temp_Celsius 2013-02-01 12:45:59 31.67000 UHall575AB
     ---                                                           
    311: SHT15_temp_Celsius 2013-02-03 16:01:19 31.30684 UHall575AB
    312: SHT15_temp_Celsius 2013-02-03 16:11:21 30.67779 UHall575AB
    313: SHT15_temp_Celsius 2013-02-03 16:21:23 30.65044 UHall575AB
    314: SHT15_temp_Celsius 2013-02-03 16:31:27 31.03175 UHall575AB
    315: SHT15_temp_Celsius 2013-02-03 16:37:51 30.94613 UHall575AB
    
    R> library(zoo)
    R> SHT15_temp_Celsius <- zoo(result$value, order.by=result$timestamp)
    R> plot(SHT15_temp_Celsius)

[R]: http://r-project.org "R"
[OpenTSDB]: http://www.opentsdb.net "OpenTSDB"
[BEACON]: http://beacon.berkeley.edu "Beacon"