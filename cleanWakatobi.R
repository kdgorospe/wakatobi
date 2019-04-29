# R script for Wakatobi socio-economic data cleaning
# Contact: Austin Humphries, Paul Carvalho, Kelvin Gorospe, Lauren Josephs


### STEP ONE: set your preferred working directory using setwd() in console
### setwd("~/Analyses/wakatobi")

rm(list=ls())
library(googledrive)


### GET DATA AND CREATE SUMMARY TABLES
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
# Column: Fish_name_p has the most number of categories; Clean this column first and create the other columns (Genus, Spp1, Spp2 based on this)

### SPELL CHECK FISH NAMES
# NEXT: Run landings$Fish_name_p through check.spelling function:
# Select spelling with capitalized first letter as the "correct" spelling
# Use key.csv for correct spellings 
# If still unsure, use table_rawData_FishNames.csv to choose more common spelling
source("wakatobi/check_spelling.R")

# First try distance_sensitivity=1
#cleandist1<-check.spelling(df_in = landings, var_name = Fish_name_p, distance_sensitivity = 1)
#write.csv(cleandist1, file="data_landings_041119_FISH_checkspelling_dist1.csv", quote=FALSE, row.names=FALSE)
#cleandist1a<-check.spelling(df_in = cleandist1, var_name = Fish_name_p, distance_sensitivity = 1)
#write.csv(cleandist1a, file="data_landings_041119_FISH_checkspelling_dist1a.csv", quote=FALSE, row.names=FALSE)

# Now try distance_sensitivity = 2
#cleandist2<-check.spelling(df_in = cleandist1a, var_name = Fish_name_p, distance_sensitivity = 2)
#write.csv(cleandist2, file="data_landings_041119_FISH_checkspelling_dist2.csv", quote=FALSE, row.names=FALSE)
#cleandist2a<-check.spelling(df_in = cleandist2, var_name = Fish_name_p, distance_sensitivity = 2)
#write.csv(cleandist2a, file="data_landings_041119_FISH_checkspelling_dist2a.csv", quote=FALSE, row.names=FALSE)

# CLEANING NOTES: DO NOT DELETE!
#dist=1
#Chose "Banguntu" (more common) over "Baguntu"
#Keapu Coklat over Keapu Cokelat
#Keapu Loong Ngaluhu over Keapu Loong Nyaluhu
#Luppe over Kuppe
#Mangilala over Mangialo and Mangilalo

#dist=2
#Kept both Bukalang and Bulealang (labeled as "Unknown" in key.csv)
#Kept both Dodoh Batu and Mogoh Batu
#Keapu Bitte Mira over Keapu Bitti Mirah
#Kept Keapu Nyarengelah, Keapu Nyarengluh, Keapu Nyarengkeh
#Kept Keapu Goas and Keapu Garas
#Mogo Nyulloh over Mogoh Nyuluh
#Kept Mogoh Birrah, Mogoh Borra, and Mogoh Birro
#Kept both Taburoh and Taboh (labeled as "Unknown" in key.csv)
#Kept both Tatape Buna and Tatape Bulan

cleandist1<-read.csv("data_landings_041119_FISH_checkspelling_dist1.csv")
write.csv(as.data.frame(table(cleandist1$Fish_name_p)), "table_cleandist1_FishNames.csv")
cleandist1a<-read.csv("data_landings_041119_FISH_checkspelling_dist1a.csv")
write.csv(as.data.frame(table(cleandist1a$Fish_name_p)), "table_cleandist1a_FishNames.csv")
cleandist2<-read.csv("data_landings_041119_FISH_checkspelling_dist2.csv")
write.csv(as.data.frame(table(cleandist2$Fish_name_p)), "table_cleandist2_FishNames.csv")
cleandist2a<-read.csv("data_landings_041119_FISH_checkspelling_dist2a.csv")
write.csv(as.data.frame(table(cleandist2a$Fish_name_p)), "table_cleandist2a_FishNames.csv")

landings<-cleandist2a

### MERGE fish and trip data
dim(landings)
dim(trips)

mergecol<-names(landings)[names(landings) %in% names(trips)]
write.csv(as.data.frame(table(trips$trip_id)), "table_tripID.csv") 
tempdat<-merge(landings, trips, by=mergecol)

### Convert trip time to single standardized unit (USE: HOURS)
table(tempdat$Trip_time_unit) # levels = day, days, hour, hours
tempdat$Trip_time_unit[grep("day", tempdat$Trip_time_unit)]<-"d"
tempdat$Trip_time_unit[grep("hour", tempdat$Trip_time_unit)]<-"h"
tempdat$Trip_time_hours<-tempdat$Trip_time_no
tempdat<-transform(tempdat, Trip_time_hours=ifelse(Trip_time_unit=="d", Trip_time_hours*24, Trip_time_hours))

## Just an UPDATE and GITHUB TEST
## Turns out my box/basket to fish conversion from past data cleaning
## Did not include weight - it was just 1 box = 520 fish individuals
## We'll need to get some estimate of how many kg 1 fish represented from Melati - LJ
