# Clean just the fish flow data

rm(list=ls())
library(sf)
library(ggplot2)
library(googledrive)

# input LANDINGS TRIP data: https://drive.google.com/open?id=10C0WT0Psz00bHkw8S-NGbPU9FR7Ufgzv
# Path file: /Users/KGthatsme/Projects/Google Drive/Wakatobi-SEMAnalysis/_landingsData/Wakatobi-landings_20190910_TRIP-cleanedFishingGrounds.csv
drive_download(as_id("10C0WT0Psz00bHkw8S-NGbPU9FR7Ufgzv"), overwrite=TRUE)
trip.dat<-read.csv("Wakatobi-landings_20190910_TRIP_cleanedFishingGrounds.csv")
file.remove("Wakatobi-landings_20190910_TRIP_cleanedFishingGrounds.csv")

# Select relevant columns:
trip.dat<-subset(trip.dat, select=c(trip_id, fishing_grnd1, landing_no, landing_unit,
                                    landings_sold_personally_no, landings_sold_personally_unit,
                                    landings_sold_Papalele_no, landings_sold_Papalele_unit, 
                                    landings_sold_Pengumpul_no, landings_sold_Pengumpul_unit,
                                    landings_eaten_no, landings_eaten_unit,
                                    landings_given_no, landings_given_unit))



##### FISH FLOW CLEANING:
##### 1 - check for duplicate trips

# First remove all duplicate rows
dim(trip.dat)
trip.dat<-unique(trip.dat)
dim(trip.dat)

tripID.tab<-as.data.frame(table(trip.dat$trip_id))
tripID.check<-tripID.tab[(tripID.tab$Freq!=1),]$Var1

# "1 11 DAHLAN" and "1 11 ACER + DULETES" are both duplicated rows (only difference is that some columns are NAs and others are blank)
delete1<-grep("1 11 DAHLAN", trip.dat$trip_id)[1]
trip.dat<-trip.dat[-delete1,]

delete2<-grep("1 11 ACER", trip.dat$trip_id)[1]
trip.dat<-trip.dat[-delete2,]


# Now, only "11 20 BAGON" is a duplicated tripID
# Checked original scanned data sheet, the first 11 20 BAGON (fishing grnd = gusoh padutaian) is the correct entry
# Delete the second entry
delete3<-grep("11 20 BAGON", trip.dat$trip_id)[2]
trip.dat<-trip.dat[-delete3,]

##### FISH FLOW CLEANING (contd):
##### 2 - Need to clean column: "landings_sold_personally_no"; inputted as "factor" and should be "numeric"
summary(trip.dat)
levels(trip.dat$landings_sold_personally_no)
trip.dat$landings_sold_personally_no<-as.character(trip.dat$landings_sold_personally_no)

fix_index<-grep("1 box kecil", trip.dat$landings_sold_personally_no)
trip.dat$landings_sold_personally_no[fix_index]<-"1"
trip.dat$landings_sold_personally_unit[fix_index]<-"box kecil"


fix_index<-grep("21 ekor jual sendiri", trip.dat$landings_sold_personally_no) # selling 21 fish personally
trip.dat$landings_sold_personally_no[fix_index]<-"21"
trip.dat$landings_sold_personally_unit[fix_index]<-"fish"

fix_index<-grep("jual ke pasar dan pengumpul", trip.dat$landings_sold_personally_no) # selling to market and collectors - ie, need to move entire landings of "1 box" to "Pengumpul" column
trip.dat$landings_sold_Pengumpul_no[fix_index]<-1
trip.dat$landings_sold_Pengumpul_unit[fix_index]<-"box"
trip.dat$landings_sold_personally_no[fix_index]<-"0"

trip.dat$landings_sold_personally_no<-as.numeric(trip.dat$landings_sold_personally_no)



##### FISH FLOW CLEANING (contd):
##### 3 - Fix spelling errors and standardize all landing_units: 
levels(trip.dat$landing_unit)
# First, set as character so that new factors can be added (e.g., can't add small bucket since it's not currently a factor level)
trip.dat$landing_unit<-as.character(trip.dat$landing_unit)
trip.dat$landing_unit[grep("box kecil", trip.dat$landing_unit)]<-"small box"
trip.dat$landing_unit[grep("smal box", trip.dat$landing_unit)]<-"small box"
trip.dat$landing_unit[grep("bucket kecil", trip.dat$landing_unit)]<-"small bucket"
trip.dat$landing_unit[grep("ekor", trip.dat$landing_unit)]<-"fish"
trip.dat$landing_unit[grep("fish ", trip.dat$landing_unit)]<-"fish"
# Final check
table(trip.dat$landing_unit)
# Now, reset as factor
trip.dat$landing_unit<-as.factor(trip.dat$landing_unit)
levels(trip.dat$landing_unit)

# Standardize all landings_sold_personally_units: 
levels(trip.dat$landings_sold_personally_unit)
trip.dat$landings_sold_personally_unit<-as.character(trip.dat$landings_sold_personally_unit)
trip.dat$landings_sold_personally_unit[grep("box kecil", trip.dat$landings_sold_personally_unit)]<-"small box"
trip.dat$landings_sold_personally_unit[grep("smal box", trip.dat$landings_sold_personally_unit)]<-"small box"
trip.dat$landings_sold_personally_unit[grep("ekor", trip.dat$landings_sold_personally_unit)]<-"fish"
trip.dat$landings_sold_personally_unit[!(trip.dat$landings_sold_personally_unit %in% c("basket", "box", "bucket", "small box", "small bucket", "fish"))]<-NA
# Final check
table(trip.dat$landings_sold_personally_unit)
# Now, reset as factor
trip.dat$landings_sold_personally_unit<-as.factor(trip.dat$landings_sold_personally_unit)
levels(trip.dat$landings_sold_personally_unit)

# Standardize all landings_sold_Papalele_units: 
levels(trip.dat$landings_sold_Papalele_unit)
trip.dat$landings_sold_Papalele_unit<-as.character(trip.dat$landings_sold_Papalele_unit)
trip.dat$landings_sold_Papalele_unit[grep("box kecil", trip.dat$landings_sold_Papalele_unit)]<-"small box"
trip.dat$landings_sold_Papalele_unit[grep("live fish", trip.dat$landings_sold_Papalele_unit)]<-"fish"
trip.dat$landings_sold_Papalele_unit[!(trip.dat$landings_sold_Papalele_unit %in% c("basket", "box", "bucket", "small box", "small bucket", "fish"))]<-NA
# Final check
table(trip.dat$landings_sold_Papalele_unit)
# Now, reset as factor
trip.dat$landings_sold_Papalele_unit<-as.factor(trip.dat$landings_sold_Papalele_unit)
levels(trip.dat$landings_sold_Papalele_unit)

# Standardize all landings_sold_Pengumpul_units: 
levels(trip.dat$landings_sold_Pengumpul_unit)
trip.dat$landings_sold_Pengumpul_unit<-as.character(trip.dat$landings_sold_Pengumpul_unit)
trip.dat$landings_sold_Pengumpul_unit[!(trip.dat$landings_sold_Pengumpul_unit %in% c("basket", "box", "bucket", "small box", "small bucket", "fish"))]<-NA
# Final check
table(trip.dat$landings_sold_Pengumpul_unit)
# Now, reset as factor
trip.dat$landings_sold_Pengumpul_unit<-as.factor(trip.dat$landings_sold_Pengumpul_unit)
levels(trip.dat$landings_sold_Pengumpul_unit)

# Standardize all landings_eaten_units: 
levels(trip.dat$landings_eaten_unit)
trip.dat$landings_eaten_unit<-as.character(trip.dat$landings_eaten_unit)
trip.dat$landings_eaten_unit[!(trip.dat$landings_eaten_unit %in% c("basket", "box", "bucket", "small box", "small bucket", "fish"))]<-NA
# Final check
table(trip.dat$landings_eaten_unit)
# Now, reset as factor
trip.dat$landings_eaten_unit<-as.factor(trip.dat$landings_eaten_unit)
levels(trip.dat$landings_eaten_unit)

# Standardize all landings_given_units: 
levels(trip.dat$landings_given_unit)
trip.dat$landings_given_unit<-as.character(trip.dat$landings_given_unit)
trip.dat$landings_given_unit[!(trip.dat$landings_given_unit %in% c("basket", "box", "bucket", "small box", "small bucket", "fish"))]<-NA
# Final check
table(trip.dat$landings_given_unit)
# Now, reset as factor
trip.dat$landings_given_unit<-as.factor(trip.dat$landings_given_unit)
levels(trip.dat$landings_given_unit)

##### FISH FLOW CLEANING (contd):
##### 4 - check which fish flow data are missing (is.empty tests for 0s and NAs)
# First convert all blank spaces to NAs
trip.dat[trip.dat==""]<-NA

# Convert all NAs in "no." columns to 0s
toMatch<-c("landing_no", 
           "landings_sold_personally_no", 
           "landings_sold_Papalele_no",
           "landings_sold_Pengumpul_no",
           "landings_eaten_no",
           "landings_given_no"
)
no_cols<-grep(paste(toMatch,collapse="|"), names(trip.dat))
for (i in no_cols)
{
  trip.dat[,i][is.na(trip.dat[,i])]<-0
}

# Which trips have "0" fish flow information? (columns: sold, eaten, or given)
# all columns except "landings_no"
flow.dat<-trip.dat[no_cols]
notflow<-grep("landing_no", names(flow.dat))
flow.dat<-flow.dat[,-notflow]
trip.dat$FlowSums<-rowSums(flow.dat)


## 10 trips have no fish flow data
trip.dat[trip.dat$FlowSums==0,]
# Check original raw data sheets: CONFIRMED NO DATA; DELETE THESE ROWS
trip.dat<-trip.dat[trip.dat$FlowSums!=0,]


##### FISH FLOW CLEANING (contd):
##### 5 - Quality Control: Check that sum of fish flows = total landings
# Conversion of units of volume to abundance (as per Melati)
# essentially converting all units to "fish units"
box          <- 58
basket       <- 16
small_box    <- 19
bucket       <- 14
small_bucket <- 7

unit_cols<-grep("unit", names(trip.dat))
for (i in unit_cols)
{
  # make new column for fish abundance units
  trip.dat$newcol<-0
  trip.dat$newcol[grep("box", trip.dat[,i])]<-box
  trip.dat$newcol[grep("basket", trip.dat[,i])]<-basket
  trip.dat$newcol[grep("small box", trip.dat[,i])]<-small_box
  trip.dat$newcol[grep("bucket", trip.dat[,i])]<-bucket
  trip.dat$newcol[grep("small bucket", trip.dat[,i])]<-small_bucket
  
  # for data already in units of fish abundance (i.e., unit column == "fish"), insert the number 1 (since units are already in "fish", number of units x 1 = number of fish)
  trip.dat$newcol[grep("fish", trip.dat[,i])]<-1
  
  # rename newcol
  renamecol<-grep("newcol", names(trip.dat))
  names(trip.dat)[renamecol]<-paste(names(trip.dat)[i], "_abund", sep="")
}

# Calculate all fish flow abundances by multiplying "no." column with "unit_abund" column
trip.dat$landings_abund<-trip.dat$landing_no * trip.dat$landing_unit_abund
trip.dat$landings_sold_personally_abund<-trip.dat$landings_sold_personally_no * trip.dat$landings_sold_personally_unit_abund
trip.dat$landings_sold_Papalele_abund<-trip.dat$landings_sold_Papalele_no * trip.dat$landings_sold_Papalele_unit_abund
trip.dat$landings_sold_Pengumpul_abund<-trip.dat$landings_sold_Pengumpul_no * trip.dat$landings_sold_Pengumpul_unit_abund
trip.dat$landings_eaten_abund<-trip.dat$landings_eaten_no * trip.dat$landings_eaten_unit_abund
trip.dat$landings_given_abund<-trip.dat$landings_given_no * trip.dat$landings_given_unit_abund

### CHECK that landings_abund = sum(all other landings_abund)
trip.dat$fishflow_abund <- trip.dat$landings_sold_personally_abund + 
  trip.dat$landings_sold_Papalele_abund + 
  trip.dat$landings_sold_Pengumpul_abund + 
  trip.dat$landings_eaten_abund + 
  trip.dat$landings_given_abund

fishflowQC<-trip.dat$fishflow_abund != trip.dat$landings_abund
trip.dat_needsQC<-trip.dat[fishflowQC,]

# These are the trip IDs that need fish flow QC
tripID_needsQC<-trip.dat_needsQC$trip_id

# How much do landings abundance data differ from sum of fish flow data?
summary(abs(trip.dat_needsQC$landings_abund - trip.dat_needsQC$fishflow_abund))
# Median: 21.63
# Median: 20

# Without absolute value:
summary(trip.dat_needsQC$landings_abund - trip.dat_needsQC$fishflow_abund)
# On average, sum of fish flow data is greater than total landings data 

# For now, REMOVE THESE:
#trip.dat<-trip.dat[!(trip.dat$trip_id %in% tripID_needsQC),]
#summary(abs(trip.dat$landings_abund - trip.dat$fishflow_abund))

# Use sum of fish flows as our measure of total landings - ie, ignore landings_abund column
trip.dat<-subset(trip.dat, select=-landings_abund)


##### FISH FLOW CLEANING (contd):
##### 6 - Quality Control: Check for outliers
#plot(trip.dat$landings_abund)
plot(trip.dat$landings_sold_personally_abund)
plot(trip.dat$landings_sold_Papalele_abund) # ON ISLAND
plot(trip.dat$landings_sold_Pengumpul_abund) # OFF ISLAND
# How many trips had catch sold off-island?
sum(trip.dat$landings_sold_Pengumpul_abund!=0) # 59
plot(trip.dat$landings_eaten_abund)
plot(trip.dat$landings_given_abund)

write.csv(trip.dat, file="Wakatobi-landings_20190912_TRIP_cleanedFishFlows.csv", quote=FALSE, row.names = FALSE)

### 5 - Display data on map

