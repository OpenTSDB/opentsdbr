context("deserialize")

test_that("deserialize tags from string (ex: foo=bar baz=bap)", {
    tag_keys <- c("serial", "host", "site")
    tag_strings <- c(
        "host=foo serial=bar site=bap",
        "host=foo serial=bar site=baz"
        )
    actual <- deserialize_tags(tag_strings, tag_keys)
    expected <- data.frame(serial=c("bar", "bar"), host=c("foo", "foo"), site=c("bap", "baz"))
    expect_equal(actual, expected)
})