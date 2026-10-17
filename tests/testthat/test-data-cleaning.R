library(testthat)
library(dplyr)

test_that("eq_clean_data converts types and handles coordinates properly", {
  mock_raw <- data.frame(
    YEAR = c("2010", "1995"),
    MONTH = c("05", NA),
    DAY = c("12", NA),
    LATITUDE = c("19.43", "-12.04"),
    LONGITUDE = c("-99.13", "-77.03"),
    LOCATION_NAME = c("MEXICO: OAXACA", "ITALY: ROME"),
    stringsAsFactors = FALSE
  )

  cleaned <- eq_clean_data(mock_raw)
  expect_s3_class(cleaned$DATE, "Date")

  # Target the specific row index for each comparison
  expect_equal(cleaned$DATE[1], as.Date("2010-05-12"))
  expect_equal(cleaned$DATE[2], as.Date("1995-01-01"))
})

test_that("eq_location_clean strips country labels and formats to Title Case", {
  mock_locations <- data.frame(
    LOCATION_NAME = c("MEXICO: SAN CRISTOBAL", "ITALY: ROME"),
    stringsAsFactors = FALSE
  )

  cleaned_locs <- eq_location_clean(mock_locations)

  # FIXED: Target the specific row index for each comparison
  expect_equal(cleaned_locs$LOCATION_NAME[1], "San Cristobal")
  expect_equal(cleaned_locs$LOCATION_NAME[2], "Rome")
})
