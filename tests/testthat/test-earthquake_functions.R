library(Final)
library(ggplot2)

# Load dataset paths for testing
file_path <- system.file("extdata", "signif.txt", package = "Final")
raw_data <- if (file_path != "") readr::read_delim(file_path, delim = "\t", n_max = 20, show_col_types = FALSE) else NULL

# standardize column names needed by eq_clean_data
if (!is.null(raw_data)) {
  # Go to upper case
  names(raw_data) <- toupper(names(raw_data))

  # Change abbreviations to full versions
  if ("MO" %in% names(raw_data)) names(raw_data)[names(raw_data) == "MO"] <- "MONTH"
  if ("DY" %in% names(raw_data)) names(raw_data)[names(raw_data) == "DY"] <- "DAY"
  if ("LOCATION_NAME" %in% names(raw_data) == FALSE) {
    names(raw_data)[names(raw_data) == "LOCATION_NAME"] <- "LOCATION_NAME"
  }

  # Check underscores exist
  names(raw_data) <- gsub(" ", "_", names(raw_data))

  # map MAG or MAGNITUDE to EQ_PRIMARY for eq_map requirements
  if ("MAG" %in% names(raw_data)) {
    raw_data$EQ_PRIMARY <- as.numeric(raw_data$MAG)
  } else if (!"EQ_PRIMARY" %in% names(raw_data)) {
    raw_data$EQ_PRIMARY <- 5.0
  }
}

test_that("Data cleaning functions work properly", {
  testthat::skip_if(is.null(raw_data), "Raw data file not found")

  clean_data <- eq_clean_data(raw_data)
  expect_s3_class(clean_data, "data.frame")
  expect_true("DATE" %in% names(clean_data))

  loc_clean <- eq_location_clean(clean_data)
  expect_true("LOCATION_NAME" %in% names(loc_clean))
})

test_that("Geom timeline layers return correct ggplot elements", {
  testthat::skip_if(is.null(raw_data), "Raw data file not found")
  clean_data <- eq_clean_data(raw_data)

  if (!"COUNTRY" %in% names(clean_data)) clean_data$COUNTRY <- "USA"
  if (!"EQ_PRIMARY" %in% names(clean_data)) clean_data$EQ_PRIMARY <- 5.0

  p1 <- ggplot(clean_data, aes(x = DATE)) + geom_timeline()
  expect_s3_class(p1, "ggplot")

  p2 <- p1 + geom_timeline_label(aes(label = LOCATION_NAME, magnitude = EQ_PRIMARY))
  expect_s3_class(p2, "ggplot")
})

test_that("Leaflet mapping function works smoothly", {
  testthat::skip_if(is.null(raw_data), "Raw data file not found")
  clean_data <- eq_clean_data(raw_data)

  if (!"LOCATION_NAME" %in% names(clean_data)) clean_data$LOCATION_NAME <- "Test Location"
  if (!"EQ_PRIMARY" %in% names(clean_data)) clean_data$EQ_PRIMARY <- 5.0

  map_plot <- eq_map(clean_data, annot_col = "LOCATION_NAME")
  expect_s3_class(map_plot, "leaflet")
})
