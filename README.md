# Georeferenced Program Evaluation

## Description and context

The R package GPE (Georeferenced Program Evaluation), includes functions that will allow the user to study various aspects of consumer or beneficiary behavior, including:

i.      Georeference postal addresses (converting street name and number to latitude and longitude points)

ii.     Obtain base maps of any city’s urban grid and visualize overlaid projections of the distance traveled (between participants’ homes and points of service accessed, for example)

iii.	Estimate a matrix of distances between sites accessed and consumer/beneficiary origin

iv.	    Calculate metrics of frequency, distribution by group, and distance travelled by consumers/beneficiaries to points of sale/access
    
v.	    Create visualizations that explore the difference between frequency and type of consumption by consumer/beneficiary attribute (depending on the information available: socioeconomic status, length of program participation, type of program participation, etc)



## User guide

## Installation guide

Use:
-----------
    install.packages("devtools")
    devtools::install_github("EL-BID/GPE")


#### Dependencies

GPE depends on the following packages:

`ggmap`
`sf`
`knitr`

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
