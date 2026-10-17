#' Create Interactive Map of Earthquake Epicenters
#'
#' @param data A data frame containing filtered NOAA earthquake data.
#' @param annot_col Character string representing the column name to use for popup annotations.
#' @return A leaflet map object.
#' @export
eq_map <- function(data, annot_col = "DATE") {
  leaflet::leaflet(data) %>%
    leaflet::addTiles() %>%
    leaflet::addCircleMarkers(
      lng = ~LONGITUDE,
      lat = ~LATITUDE,
      radius = ~EQ_PRIMARY,
      popup = lapply(data[[annot_col]], htmltools::HTML),
      weight = 1,
      color = "grey50",
      fillColor = "red",
      fillOpacity = 0.5
    )
}

#' Create HTML Labels for Earthquake Popups
#'
#' @param data A data frame containing cleaned NOAA earthquake data.
#' @return A character vector of HTML-formatted strings.
#' @export
eq_create_label <- function(data) {
  labels <- character(nrow(data))

  for (i in seq_len(nrow(data))) {
    label_parts <- c()

    if (!is.na(data$LOCATION_NAME[i]) && data$LOCATION_NAME[i] != "") {
      label_parts <- c(label_parts, paste0("<b>Location:</b> ", data$LOCATION_NAME[i]))
    }

    if (!is.na(data$EQ_PRIMARY[i])) {
      label_parts <- c(label_parts, paste0("<b>Magnitude:</b> ", data$EQ_PRIMARY[i]))
    }

    if ("TOTAL_DEATHS" %in% names(data) && !is.na(data$TOTAL_DEATHS[i])) {
      label_parts <- c(label_parts, paste0("<b>Total deaths:</b> ", data$TOTAL_DEATHS[i]))
    }

    labels[i] <- paste(label_parts, collapse = "<br/>")
  }

  labels
}
