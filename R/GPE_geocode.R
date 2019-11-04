#' GPE_geocode
#'
#' A thin wrapper for ggmap::utate_geocode. Takes a dataframe, adds lon/lat columns based on an existing address column using Google's geocoding API (https://developers.google.com/maps/documentation/geocoding/start).
#' @import ggmap
#' @export GPE_geocode
#' @param data a dataframe containing an address column
#' @param address the name of a column in the geocode dataframe containing addresses
#' @param key an API key obtained at https://cloud.google.com/maps-platform/
#' @examples
#' GPE_geocode(data = schools, addres = address)

GPE_geocode <- function(data, address, key) {

    if (ggmap::google_key() != key) register_google(key)

    ggmap::mutate_geocode(data = data, location = address)
}
