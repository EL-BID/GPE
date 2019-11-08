#' GPE_get_basemap
#'
#' Get a basemap from Stamen Maps (http://maps.stamen.com/)
#' @import ggmap
#' @export GPE_get_basemap
#' @param participants a dataframe containing "lon" and "lat" columns with WGS84 (Mercator) coordinates
#' @param locations a dataframe containing "lon" and "lat" columns with WGS84 (Mercator) coordinates
#'
#' @examples
#' \donttest{
#' GPE_get_basemap(participants = participants, locations = locations)
#' }

GPE_get_basemap <- function(participants, locations) {

    bbox <- ggmap::make_bbox(lon = c(participants$lon, locations$lon),
                             lat = c(participants$lat, locations$lat))

    zoom <- ggmap::calc_zoom(bbox)

    ggmap::get_stamenmap(bbox = bbox, zoom = zoom)
}
