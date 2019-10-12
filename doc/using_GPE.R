## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)

## ------------------------------------------------------------------------
participants <- read.csv("../data/participants.csv")

head(participants)

## ------------------------------------------------------------------------
locations <- read.csv("../data/locations.csv")

head(locations)

## ------------------------------------------------------------------------
library(GPE)

GPE_plot_map(participants, locations)

