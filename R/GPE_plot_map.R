#' GPE_plot_map
#'
#' Plot a map showing participants, and program locations
#' @export GPE_plot_map
#' @param participants a dataframe containing "lon" and "lat" columns with WGS84 (Mercator) coordinates
#' @param locations a dataframe containing "lon" and "lat" columns with WGS84 (Mercator) coordinates
#' @param participant_attribute (optional) a participants dataframe column containing an attribute to show in the map
#' @param location_attribute (optional) a locations dataframe column containing an attribute to show in the map
#' @examples
#' \donttest{
#' GPE_plot_map(participants = participants, locations = locations)
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

    set_color_scale <- function() {
        if (is.numeric(participants[[participant_attribute]])) return(ggplot2::scale_color_viridis_c(option = "plasma"))
            else return(ggplot2::scale_color_viridis_d(option = "plasma"))
    }

    p <- ggmap::ggmap(ggmap = basemap)

    if (is.na(participant_attribute)) {
        p <- p + ggplot2::geom_point(data = participants, ggplot2::aes_string(x = "lon", y = "lat"),
                                     color = "#e34a33", alpha = 0.5, size = point_size(nrow(participants)))
    } else {
        p <- p + ggplot2::geom_point(data = participants,
                                     ggplot2::aes_string(x = "lon", y = "lat", color = participant_attribute),
                                     alpha = 0.5, size = point_size(nrow(participants))) +
            set_color_scale()
    }

    if (!missing(locations)) {

        if (is.na(location_attribute)) {
            p <- p + ggplot2::geom_point(data = locations,
                                         ggplot2::aes_string(x = "lon", y = "lat"),
                                         shape = 6, size = point_size(nrow(locations)))
        } else {
            p <- p + ggplot2::geom_point(data = locations,
                                         ggplot2::aes_string(x = "lon", y = "lat", shape = location_attribute),
                                         size = point_size(nrow(locations)))
        }

    }


    p + ggplot2::theme_void()

}

