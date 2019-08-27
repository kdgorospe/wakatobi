# R script for Wakatobi socio-economic data cleaning
# Contact: Austin Humphries, Paul Carvalho, Kelvin Gorospe, Lauren Josephs, Melati Kaye


### STEP ONE: setwd() to local repository
### setwd("~/Analyses/wakatobi")

rm(list=ls())
library(googledrive)
library(dplyr)
library(tidyr)

### GET DATA AND CREATE SUMMARY TABLES
# Download raw data files from SHERA google drive folder
#drive_auth() # Will require you to sign into Google account and grant permission to tidyverse for access 
#drive_download("Wakatobi-landings_041119_FISH.csv", type="csv", overwrite=TRUE)  # saves file locally; overwrite in case you've downloaded it before and want the most up-to-date
#file id: 1_71pviN-qsSmvAZAgQMCQIqkEXpKTPcd
#Use File ID method: more specific file identification
#drive_download(as_id("1_71pviN-qsSmvAZAgQMCQIqkEXpKTPcd"), overwrite=TRUE) # Saves file to working directory
#landings<-read.csv("Wakatobi-landings_041119_FISH.csv", header=T, stringsAsFactors = FALSE, strip.white = TRUE)

# NOTES on cleaning TRIP IDs: 

# A: Most duplicate trip IDs were identical rows of data: Deleted duplicates

# B: For duplicate trip IDs that were non-unique:
# try to coroborate data with raw data sheets
# use date to track down raw data file
# if this doesn't work, search by "captain name"
# if can't find raw data sheet, keep all trips for now
# Changes:
# 1 25 SIDDENG - kept data row with "bulawis" as dominant species

# C: Could not find raw data sheets for the following trips:
# 1 11 DAHLAN
# 1 11 ACER + DULETES - couldn't find raw data sheet !!!! (still need to address this)
# 11 20 BAGON - couldn't find raw data sheet !!!! (still need to address this)

# D: Deleted all trip IDs with missing dates
# Checked all of these and found them to be duplicate rows after adding dates to tripID
# SAVED AS "Wakatobi-landings_062019_TRIP-CLEAN.csv"

# OLD trips file
#file id: 1lVYpdmf8i0BZYbK5iQxXn2eFR1klxWbC
#drive_download(as_id("1lVYpdmf8i0BZYbK5iQxXn2eFR1klxWbC"), overwrite=TRUE)
#trips<-read.csv("Wakatobi-landings_04119_TRIP.csv", header=T, stringsAsFactors = FALSE, strip.white = TRUE)
#write.csv(as.data.frame(table(trips$trip_id)), "table_tripID_04119.csv") 



# Clean fish names in landings data frame using Paul's checkspelling.R script           
# Output table of current fish names for comparison
#write.csv(as.data.frame(table(landings$Fish_name_p)), file="table_rawData_FishNames.csv", quote=FALSE)
#write.csv(as.data.frame(table(landings$Bajau_genus)), file="table_rawData_BajauGenus.csv", quote=FALSE)
#write.csv(as.data.frame(table(landings$Bajau_spp_p1)), file="table_rawData_BajauSpp1.csv", quote=FALSE)
#write.csv(as.data.frame(table(landings$Bajau_spp_p2)), file="table_rawData_BajauSpp2.csv", quote=FALSE)
# Column: Fish_name_p has the most number of categories; Clean this column first and create the other columns (Genus, Spp1, Spp2 based on this)

### SPELL CHECK FISH NAMES
# NEXT: Run landings$Fish_name_p through check.spelling function:
# Select spelling with capitalized first letter as the "correct" spelling
# Use key.csv for correct spellings 
# If still unsure, use table_rawData_FishNames.csv to choose more common spelling
#source("check_spelling.R")

# First try distance_sensitivity=1
#cleandist1<-check.spelling(df_in = landings, var_name = Fish_name_p, distance_sensitivity = 1)
#write.csv(cleandist1, file="data_landings_041119_FISH_checkspelling_dist1.csv", quote=FALSE, row.names=FALSE)
#cleandist1a<-check.spelling(df_in = cleandist1, var_name = Fish_name_p, distance_sensitivity = 1)
#write.csv(cleandist1a, file="data_landings_041119_FISH_checkspelling_dist1a.csv", quote=FALSE, row.names=FALSE)

# Now try distance_sensitivity = 2
#cleandist2<-check.spelling(df_in = cleandist1a, var_name = Fish_name_p, distance_sensitivity = 2)
#write.csv(cleandist2, file="data_landings_061819_FISH_checkspelling_dist2.csv", quote=FALSE, row.names=FALSE)
#cleandist2a<-check.spelling(df_in = cleandist2, var_name = Fish_name_p, distance_sensitivity = 2)
#write.csv(cleandist2a, file="data_landings_061819_FISH_checkspelling_dist2a.csv", quote=FALSE, row.names=FALSE)

# CLEANING NOTES (DO NOT DELETE): for names that I was unsure of - i.e., couldn't decide on spelling even after inspecting key.csv
# Which spelling is kept is arbitrary - what matters is whether or not the names are for the same or different things
# The following decisions were confirmed based on consulting with Melati Kaye
#dist=1
#Chose: "Banguntu" (more common) over "Baguntu"
#Keapu Coklat over Keapu Cokelat
#Keapu Loong Ngaluhu over Keapu Loong Nyaluhu
#Luppe over Kuppe
#Mangilala over Mangialo and Mangilalo

#dist=2
#Kept both Bukalang and Bulealang (labeled as "Unknown" in key.csv)
#Kept both Dodoh Batu and Mogoh Batu
#Keapu Bitte Mira over Keapu Bitti Mirah
#Keapu Nyarengelah over Keapu Nyarengluh; Kept Keapu Nyarengkeh separate from both Nyarengelah and Nyarengluh
#Kept both Keapu Goas and Keapu Garas - Note: still not sure whether these are the same or different species
#Mogo Nyulloh over Mogoh Nyuluh
#Mogoh Birrah over Mogoh Borra and Mogoh Birro
#Kept both Pogo and Popogo (triggerfish and smaller triggerfish) - these are two different Bajau words (not spelling errors), so keeping both
#Kept both Taburoh and Taboh (labeled as "Unknown" in key.csv)
#Kept both Tatape Buna and Tatape Bulan

# OUTPUT TABLE OF CLEANED FISH NAMES
#cleandist1<-read.csv("data_landings_041119_FISH_checkspelling_dist1.csv")
#write.csv(as.data.frame(table(cleandist1$Fish_name_p)), "table_cleandist1_FishNames.csv")
#cleandist1a<-read.csv("data_landings_041119_FISH_checkspelling_dist1a.csv")
#write.csv(as.data.frame(table(cleandist1a$Fish_name_p)), "table_cleandist1a_FishNames.csv")
#cleandist2<-read.csv("data_landings_061819_FISH_checkspelling_dist2.csv")
#write.csv(as.data.frame(table(cleandist2$Fish_name_p)), "table_cleandist2_FishNames.csv")
#cleandist2a<-read.csv("data_landings_061819_FISH_checkspelling_dist2a.csv") 
#write.csv(as.data.frame(table(cleandist2a$Fish_name_p)), "table_cleandist2a_FishNames.csv")

# READ IN latest CLEANED fish landings file here:
drive_auth() # Will require you to sign into Google account and grant permission to tidyverse for access 
drive_download(as_id("10-ERWTJI2SZS0ljP9noprFhmKU0sjDBN"), overwrite=TRUE) # Saves file to working directory
landings<-read.csv("Wakatobi-landings_061819_FISH.csv") 
file.remove("Wakatobi-landings_061819_FISH.csv")

# READ IN latest CLEANED trips file here:
#file id: 1gL7_gUFYUtETEVDBlNQ3FN7Ddt04AIsP
drive_download(as_id("1gL7_gUFYUtETEVDBlNQ3FN7Ddt04AIsP"), overwrite=TRUE) 
trips<-read.csv("Wakatobi-landings_062019_TRIP.csv", header=T, stringsAsFactors = FALSE, strip.white = TRUE)
file.remove("Wakatobi-landings_062019_TRIP.csv")


### MERGE fish and trip data
dim(landings)
dim(trips)

mergecol<-names(landings)[names(landings) %in% names(trips)]
tempdat<-merge(landings, trips, by=mergecol)

### Convert trip time to single standardized unit (USE: HOURS)
table(tempdat$Trip_time_unit) # levels = day, days, hour, hours
tempdat$Trip_time_unit[grep("day", tempdat$Trip_time_unit)]<-"d"
tempdat$Trip_time_unit[grep("hour", tempdat$Trip_time_unit)]<-"h"
tempdat$Trip_time_hours<-tempdat$Trip_time_no
tempdat<-transform(tempdat, Trip_time_hours=ifelse(Trip_time_unit=="d", Trip_time_hours*24, Trip_time_hours))

### Convert landings units (boxes, baskets, ekor) to biomass (kg)
# Instead of doing this for each column of units, use gsub() to make the substitution and apply() to do this across the entire dataframe
tempdat <- as.data.frame(apply(tempdat, 2, function(y) gsub("smal box", "small box", y)))
tempdat <- as.data.frame(apply(tempdat, 2, function(y) gsub("box kecil", "small box", y)))
tempdat <- as.data.frame(apply(tempdat, 2, function(y) gsub("ekor", "fish", y)))
tempdat <- as.data.frame(apply(tempdat, 2, function(y) gsub("bucket kecil", "small bucket", y)))
tempdat$landing_no <- as.numeric(as.character((tempdat$landing_no)))
# Create empty column for the conversion calculation
tempdat$landing_unit_fish <- "NA"
# Create empty column for the conversion to kilograms (see calibration table from Melati)
tempdat$landing_unit_convert <- "NA"
# Set conversion units here, this way if we need to modify the numbers we only need to change in one place
box          <- 58
basket       <- 16
small_box    <- 19
bucket       <- 14
small_bucket <- 7
fish         <- NA
tempdat$landing_unit_convert[tempdat$landing_unit == "box"] <- box
tempdat$landing_unit_convert[tempdat$landing_unit == "basket"] <- basket
tempdat$landing_unit_convert[tempdat$landing_unit == "small box"] <- small_box
tempdat$landing_unit_convert[tempdat$landing_unit == "bucket"] <- bucket
tempdat$landing_unit_convert[tempdat$landing_unit == "small bucket"] <- small_bucket 
tempdat$landing_unit_convert[tempdat$landing_unit == "fish"] <- fish
# Need to use length-weight conversion to calculate kg when "fish" is the landing unit
# Then multiply landing_no by landing_unit_convert to get all landing totals in units of biomass (landing_unit_fish)
tempdat$landing_unit_fish <- tempdat$landing_no * as.numeric(as.character(tempdat$landing_unit_convert))

### Convert landings flow units to individual fish units and check for 100% fish flow reported
# LEARNING OPPORTUNITY for Lauren:: what is a more efficient way to make these substitutions for all relevant landings columns?
# As of now, I do them one at a time

#tempdat$landings_flow_convert <- "NA"
#drop <- c("landings_flow_convert")
#tempdat <- tempdat[ , !(names(tempdat) %in% drop)]
tempdat$landings_sold_personally_convert <- "NA"
tempdat$landings_sold_personally_no <- as.numeric(as.character(tempdat$landings_sold_personally_no))
tempdat$landings_sold_personally_convert[tempdat$landings_sold_personally_unit == "basket"] <- basket
tempdat$landings_sold_personally_convert[tempdat$landings_sold_personally_unit == "box"] <- box
tempdat$landings_sold_personally_convert[tempdat$landings_sold_personally_unit == "bucket"] <- bucket
tempdat$landings_sold_personally_convert[tempdat$landings_sold_personally_unit == "fish"] <- fish

tempdat$landings_sold_Papalele_convert <- "NA"
tempdat$landings_sold_Papalele_no <- as.numeric(as.character(tempdat$landings_sold_Papalele_no))
tempdat$landings_sold_Papalele_convert[tempdat$landings_sold_Papalele_unit == "basket"] <- basket
tempdat$landings_sold_Papalele_convert[tempdat$landings_sold_Papalele_unit == "box"] <- box
tempdat$landings_sold_Papalele_convert[tempdat$landings_sold_Papalele_unit == "bucket"] <- bucket
tempdat$landings_sold_Papalele_convert[tempdat$landings_sold_Papalele_unit == "fish"] <- fish

tempdat$landings_sold_Pengumpul_convert <- "NA"
tempdat$landings_sold_Pengumpul_no <- as.numeric(as.character(tempdat$landings_sold_Pengumpul_no))
tempdat$landings_sold_Pengumpul_convert[tempdat$landings_sold_Pengumpul_unit == "basket"] <- basket
tempdat$landings_sold_Pengumpul_convert[tempdat$landings_sold_Pengumpul_unit == "box"] <- box
tempdat$landings_sold_Pengumpul_convert[tempdat$landings_sold_Pengumpul_unit == "bucket"] <- bucket
tempdat$landings_sold_Pengumpul_convert[tempdat$landings_sold_Pengumpul_unit == "fish"] <- fish

tempdat$landings_eaten_convert <- "NA"
tempdat$landings_eaten_no <- as.numeric(as.character(tempdat$landings_eaten_no))
tempdat$landings_eaten_convert[tempdat$landings_eaten_unit == "basket"] <- basket
tempdat$landings_eaten_convert[tempdat$landings_eaten_unit == "box"] <- box
tempdat$landings_eaten_convert[tempdat$landings_eaten_unit == "bucket"] <- bucket
tempdat$landings_eaten_convert[tempdat$landings_eaten_unit == "fish"] <- fish

tempdat$landings_given_convert <- "NA"
tempdat$landings_given_no <- as.numeric(as.character(tempdat$landings_given_no))
tempdat$landings_given_convert[tempdat$landings_given_unit == "basket"] <- basket
tempdat$landings_given_convert[tempdat$landings_given_unit == "box"] <- box
tempdat$landings_given_convert[tempdat$landings_given_unit == "bucket"] <- bucket
tempdat$landings_given_convert[tempdat$landings_given_unit == "fish"] <- fish

# Will need to add in more conversion values when we get them from Melati
# Next: check that landings flow columns add up to total landings for each trip (100% flow reported)


### Clean fishing gear variable
# Create two columns for fishing gear - one for general gear category (cat1) and another for specific gear (cat2), particularly for nets.
tempdat$gear_cat1 <- as.character(tempdat$gear)
tempdat$gear_cat1 <- gsub("dblnetspr|Dblnspr|Doublenet|dblnet|Net|Netspr","net", tempdat$gear_cat1)
tempdat$gear_cat1 <- gsub("Spear","spear", tempdat$gear_cat1)
tempdat$gear_cat1 <- gsub("Handline|handline","line", tempdat$gear_cat1)
tempdat$gear_cat2 <- as.character(tempdat$gear)
tempdat$gear_cat2 <- gsub("dblnetspr|Dblnspr|Doublenet|dblnet","double net",tempdat$gear_cat2)
tempdat$gear_cat2 <- gsub("Net|Netspr|^net","single net",tempdat$gear_cat2)
tempdat$gear_cat2 <- gsub("Spear","spear", tempdat$gear_cat2)
tempdat$gear_cat2 <- gsub("Handline|handline","line", tempdat$gear_cat2)

### Clean fishing ground names
# make all characters in each column lower case
tempdat <- tempdat %>%
     mutate(fishing_grnd1 = tolower(.$fishing_grnd1)) %>%
     mutate(fgnd1_p = tolower(.$fgnd1_p))
# Create a temporary dataframe for manipulation
tmp <- tempdat
# Create a single verctor with names for the first fishing ground
fishing_ground_1 <- NULL
for(i in 1:length(tmp$fishing_grnd1)){
  if(tmp$fishing_grnd1[i] == tmp$fgnd1_p[i]){
    fishing_ground_1[i] <- tmp$fishing_grnd1[i]
  } else if(tmp$fishing_grnd1[i]=="" & tmp$fgnd1_p[i]!=""){
    fishing_ground_1[i] <- tmp$fgnd1_p[i]
  } else if(tmp$fishing_grnd1[i]!="" & tmp$fgnd1_p[i]==""){
    fishing_ground_1[i] <- tmp$fishing_grnd1[i]
  } else {
    fishing_ground_1[i] <- NA
  }
}
# sum(is.na(fishing_ground_1))
# Create a new column for cleaned fishing ground column
tempdat$fishing_ground_1 <- fishing_ground_1
# assign aggregated fishing ground names
fishing_ground_key <- read.csv("keys/fishing_grounds_key.csv")
names(fishing_ground_key)[1] <- "fishing_ground_1"
tempdat <- merge(tempdat,fishing_ground_key,by="fishing_ground_1",all.x=TRUE,all.y=FALSE)

### Clean fish name columns
# Just copy and paste from first column into the second if blank or vice versa
tempdat$Fish_name_p <- as.character(tempdat$Fish_name_p)
tempdat$Bajau_genus <- as.character(tempdat$Bajau_genus)
for(i in 1:length(tempdat$Fish_name_p)){
  if(tempdat$Fish_name_p[i] == "" & tempdat$Bajau_genus[i] != ""){
    tempdat$Fish_name_p[i] <- tempdat$Bajau_genus[i[]]
  } else if (tempdat$Bajau_genus[i] == "" & tempdat$Fish_name_p[i] != ""){
    tempdat$Bajau_genus[i] <- tempdat$Fish_name_p[i]
  }
  # else do nothing
}


### Clean up tempdat dataframe to remove unnecessary columns
tempdat_1 <- tempdat %>%
  filter(!is.na(.$new_fg)) %>% # 397 rows are missing fishing ground
  mutate(Fish_name_p = tolower(Fish_name_p)) %>%
  dplyr::select(date = Date, captain_name = Capt_name, trip_id, fishing_ground = new_fg, engine = Engine, crew_no, season = Season, trip_time_hours = Trip_time_hours,
                gear_cat1, gear_cat2, landing_no, landing_unit_fish, landing_unit_convert, # did not include the fish flow information
                depth = max_fish_depth, dominant_catch = dominant_spp1, total_revenue = gross_profit_IDR, 
                bajau_name = Fish_name_p, size_cm = Ukuran) %>%
  mutate(size_cm = as.numeric(as.character(size_cm)))



# Need to cross reference names entered in the data with names in the fish key
fish_id_key <- read.csv("keys/fish_id_key_2.csv")

fish_id_key <- fish_id_key %>%
  dplyr::select(bajau_name, family, species) %>%
  mutate(bajau_name = tolower(bajau_name)) %>%
  mutate(family = tolower(family)) %>%
  mutate(species = tolower(species))

test <- tempdat %>%
  
  
  left_join(., fish_id_key, by="bajau_name")

temp_fish_id_key <- tempdat %>%
  dplyr::select(bajau_name = Fish_name_p, common_name = Common_Name) %>%
  complete(bajau_name, nesting()) %>%
  distinct() %>%
  mutate(bajau_name = tolower(bajau_name)) %>%
  full_join(., fish_id_key, by="bajau_name")

write.csv(temp_fish_id_key, "fish_id_key_2.csv")


