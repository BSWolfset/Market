# include necessary libraries
library(shiny)
library(leaflet)
library(dplyr)

# Read in Data file
FarmMarketRaw <-
  read.csv("data/FMExport.csv", na.strings = c("NA", "", "#DIV/0!"), header = TRUE, strip.white = TRUE)

# Clean data - ignore rows with no lat or long because they cannot be mapped
FarmMarketDS <- filter(FarmMarketRaw, !is.na(FarmMarketRaw$x) & !is.na(FarmMarketRaw$y))

# Clean data - make city upper case so that dropdown lists will be consistent
FarmMarketDS$city <- toupper(FarmMarketDS$city)

# this dataframe will be used for mapping - start it with complete set
FarmMarketDisp <- FarmMarketDS
# this matrix will be used to display the list of states
StateList <- FarmMarketDS$State %>% unique() %>% sort()