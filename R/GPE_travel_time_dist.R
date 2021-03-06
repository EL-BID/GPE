#' GPE_travel_time_dist
#'
#' Estimate travel time and distance between origins and destinations
#' @export GPE_travel_time_dist
#' @param visits a dataframe of "visits", events when a participant visited a location, containing "participant_id" and "location_id" columns
#' @param participants a dataframe containing "lon" and "lat" columns with WGS84 (Mercator) coordinates and a "participant_id" column
#' @param locations a dataframe containing "lon" and "lat" columns with WGS84 (Mercator) coordinates and a "location_id" column
#' @param key an API key obtained at https://cloud.google.com/maps-platform/
#' @param transport_mode (optional) either "transit" (default), "driving", "walking", or "bicycling"
#' @examples
#' \dontrun{
#' GPE_travel_time_dist(visits, participants, locations, key, transport_mode = "walking")
#' }



GPE_travel_time_dist <- function(visits, participants, locations, key, transport_mode = "transit") {

    if (is.na(ggmap::google_key()) | ggmap::google_key() != key) ggmap::register_google(key)

    trips <- unique(visits[c("participant_id", "location_id")] )

    trips <- merge(trips, participants[c("participant_id","lon", "lat")])
    colnames(trips)[c(ncol(trips)-1, ncol(trips))] <- c("origin_lat", "origin_lon")

    trips <- merge(trips, locations[c("location_id", "lon", "lat")])
    colnames(trips)[c(ncol(trips)-1, ncol(trips))] <- c("dest_lat", "dest_lon")

    trips["from"] <- paste(trips$origin_lon, trips$origin_lat, sep = ",")
    trips["to"] <- paste(trips$dest_lon, trips$dest_lat, sep = ",")


    trip_dist_time <- function(from, to, mode = transport_mode) {

        results <- ggmap::route(from, to, mode)

        data.frame(time_minutes = sum(results$minutes),
                   distance_km = sum(results$km),
                   mode = mode)
    }

    results <- mapply(trip_dist_time, trips$from, trips$to, "transit", SIMPLIFY = FALSE)
    results <- Reduce(rbind, results)

    trips <- cbind(trips[1:2], results)

    merge(visits, trips, all.x = TRUE)
}


