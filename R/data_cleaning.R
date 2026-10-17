#' Clean Raw NOAA Earthquake Data
#'
#' Converts coordinates to numeric values and combines year, month, and day into a standard R Date object.
#'
#' @param df A data frame containing raw NOAA earthquake data.
#' @return A data frame with parsed geographic coordinates and a standard \code{DATE} column.
#' @importFrom dplyr mutate case_when filter if_else select
#' @importFrom stringr str_detect str_to_upper str_extract str_trim str_remove str_to_title
#' @export

eq_clean_data <- function(df) {
  if (!"LOCATION_NAME" %in% names(df)) {
    stop(
      "LOCATION_NAME column not found. Available columns: ",
      paste(names(df), collapse = ", ")
    )
  }

  df %>%
    dplyr::mutate(
      COUNTRY = dplyr::case_when(
        stringr::str_detect(stringr::str_to_upper(LOCATION_NAME), "USA|UNITED STATES") ~ "USA",
        stringr::str_detect(
          stringr::str_to_upper(LOCATION_NAME),
          paste(
            c(
              "ALABAMA", "ALASKA", "ARIZONA", "ARKANSAS", "CALIFORNIA", "COLORADO",
              "CONNECTICUT", "FLORIDA", "GEORGIA", "HAWAII", "IDAHO", "ILLINOIS",
              "INDIANA", "IOWA", "KANSAS", "KENTUCKY", "LOUISIANA", "MAINE",
              "MARYLAND", "MASSACHUSETTS", "MICHIGAN", "MINNESOTA", "MISSISSIPPI",
              "MISSOURI", "MONTANA", "NEBRAKSA", "NEVADA", "NEW HAMPSHIRE",
              "NEW JERSEY", "NEW MEXICO", "NEW YORK", "NORTH CAROLINA", "NORTH DAKOTA",
              "OHIO", "OKLAHOMA", "OREGON", "PENNSYLVANIA", "RHODE ISLAND",
              "SOUTH CAROLINA", "SOUTH DAKOTA", "TENNESSEE", "TEXAS", "UTAH",
              "VERMONT", "VIRGINIA", "WASHINGTON", "WEST VIRGINIA", "WISCONSIN",
              "WYOMING", "ALASKA PENINSULA", "HAWAIIAN ISLANDS", "GULF OF ALASKA",
              "SE ALASKA", "SE. ALASKA"
            ),
            collapse = "|"
          )
        ) ~ "USA",
        TRUE ~ stringr::str_to_upper(stringr::str_trim(stringr::str_extract(LOCATION_NAME, "^[^:]+")))
      ),
      clean_month = dplyr::if_else(is.na(MONTH), 1, as.numeric(MONTH)),
      clean_day = dplyr::if_else(is.na(DAY), 1, as.numeric(DAY)),
      date_str = sprintf(
        "%04d-%02d-%02d",
        as.integer(YEAR),
        as.integer(clean_month),
        as.integer(clean_day)
      )
    ) %>%
    dplyr::filter(YEAR > 0) %>%
    dplyr::mutate(
      DATE = as.Date(date_str, format = "%Y-%m-%d")
    ) %>%
    dplyr::select(-clean_month, -clean_day, -date_str)
}

#' Clean Location Names
#'
#' Strips the country prefix and colon from the location name column and converts the remaining text to Title Case.
#'
#' @param df A data frame containing a \code{LOCATION_NAME} column.
#' @return A data frame with a sanitized, Title Case LOCATION_NAME column.
#' @export
eq_location_clean <- function(df) {
  df %>%
    dplyr::mutate(
      LOCATION_NAME = LOCATION_NAME %>%
        stringr::str_remove("^[^:]+:\\s*") %>%
        stringr::str_to_title()
    )
}
