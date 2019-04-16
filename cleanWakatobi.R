# R script for Wakatobi socio-economic data cleaning
# Contact: Austin Humphries, Paul Carvalho, Kelvin Gorospe, Lauren Josephs


### STEP ONE: set your preferred working directory using setwd() in console


rm(list=ls())
library(googledrive)


# Download raw data files from SHERA google drive folder
drive_auth() # Will require you to sign into Google account and grant permission to tidyverse for access 
drive_download("Wakatobi-fish-data_041119.csv", overwrite=TRUE)  # saves file locally; overwrite in case you've downloaded it before and want the most up-to-date
landings<-read.csv("Wakatobi-fish-data_041119.csv", header=T, stringsAsFactors = FALSE, strip.white = TRUE)


drive_download("Wakatobi-trip-data_041119.csv", overwrite=TRUE)
trips<-read.csv("Wakatobi-trip-data_041119.csv", header=T, stringsAsFactors = FALSE, strip.white = TRUE)


dim(landings)
dim(trips)

mergecol<-names(landings)[names(landings) %in% names(trips)]

tempdat<-merge(landings, trips, by=mergecol)

# Questions for Melati?
# table(trips$trip_id) # why are some trip_IDs not unique? 
tempdat[tempdat$trip_id=="1 11 ACER + DULETES",]
tempdat[tempdat$Fish_name_p=="Kumai",]
# TESTING HOW QUICK IT PUSHES
