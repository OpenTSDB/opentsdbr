context("deserialize")

content <- "
myservice.latency.avg 1288900000 42 reqtype=foo host=baz
myservice.latency.avg 1288900001 51 reqtype=bar host=bap
"

json_content <- '
[{"metric":"metric1","tags":{"reqtype":"foo","host":"baz"},"aggregateTags":["tagk3"],"dps":{"1427846400":42,"1427850000":51}},
{"metric":"metric2","tags":{"reqtype":"bar","host":"bap"},"aggregateTags":["tagk3"],"dps":{"1427846400":51,"1427850000":42}}]
'

test_that("deserialize ASCII content as returned by TSD", {
    tags <- c(reqtype="*", host="*")
    parsed <- parse_ascii(content)
    expect_true(is.data.frame(parsed))
    expect_equal(names(parsed)[1:3], c("metric", "timestamp", "value"))
    expect_equal(names(parsed)[4:ncol(parsed)], names(tags))
    expect_true(is(parsed$timestamp, "POSIXct"))
    expect_equal(attr(parsed$timestamp, "tzone"), "UTC")
    expect_equal(as.numeric(parsed$timestamp), c(1288900000, 1288900001))
    expect_equal(parsed$value, c(42, 51))
    expect_equal(as.character(parsed$reqtype), c("foo", "bar"))
    expect_equal(as.character(parsed$host), c("baz", "bap"))
})

test_that("deserialize JSON content as returned by TSD", {
  tags <- c(reqtype="*", host="*")
  parsed <- parse_json_response(json_content)
  expect_true(is.data.frame(parsed))
  expect_equal(names(parsed)[1:3], c("metric", "timestamp", "value"))
  expect_equal(names(parsed)[4:ncol(parsed)], names(tags))
  expect_true(is(parsed$timestamp, "POSIXct"))
  expect_equal(attr(parsed$timestamp, "tzone"), "UTC")
  expect_equal(as.numeric(parsed$timestamp), c(1427846400, 1427846400, 1427850000, 1427850000))
  expect_equal(parsed$value, c(42, 51, 51, 42))
  expect_equal(as.character(parsed$reqtype), c("foo", "bar", "foo", "bar"))
  expect_equal(as.character(parsed$host), c("baz", "bap", "baz", "bap"))
})