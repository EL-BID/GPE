#' GPE_plot_map
#'
#' Plot a map showing participants, and program locations
#' @import ggplot2
#' @import ggmap
#' @export GPE_plot_map
#' @param participants a dataframe containing "lon" and "lat" columns with WGS84 (Mercator) coordinates
#' @param locations a dataframe containing "lon" and "lat" columns with WGS84 (Mercator) coordinates
#' @param participant_attribute (optional) a participants dataframe column containing an attribute to show in the map
#' @param location_attribute (optional) a locations dataframe column containing an attribute to show in the map
#' @examples
#' \donttest{
#' #'GPE_plot_map(participants = participants, locations = locations)
#' }


GPE_plot_map <- function(participants, locations = NULL,
                         participant_attribute = NA, location_attribute = NA) {

    basemap <- GPE_get_basemap(participants = participants, locations = locations)

    point_size <- function(n) {
        if (n < 20) {
            3 } else if (n < 200) {
                2 } else if (n < 1000) {
                    1 } else if (n < 10000) {
                        1000 / n } else {
                            0.1 }
    }

    ggmap::ggmap(ggmap = basemap) +
        ggplot2::geom_point(data = participants, ggplot2::aes_string(x = "lon", y = "lat"),
                   color = "#e34a33",
                   alpha = 0.5,
                   size = point_size(nrow(participants))) +
            ggplot2::geom_point(data = locations, ggplot2::aes_string(x = "lon", y = "lat"),
                                shape = 6,
                                size = 2) +
            ggplot2::theme_void()

}

