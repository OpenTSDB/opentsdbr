require(opentsdb)
end <- now()
start <- end - 3600		# 1 hour ago
tags <- c(arduino = "*")
SHT15_temp_Celsius <- tsd_get("SHT15_temp_Celsius", start, end=end, tags=tags)
SHT15_humid_rel_pct <- tsd_get("SHT15_humid_rel_pct", start, end=end, tags=tags)
SHT15 <- rbind(SHT15_temp_Celsius, SHT15_humid_rel_pct)
summary(SHT15)