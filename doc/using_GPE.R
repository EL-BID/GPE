## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, dpi = 200)

## ------------------------------------------------------------------------
library(GPE)

schools

## ----eval=FALSE----------------------------------------------------------
#  key <- "AIjaSyBR76W62lloYPh_c01LYGhCOZuKU6RVW9" # This is not a real API key, you must provide yours
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
merge(visits, visits_timedist, all = FALSE)

## ------------------------------------------------------------------------
head(visits_timedist)

## ------------------------------------------------------------------------
GPE_summary(visits_timedist)

## ------------------------------------------------------------------------
GPE_plot_travel(visits_timedist)

## ------------------------------------------------------------------------
GPE_plot_travel(visits_timedist, metric = "distance")

## ------------------------------------------------------------------------
GPE_plot_travel(visits_timedist, plot_type = "boxplot")

## ------------------------------------------------------------------------
GPE_plot_travel(visits_timedist, add_data_from = participants, plot_attribute = "income_bracket")

## ------------------------------------------------------------------------
GPE_plot_travel(visits_timedist, 
                add_data_from = locations, plot_attribute = "type", 
                plot_type = "boxplot", metric = "distance")

