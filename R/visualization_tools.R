#' ggproto for Earthquake Timeline
#' GeomTimeline
#' Internal ggproto class for geom_timeline.
#' @keywords internal
#' @format NULL
#' @usage NULL
#' @importFrom ggplot2 ggproto Geom aes
#' @importFrom grid segmentsGrob pointsGrob grobTree textGrob gpar
#' @export
GeomTimeline <- ggplot2::ggproto(
  "GeomTimeline",
  ggplot2::Geom,

  required_aes = c("x"),

  default_aes = ggplot2::aes(
    y = 0,
    shape = 19,
    colour = "grey50",
    size = 1.5,
    alpha = 0.4
  ),

  draw_panel = function(data, panel_params, coord) {
    coords <- coord$transform(data, panel_params)
    y_values <- unique(coords$y)

    timeline_grob <- grid::segmentsGrob(
      x0 = 0, x1 = 1,
      y0 = y_values, y1 = y_values,
      default.units = "native",
      gp = grid::gpar(col = "grey70", lwd = 1)
    )

    point_grob <- grid::pointsGrob(
      x = coords$x, y = coords$y,
      pch = coords$shape,
      default.units = "native",
      gp = grid::gpar(
        col = coords$colour,
        fill = coords$colour,
        alpha = coords$alpha,
        cex = coords$size
      )
    )

    grid::grobTree(timeline_grob, point_grob)
  }
)

#' Earthquakes Timeline Layer
#' Timeline of Earthquakes
#' Creates a timeline of earthquakes
#' #' Earthquakes Timeline Layer
#'
#' @param mapping Set of aesthetic mappings created by \code{\link[ggplot2]{aes}}.
#' @param data The data to be displayed in this layer.
#' @param stat The statistical transformation to use on the data.
#' @param position Position adjustment for overlapping points.
#' @param na.rm If \code{FALSE}, the default, missing values are removed with a warning.
#' @param show.legend Logical. Should this layer be included in the legends?
#' @param inherit.aes If \code{FALSE}, overrides the default aesthetics.
#' @param ... Other arguments passed on to \code{\link[ggplot2]{layer}}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot(df, aes(x = DATE)) +
#'   geom_timeline()
#' }
#' @export
geom_timeline <- function(
    mapping = NULL, data = NULL, stat = "identity", position = "identity",
    na.rm = FALSE, show.legend = TRUE, inherit.aes = TRUE, ...
) {
  ggplot2::layer(
    geom = GeomTimeline, mapping = mapping, data = data, stat = stat,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, ...)
  )
}
#' @export
GeomTimelineLabel <- ggplot2::ggproto(
  "GeomTimelineLabel",
  ggplot2::Geom,

  required_aes = c("x", "label", "magnitude"),

  default_aes = ggplot2::aes(
    y = 0,
    colour = "black",
    size = 3,
    alpha = 1
  ),

  parameters = function(extra = FALSE) {
    c(ggplot2::Geom$parameters(extra), "n_max")
  },

  setup_data = function(data, params) {
    if (nrow(data) > 0 && !is.null(params$n_max)) {
      data <- data %>%
        dplyr::group_by(y) %>%
        dplyr::arrange(dplyr::desc(magnitude)) %>%
        dplyr::slice(1:min(params$n_max, dplyr::n())) %>%
        dplyr::ungroup()
    }
    data
  },

  draw_panel = function(data, panel_params, coord) {
    coords <- coord$transform(data, panel_params)

    if ("size" %in% names(coords) && length(coords$size) > 1 && (max(coords$size) != min(coords$size))) {
      label_height <- (coords$size - min(coords$size)) /
        (max(coords$size) - min(coords$size) + 0.01) * 0.15 + 0.05
    } else {
      label_height <- rep(0.1, nrow(coords))
    }

    line_grob <- grid::segmentsGrob(
      x0 = coords$x, x1 = coords$x,
      y0 = coords$y, y1 = coords$y + label_height,
      default.units = "native",
      gp = grid::gpar(col = coords$colour, alpha = coords$alpha, lwd = 0.5)
    )

    text_grob <- grid::textGrob(
      label = coords$label,
      x = coords$x, y = coords$y + label_height,
      just = c("left", "bottom"),
      rot = 45,
      default.units = "native",
      gp = grid::gpar(col = coords$colour, fontsize = coords$size * 3, alpha = coords$alpha)
    )

    grid::grobTree(line_grob, text_grob)
  }
)

#' Labeling Geom for Timeline Earthquakes
#'
#' Adds vertical connector lines and annotations for the largest earthquakes on a timeline.
#'
#' @param mapping Set of aesthetic mappings created by \code{\link[ggplot2]{aes}}.
#' @param data The data to be displayed in this layer.
#' @param stat The statistical transformation to use on the data.
#' @param position Position adjustment for overlapping points.
#' @param na.rm If \code{FALSE}, the default, missing values are removed with a warning.
#' @param show.legend Logical. Should this layer be included in the legends?
#' @param inherit.aes If \code{FALSE}, overrides the default aesthetics.
#' @param n_max An integer specifying the maximum number of top earthquakes to label.
#' @param ... Other arguments passed on to \code{\link[ggplot2]{layer}}.
#'
#' @export
geom_timeline_label <- function(
    mapping = NULL, data = NULL, stat = "identity", position = "identity",
    na.rm = FALSE, show.legend = FALSE, inherit.aes = TRUE, n_max = 5, ...
) {
  ggplot2::layer(
    geom = GeomTimelineLabel, mapping = mapping, data = data, stat = stat,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, n_max = n_max, ...)
  )
}
