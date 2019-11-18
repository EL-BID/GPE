#' GPE_summary
#'
#' Plot a map showing participants, and program locations
#' @export GPE_summary
#' @param visits a dataframe of "visits", events when a participant visited a location, containing "participant_id" and "location_id" columns
#' @examples
#' GPE_summary(visits = visits)


GPE_summary <- function(visits) {

    participant_frecuency <- data.frame(table(visits$participant_id))

    participant_visits <- summary(participant_frecuency$Freq)

    location_frecuency <- data.frame(table(visits$location_id))

    location_visits <- summary(location_frecuency$Freq)

    output <- list("visits by participant" = participant_visits,
                   "visits by location" = location_visits)

    if ("time_minutes" %in% names(visits)) {

        output <- c(output, list("travel time (minutes)" = summary(visits$time_minutes)))
    }

    if ("distance_km" %in% names(visits)) {

        output <- c(output, list("travel distance (km)" = summary(visits$distance_km)))
    }

    output


}

