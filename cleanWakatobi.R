# R script for Wakatobi socio-economic data cleaning
# Contact: Austin Humphries, Paul Carvalho, Kelvin Gorospe, Lauren Josephs


### STEP ONE: set your preferred working directory using setwd() in console
### setwd("~/Analyses")

rm(list=ls())
library(googledrive)


# Download raw data files from SHERA google drive folder
drive_auth() # Will require you to sign into Google account and grant permission to tidyverse for access 
#drive_download("Wakatobi-landings_041119_FISH.csv", type="csv", overwrite=TRUE)  # saves file locally; overwrite in case you've downloaded it before and want the most up-to-date
#file id: 1_71pviN-qsSmvAZAgQMCQIqkEXpKTPcd
#Use File ID method: more specific file identification
drive_download(as_id("1_71pviN-qsSmvAZAgQMCQIqkEXpKTPcd"), overwrite=TRUE) # Saves file to working directory
landings<-read.csv("Wakatobi-landings_041119_FISH.csv", header=T, stringsAsFactors = FALSE, strip.white = TRUE)


#drive_download("Wakatobi-landings_041119_TRIP.csv", overwrite=TRUE)
#file id: 1lVYpdmf8i0BZYbK5iQxXn2eFR1klxWbC
drive_download(as_id("1lVYpdmf8i0BZYbK5iQxXn2eFR1klxWbC"), overwrite=TRUE) 
trips<-read.csv("Wakatobi-landings_041119_TRIP.csv", header=T, stringsAsFactors = FALSE, strip.white = TRUE)


# Clean fish names in landings data frame using Paul's checkspelling.R script           
# Output table of current fish names for comparison
write.csv(as.data.frame(table(landings$Fish_name_p)), file="table_rawData_FishNames.csv", quote=FALSE)
write.csv(as.data.frame(table(landings$Bajau_genus)), file="table_rawData_BajauGenus.csv", quote=FALSE)
write.csv(as.data.frame(table(landings$Bajau_spp_p1)), file="table_rawData_BajauSpp1.csv", quote=FALSE)
write.csv(as.data.frame(table(landings$Bajau_spp_p2)), file="table_rawData_BajauSpp2.csv", quote=FALSE)
# Column: Fish_name_p has the most number of categories; Clean this column only and create the other columns (Genus, Spp1, Spp2 based on this)


# NEXT: Run landings$Fish_name_p through check.spelling function:
# Select spelling with capitalized first letter as the "correct" spelling
source("wakatobi/check_spelling.R")
cleandist1<-check.spelling(df_in = landings, var_name = Fish_name_p, distance_sensitivity = 1)
# write.csv(cleandist1, file="data_landings_041119_FISH_checkspelling_dist1_.csv", quote=FALSE, row.names=FALSE)

# Cleaning notes fo Melati (DO NOT DELETE):
# Waiting for Melati to respond with most updated species names list



### Attempt to merge landings and trips
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


