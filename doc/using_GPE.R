## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, dpi = 200)

## ------------------------------------------------------------------------
library(GPE)

schools

## ----eval=FALSE----------------------------------------------------------
#  key <- "AIjaSyBR76W62lloYPh_c01LYGhCOZuKU6RVW9" # This is not a real API key, provide yours
#  
#  GPE_geocode(schools, address, key)

## ----echo=FALSE----------------------------------------------------------
key <- ggmap::google_key()

GPE_geocode(schools, address, key)

## ------------------------------------------------------------------------
head(participants)

## ------------------------------------------------------------------------
GPE_plot_map(participants)

## ------------------------------------------------------------------------
head(locations)

## ------------------------------------------------------------------------
GPE_plot_map(participants, locations)

## ------------------------------------------------------------------------
GPE_plot_map(participants, locations, participant_attribute = "group")

## ------------------------------------------------------------------------
GPE_plot_map(participants, locations, location_attribute = "type")

## ------------------------------------------------------------------------
GPE_plot_map(participants, locations, participant_attribute = "group", location_attribute = "type")

## ------------------------------------------------------------------------
visits

## ----eval=FALSE----------------------------------------------------------
#  GPE_travel_time_dist(visits, participants, locations, key)

## ----echo=FALSE----------------------------------------------------------
visits_timedist

## ------------------------------------------------------------------------
head(visits_timedist)

## ------------------------------------------------------------------------
#GPE_summary(visits_timedist)

