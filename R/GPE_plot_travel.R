#' GPE_plot_travel
#'
#' Plot a visualization showing participant travel time
#' @export GPE_plot_travel
#' @param visits_timedist a dataframe of "visits" with travel time and distance (see ?GPE_travel_time_dist)
#' @param add_data_from (optional) a participants or locations dataframe, containing either a "participant_id" or a "location_id" column, plus a column with an attribute to plot. Must be paired with "plot_attribute"
#' @param plot_attribute (optional) the column name from the "add_data" dataframe containing the attribute to show on the plot
#' @param plot_type (optional) either "histogram" (default), "boxplot"
#' @param metric (optional) measure for travel, either "time" (default), or "distance"
#' @examples
#' GPE_plot_travel(visits_timedist = visits_timedist)



GPE_plot_travel <- function(visits_timedist, add_data_from = NA,
                         plot_attribute = NA, plot_type = "histogram", metric = "time") {

    if (!is.na(plot_attribute)) {

        if ("participant_id" %in% names(add_data_from)) {
            visits_timedist <- merge(visits_timedist,
                                     add_data_from, by.x = "participant_id", by.y = "participant_id")
        } else if ("location_id" %in% names(add_data_from)) {
            visits_timedist <- merge(visits_timedist,
                                     add_data_from, by.x = "location_id", by.y = "location_id")
        } else {
            stop('the "add_data_from" data frame must contain either a "participant_id" or a "location_id" column')
        }

    }


    if (metric == "distance") {
        trip_var <- "distance_km"
        plot_title <- "Travel distance"
        plot_subtitle <- ""
    } else if (metric == "time") {
        trip_var <- "time_minutes"
        plot_title <- "Travel time"
        plot_subtitle <- ""
    } else {
        stop('parameter "metric" must be either "time" or "distance"')
    }


    set_fill_scale <- function(dframe, plot_attribute) {
        if (is.numeric(dframe[[plot_attribute]])) return(ggplot2::scale_fill_viridis_c(option = "plasma"))
        else return(ggplot2::scale_fill_viridis_d(option = "plasma"))
    }

    set_color_scale <- function(dframe, plot_attribute) {
        if (is.numeric(dframe[[plot_attribute]])) return(ggplot2::scale_fill_viridis_c(option = "plasma"))
        else return(ggplot2::scale_color_viridis_d(option = "plasma"))
    }



    p <- ggplot2::ggplot(visits_timedist) + ggplot2::theme_minimal()


    if (plot_type == "histogram") {

        y_label = "count"
        x_label <- ifelse(metric == "time", "minutes", "kilometers")

        if (is.na(plot_attribute)) {
            p <- p + ggplot2::geom_histogram(ggplot2::aes_string(x = trip_var))
        } else {
            plot_subtitle <- paste("by", plot_attribute)

            p <- p + ggplot2::geom_histogram(ggplot2::aes_string(x = trip_var,
                                                                fill = plot_attribute)) +
                facet_wrap(as.formula(paste("~", plot_attribute))) +
                set_fill_scale(visits_timedist, plot_attribute) +
                guides(fill = FALSE)
        }

    } else if (plot_type == "boxplot") {

        y_label <- ifelse(metric == "time", "minutes", "kilometers")

        if (is.na(plot_attribute)) {

            x_label <- ""

            p <- p +
                ggplot2::geom_jitter(ggplot2::aes_string(x = "metric", y = trip_var),
                                     height = 0, alpha = .3) +
                ggplot2::geom_boxplot(ggplot2::aes_string(x = "metric", y = trip_var),
                                      fill = NA, alpha = .5, outlier.shape = NA) +
                theme(axis.text.x=element_blank())
        } else {
            plot_subtitle <- paste("by", plot_attribute)
            x_label <- plot_attribute
            visits_timedist[[plot_attribute]] <- as.factor(visits_timedist[[plot_attribute]])

            p <- p +
                ggplot2::geom_jitter(ggplot2::aes_string(x = plot_attribute, y = trip_var,
                                                         color = plot_attribute),
                                     height = 0, alpha = .75) +
                ggplot2::geom_boxplot(ggplot2::aes_string(x = plot_attribute, y = trip_var),
                                      fill = NA, alpha = .5, outlier.shape = NA) +
                set_color_scale(visits_timedist, plot_attribute) +
                guides(color = FALSE)
        }



    }


    p + labs(title = plot_title,
                  subtitle = plot_subtitle,
                  x = x_label,
                  y = y_label)

}

