context('parsing')

test_that("parse_tags", {
	tag_keys <- c("serial", "host", "site")
	tag_strings <- c(
		"host=foo serial=bar site=bap",
		"host=foo serial=bar site=baz"
		)
	actual <- parse_tags(tag_strings, tag_keys)
	expected <- data.frame(serial=c('bar', 'bar'), host=c('foo', 'foo'), site=c('bap', 'baz'))
	expect_equal(actual, expected)
})

content <- "
myservice.latency.avg 1288900000 42 reqtype=foo abc=bap
myservice.latency.avg 1288900000 51 reqtype=bar abc=bap
"

test_that("parse_content", {
	dat <- parse_content(content, tags=c('reqtype', 'abc'))
	#expect_equal(dat, data.frame())
})