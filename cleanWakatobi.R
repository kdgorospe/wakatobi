# R script for Wakatobi socio-economic data cleaning
# Contact: Austin Humphries, Paul Carvalho, Kelvin Gorospe, Lauren Josephs


### STEP ONE: set your preferred working directory using setwd() in console
### setwd("~/Analyses")

rm(list=ls())
library(googledrive)


# Download raw data files from SHERA google drive folder
drive_auth() # Will require you to sign into Google account and grant permission to tidyverse for access 
drive_download("Wakatobi-landings_041119_FISH.csv", type="csv", overwrite=TRUE)  # saves file locally; overwrite in case you've downloaded it before and want the most up-to-date
landings<-read.csv("Wakatobi-landings_041119_FISH.csv", header=T, stringsAsFactors = FALSE, strip.white = TRUE)


drive_download("Wakatobi-landings_041119_TRIP.csv", overwrite=TRUE)
trips<-read.csv("Wakatobi-landings_041119_TRIP.csv", header=T, stringsAsFactors = FALSE, strip.white = TRUE)


dim(landings)
dim(trips)

mergecol<-names(landings)[names(landings) %in% names(trips)]

tempdat<-merge(landings, trips, by=mergecol)

# table(trips$trip_id) # why are some trip_IDs not unique? 
tempdat[tempdat$trip_id=="1 11 ACER + DULETES",]

# Convert trip time to single standardized unit (USE: HOURS)
table(tempdat$Trip_time_unit) # levels = day, days, hour, hours
tempdat$Trip_time_unit[grep("day", tempdat$Trip_time_unit)]<-"d"
tempdat$Trip_time_unit[grep("hour", tempdat$Trip_time_unit)]<-"h"
tempdat$Trip_time_hours<-tempdat$Trip_time_no
tempdat<-transform(tempdat, Trip_time_hours=ifelse(Trip_time_unit=="d", Trip_time_hours*24, Trip_time_hours))
# PRACTICE EDITING DIFFERENT SECTIONS OF THE CODE


## Kelly is my favorite lab mascot - Lauren 

# Paul's doing all of this data cleaning for us

# paul's comment
kelvin = "kelly's dad"


kelvin<-strsplit(kelvin, " ")
kelvin[[1]][grep("dad", kelvin)]<-"cool dude"

