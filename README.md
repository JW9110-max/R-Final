# Final: NOAA Significant Earthquake Visualization Tool

The **Final** R package provides a robust suite of tools designed to process, analyze, and visualize historical earthquake data from the **NOAA Global Significant Earthquake Database**. Built as a capstone project for the Mastering Software Development in R specialization, it introduces custom `ggplot2` layout layers for timeline tracking alongside interactive `leaflet` geospatial maps.

## Features

- **Data Wrangling:** Cleans erratic coordinate listings, sanitizes regional locations to clear Title Case formatting, and gracefully processes multi-era dates.
- **Geom Extensions:** Chronological timeline tracking using custom `geom_timeline()` and top-magnitude annotation text callouts with `geom_timeline_label()`.
- **Interactive Spatial Mapping:** Fluid interactive maps generated with `eq_map()` featuring multi-variable HTML metadata popup indicators via `eq_create_label()`.

## Installation

You can install the development version of `Final` directly from GitHub using the `devtools` engine:

```R
# If devtools isn't installed: install.packages("devtools")
devtools::install_github("your_github_username/Final")
```

## Quick Start & Usage Examples

Ensure you have your earthquake data frame loaded (typically reading the NOAA `signif.txt` file). Here is how you can use all three package modules back-to-back:

### 1. Data Processing & Cleaning
```R
library(Final)
library(dplyr)
library(ggplot2)

# Load raw dataset and apply programmatic cleaning routines
cleaned_data <- raw_data %>%
  eq_clean_data() %>%
  eq_location_clean()
```

### 2. Plotting Chronological Timelines
Compare earthquake time sequences across stratified country horizons. Scale marker dots by magnitude and assign color intensity based on fatalities:

```R
timeline_df <- cleaned_data %>%
  dplyr::filter(
    YEAR >= 2000,
    YEAR <= 2020,
    COUNTRY %in% c("USA", "CHINA", "JAPAN")
  )

ggplot(timeline_df, aes(x = DATE, y = COUNTRY, size = EQ_PRIMARY, colour = TOTAL_DEATHS)) +
  geom_timeline() +
  geom_timeline_label(aes(label = LOCATION_NAME, magnitude = EQ_PRIMARY), n_max = 3) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  labs(size = "Magnitude", colour = "Fatalities", x = "Timeline Date", y = "Country")
```

### 3. Creating Interactive Leaflet Maps
Map the spatial epicenters of earthquakes dynamically with fully structured boldface metadata popups:

```R
map_df <- cleaned_data %>%
  dplyr::filter(COUNTRY == "MEXICO" & lubridate::year(DATE) >= 2000) %>%
  dplyr::mutate(popup_text = eq_create_label(.))

# Generates an interactive spatial rendering canvas
eq_map(map_df, annot_col = "popup_text")
```

## Requirements & Dependencies

To guarantee complete functionality, `eqvis` works in conjunction with the following required libraries:
- `ggplot2` (>= 3.0.0)
- `leaflet`
- `dplyr`
- `stringr`
- `grid`
- `htmltools`
