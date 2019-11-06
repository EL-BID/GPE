#' Made up participants
#'
#' Synthetica data describing "participants", i.e. public program beneficiaries or similar agents.
#' Useful for testing aggregation and analysis functions.
#'
#' @docType data
#'
#' @usage data(participants)
#'
#' @format A data frame with 7452 rows and 5 variables:
#' \describe{
#'   \item{participant_id}{Participant unique ID}
#'   \item{group}{An example categorical attribute}
#'   \item{lon}{Participant longitude - home address or other origin point}
#'   \item{lat}{Participant latitude - home address or other origin point}
#'   \item{income_bracket}{An example ordinal attribute}
#' }
"participants"
