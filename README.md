
# Georeferenced Program Evaluation

## Description and context

The GPE (Georeferenced Program Evaluation) R package includes functions that will allow the user to study various aspects of consumer or beneficiary behavior, including:

- Georeference postal addresses (converting street name and number to latitude and longitude points)

- Obtain base maps of any city’s urban grid and visualize overlaid projections of the distance traveled (between participants’ homes and points of service accessed, for example)

- Estimate a matrix of distances between sites accessed and consumer/beneficiary origin

- Calculate metrics of frequency, distribution by group, and distance travelled by consumers/beneficiaries to points of sale/access
    
- Create visualizations that explore the difference between frequency and type of consumption by consumer/beneficiary attribute (depending on the information available: socioeconomic status, length of program participation, type of program participation, etc)



## User guide
### Basic usage

For complete documentation of this R package, please see the [documentation website](). Examples of the functions can be found below and in the [doc](https://github.com/EL-BID/GPE/tree/master/doc) folder of this repository. 

You’ll need tabular data with addresses, or “lon” and “lat” columns containing WG84 (Mercator) location coordinates. In other words, a table with the addresses of schools that program beneficiaries attend, or a street or centroid identifying their neighborhoods, or their home addresses if using personal data is allowed.


#### Geocoding

You can geocode your data (obtain latitude and longitude from addresses) using `GPE_geocode()`, a function that queries the Google Maps Platform to translate addresses into latitude/longitude coordinates.

Using the Google Maps Platform requires a registered API key. To obtain it, follow instructions from https://developers.google.com/maps/gmp-get-started. Make sure you enable the Geocoding API.

A valid API key is a string of leters and numbers that looks like AIjaSyBR76W62lloYPh_c01LYGhCOZuKU6RVW9 -this is not a real ID by the way, just an example-. Once you have your key, you can take a data frame with an address column like this one:
Having a "participants" dataframe such as

    library(GPE)
    schools

                    name            address                             level         
                1   EMus 02         Camarones 4351, C1407FMU, CABA      other
                2   Col La Anuncia… Arenales 2065, C1124AAE, CABA       preschool, primary,…
                3   EPjs 06         Avda. Eva Perón 7431, C1439BTM, CA… primary             `
                4   EPjs 02         Avda. Pte. Manuel Quintana 31/07, … primary             `
                5   Col Horacio Wa… Díaz Colodrero 2431, C1431FMA, CABA preschool, primary,…

… and add latitude and longitude columns using GPE_geocode, specifying the name of the address column and your Google Maps Platform API key:
`key <- "AIjaSyBR76W62lloYPh_c01LYGhCOZuKU6RVW9" # This is not a real API key, you must provide yours`

`GPE_geocode(schools, address, key)`

                    name            address                          level             lon     lat
                1   EMus 02         Camarones 4351, C1407FMU, C…     other             -58.5   -34.6
                2   Col La Anunc…   Arenales 2065, C1124AAE, CA…     preschool, prima… -58.4   -34.6`
                3   EPjs 06         Avda. Eva Perón 7431, C1439…     primary           -58.5   -34.7`
                4   EPjs 02         Avda. Pte. Manuel Quintana …     primary           -58.4   -34.6`
                5   Col Horacio …   Díaz Colodrero 2431, C1431F…     preschool, prima… -58.5   -34.6`
                
Columns with latitude and longitude coordinates are added to the original data frame.


#### Mapping geocoded data

To map the geocoded data, you’ll need a data frame containing participant data. GPE includes “participants”, an example data frame with fictional public program beneficiaries. The geographic position of participants and program locations can be plotted, over a basemap, using:

`GPE_plot_map(participants)`

<p align="left">
  <img height="300" src="https://github.com/EL-BID/GPE/blob/master/man/img/plot_map_participants.PNG">
</p>

In order for `GPE_plot_map()` to work, the input data frame must include columns named “lat” and “lon” representing WGS84 coordinates. As previously shown, latitude and longitude columns can be obtained from addresses using `GPE_geocode()`.

In addition, a data frame containing locations -places that participants visit in order to interact with the program, such as training centers, day care providers, etc.- can also be mapped. GPE includes “locations”, an example data frame with fictional public program sites. This dummy data can be used as follows to generate a more detailed map:

`GPE_plot_map(participants, locations)`

<p align="left">
  <img height="300" src="https://github.com/EL-BID/GPE/blob/master/man/img/plot_map_par_loc.PNG">
</p>

You can also visualize participant attributes by indicating the name of the column that should be used:

`GPE_plot_map(participants, locations, participant_attribute = "group")`

<p align="left">
  <img height="300" src="https://github.com/EL-BID/GPE/blob/master/man/img/plot_map_bygroup.PNG">
</p>

The same can be done for location attributes…

`GPE_plot_map(participants, locations, location_attribute = "type")`

<p align="left">
  <img height="300" src="https://github.com/EL-BID/GPE/blob/master/man/img/plot_map_loc_att.PNG">
</p>

… or both participant and location attributes:

`GPE_plot_map(participants, locations, participant_attribute = "group", location_attribute = "type")`

<p align="left">
  <img height="300" src="https://github.com/EL-BID/GPE/blob/master/man/img/plot_map_bygroup_loc_att.PNG">
</p>


#### Estimating travel distance and time

Using records of interaction between people and places -representing trips by consumers/beneficiaries to points of sale/access- GPE can estimate time and distance travelled with the Google Maps Platform. As is the case with geocoding, a valid API key is needed to access this service.

GPE provides an example “visits” data frame:

`visits`

                    date            participant_id   location_id             
                1   2018-07-22      5786             71
                2   2018-06-29      804              5
                3   2018-11-08      6880             76
                4   2018-03-29      834              6
                5   2018-05-31      2643             67


Trip distance and duration can be obtained using GPE_travel_time_dist(). As inputs, the function uses visits data, and the locations and participants data frames to provide the origin and destination coordinates. The mode of transport can be chosen from “transit” (default), “driving”, “walking”, or “bicycling”. Keep in mind that transit routing information is not available for all cities; “driving” and “walking” routing is usually available everywhere.

`GPE_travel_time_dist(visits, participants, locations, key)`

                    date            participant_id   location_id    time_minutes   distance_km  mode        
                1   2018-03-29      834              6              17.38333       2.317        transit
                2   2018-05-31      2643             67             39.35000       5.511        transit
                3   2018-06-12      3395             61             39.80000       8.816        transit
                4   2018-06-29      804              5              36.20000      10.664        transit
                5   2018-07-22      5786             71             21.75000       2.303        transit



#### Summaries

GPE includes a simple summary function that takes a “visits” data frame, as described above, and returns basic descriptive statistics for: 
o	frequency of visits, by participant (person)
o	frequency of visits, by location (site)

If the input data frame includes time_minutes and distance_km columns (i.e. as a result of using `GPE_travel_time_dist())` the summary will also include basic descriptive statistics for

o	travel time, in minutes
o	travel distance, in km

For example, given a data frame like: 

                    date            participant_id   location_id    time_minutes   distance_km  mode        
                1   2018-03-29      834              6              17.38333       2.317        transit
                2   2018-05-31      2643             67             39.35000       5.511        transit
                3   2018-06-12      3395             61             39.80000       8.816        transit
                4   2018-06-29      804              5              36.20000      10.664        transit
                5   2018-07-22      5786             71             21.75000       2.303        transit

... the result is:

`GPE_summary(visits_timedist)`

        $`visits by participant`
           Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
           4.000   5.750   6.500   7.312   8.250  13.000 

        $`visits by location`
           Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
          1.000   3.000   4.000   4.255   6.000  10.000 

        $`travel time (minutes)` 
          Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
          6.30   29.00   40.16   40.53   50.27  102.17 

        $`travel distance (km)`
          Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
         0.576   5.122   8.897   9.165  12.921  28.855
            

## Installation guide

    install.packages("devtools")
    devtools::install_github("EL-BID/GPE")


#### Dependencies

GPE depends on the following packages:

`ggmap`


Some funcitons in GPE will also require a Google API key. A key can be created [here](https://cloud.google.com/maps-platform/).  For more information, use the R command `?ggmap::register_google`. 

## How to contribute
For all contributions to this project, this repository may be forked directly.

## Authors

GPE was developed by [H. Antonio Vazquez Brust](https://ar.linkedin.com/in/avazquez)


## License

The Documentation of Support and Use of the software is licensed under Creative Commons IGO 3.0 Attribution-NonCommercial-NoDerivative (CC-IGO 3.0 BY-NC-ND)

The codebase of this repo uses [AM-331-A3 Software License](https://github.com/EL-BID/GPE/blob/master/LICENSE.md).


## Limitation of responsibilities
The IDB is not responsible, under any circumstance, for damage or compensation, moral or patrimonial; direct or indirect; accessory or special; or by way of consequence, foreseen or unforeseen, that could arise:

I. Under any concept of intellectual property, negligence or detriment of another part theory; I

ii. Following the use of the Digital Tool, including, but not limited to defects in the Digital Tool, or the loss or inaccuracy of data of any kind. The foregoing includes expenses or damages associated with communication failures and / or malfunctions of computers, linked to the use of the Digital Tool.
