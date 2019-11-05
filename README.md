# Georeferenced Program Evaluation

## Description and context

The R package GPE (Georeferenced Program Evaluation), includes functions that will allow the user to study various aspects of consumer or beneficiary behavior, including:

i.      Georeference postal addresses (converting street name and number to latitude and longitude points)

ii.     Obtain base maps of any city’s urban grid and visualize overlaid projections of the distance traveled (between participants’ homes and points of service accessed, for example)

iii.	Estimate a matrix of distances between sites accessed and consumer/beneficiary origin

iv.	    Calculate metrics of frequency, distribution by group, and distance travelled by consumers/beneficiaries to points of sale/access
    
v.	    Create visualizations that explore the difference between frequency and type of consumption by consumer/beneficiary attribute (depending on the information available: socioeconomic status, length of program participation, type of program participation, etc)



## User guide
### Basic usage

You'll need a .csv file containing program participant data, including at least columns "lon" and "lat", containing WG84 (Mercator) location coordinates.

### Example

Having a "participants" dataframe such as

`
participants <- read.csv("../data/participants.csv")

head(participants)

   participant_id     group       lon       lat income_bracket

               1   control -58.50748 -34.64797              4
 
               2 treatment -58.43973 -34.60032              6
 
               3 treatment -58.45209 -34.55733              9
 
               4 treatment -58.44180 -34.58304              8
 
               5 treatment -58.50082 -34.61289              4
 
               6 treatment -58.50189 -34.66374              1
`


And another dataframe containing the Program sites, such as:

`
locations <- read.csv("../data/locations.csv")

head(locations)

   location_id type       lon       lat
   
            1    A -58.37705 -34.62262
 
            2    A -58.38254 -34.61850
 
            3    A -58.38409 -34.61999
 
            4    A -58.39352 -34.62451
 
            5    A -58.38914 -34.62843
 
            6    A -58.39476 -34.62932
`


Then the geographic position of participants and program locations can be plotted, on top of a basemap, with:

    library(GPE)
    GPE_plot_map(participants, locations)

<p align="center">
  <img width="300" src="https://github.com/EL-BID/GPE/blob/master/img/plot_map_example.PNG">
</p>



## Installation guide

    install.packages("devtools")
    devtools::install_github("EL-BID/GPE")


#### Dependencies

GPE depends on the following packages:

`ggmap`

`sf`


Some funcitons in GPE will also require a Google API key. A key can be created [here](https://cloud.google.com/maps-platform/).  For more information, use the R command `?register_google`. 

## How to contribute
For all contributions to this project, this repository may be forked directly.

## Authors

GPE was developed by [H. Antonio Vazquez Brust](https://ar.linkedin.com/in/avazquez)


## License
[GNU General Public License v3.0](https://github.com/EL-BID/GPE/blob/master/LICENSE)

The Documentation of Support and Use of the software is licensed under Creative Commons IGO 3.0 Attribution-NonCommercial-NoDerivative (CC-IGO 3.0 BY-NC-ND)

The codebase of this repo uses [AM-331-A3 Software License](https://github.com/IDB-HUD/Housing_Deficit/blob/master/LICENSE.md).


## Limitation of responsibilities
The IDB is not responsible, under any circumstance, for damage or compensation, moral or patrimonial; direct or indirect; accessory or special; or by way of consequence, foreseen or unforeseen, that could arise:

I. Under any concept of intellectual property, negligence or detriment of another part theory; I

ii. Following the use of the Digital Tool, including, but not limited to defects in the Digital Tool, or the loss or inaccuracy of data of any kind. The foregoing includes expenses or damages associated with communication failures and / or malfunctions of computers, linked to the use of the Digital Tool.
