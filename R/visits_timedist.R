#' Made up visits, with trip duration and distance
#'
#' Randomly selected pairs of "participants" and "locations", representing visits,
#' useful for testing visit aggregation and analysis functions.
#'
#' @format A data frame with 234 rows and 6 variables:
#' \describe{
#'   \item{date}{Visit date}
#'   \item{participant_id}{Participant unique ID}
#'   \item{location_id}{Location Unique ID}
#'   \item{time_minutes}{trip duration in minutes}
#'   \item{distance_km}{trip distance in km}
#'   \item{mode}{transportation mode -transit, walking, driving, or bycicle}
#' }
"visits_timedist"
