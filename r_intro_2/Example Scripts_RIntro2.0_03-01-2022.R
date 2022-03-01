# KEYOARD SHORTCUTS & HELPFUL HINTS
# "Ctrl" + "Shift" + "C" == #
# "Alt" + "-" == <-
# "Ctrl" + "Enter" == will run that line of code
# "Ctrl" + "A" followed by "Ctrl" + "Enter" == will run all code
# use colnames() in Console (lower-left)
# use getwd() in Console (lower-left)
# I find it easier to manage scripts when they are all organized under an umbrella "R Folder" >
# > instead of hiding in various files across your work folders
# "%>%" is a pipe operator used in leaflet package, also used in dplyr package



# DOWNLOAD PACKAGES - INSTALL.PACKAGES()
# once installed, you will not need to re-download packages and these lines of code can be 
# removed or #hash-tagged to be reference text

# install.packages("leaflet") # is for mapping
# install.packages("ggplot2") # graphing package
# install.packages("tidyr")
# install.packages("lubridate") # is for date data
# install.packages("mapview") # used here for exporting leaflet maps

# CALL EACH PACKAGE - LIBRARY()
# to be usable within this specific .R file in RStudio
library(leaflet)
library(ggplot2)
library(tidyr)
library(lubridate)
library(mapview)

# IMPORT DATA - READ.CSV()
sFlow <- read.csv("CTDEEP_Stream_Flow_Survey_0.csv")

awX <- read.csv("awX_stations.csv")


# REMOVE columns from data
# Use colnames(awX) in console (bottom-left) to check the columns name of awX dataframe 
awX <- awX[c("STA_SEQ", "WaterbodyName", "Description", "ylat", "xlong", "subBasin")]


# ALTERNATIVE for removing columns
# awX <- awX[c(1:5, 7)] # Removes misc. columns from dataframe
sFlow$ï..ObjectID <- NULL # Removes one column at a time, less efficient


# MERGE()
data <- merge(sFlow, awX, by.x = "Station.ID.", by.y = "STA_SEQ")
# Notice that the number of observations is reduced from 183 in sFlow to 159 in data, 
# that means that there were 24 rows of data without a matching StationID so they were
# removed automatically

# If you want to keep all of the data that doesn't have a StationID then do this instead
# adding all.x = TRUE will keep all rows from sFLow dataframe
# data <- merge(sFlow, awX, by.x = "Station.ID.", by.y = "STA_SEQ", all.x = TRUE)


# as.date()
# reformats surveyStartDate column to exist in internation data format or "ISO" format
# YYYY-MM-DD
data$surveyStartDate <- as.Date(data$surveyStartDate, format = "%m/%d/%y")


# year() from lubridate
# new column indicating only year
data$year <- year(data$surveyStartDate)


# subset()
# subsets data to data21 to only contain data from year 2021
data21 <- subset(data, data$year == "2021")

# subsets data to include two dataframes, one of Moultrie cameras and one of Reconyx cameras
data21m <- subset(data21, data21$Camera.Type. == "Moultrie")
data21r <- subset(data21, data21$Camera.Type. == "Reconyx")


# nrow()
x <- nrow(data21)
m <- nrow(subset(data21, data21$Camera.Type. == "Moultrie"))
r <- nrow(subset(data21, data21$Camera.Type. == "Reconyx"))

# length()
y <- length(data21$Station.ID.)
z <- length(data21)


# RENAME A COLUMN
colnames(data21)[colnames(data21) == "Field.Crew."] <- "fieldCrew"
# OR
colnames(data21)[6] <- "waterbody"




# New df of only certain columns from 2021 data
mapdf <- data21[c("Station.ID.", "WaterbodyName", "Description", "ylat", "xlong", "subBasin")]

# unique()
# Subsetting the mapdf to be only unique rows across ALL columns
mapdf <- unique(mapdf)




# LEAFLET PACKAGE ---

# Use leaflet package to build a map of the stations in dataset. 

# library(leaflet) # we already called this earlier so this is overkill


# This example is very simple
mapSimple <- leaflet(data = mapdf) %>% 
  addTiles() %>%
  addCircleMarkers(
    lng = mapdf$xlong,                        # Call the column with longitude coordinates
    lat = mapdf$ylat,                         # Call the column with longitude coordinates
    label = paste(data$Station.ID., "-", data$WaterbodyName),  # Adds a label to the addCircleMarker
    radius = 5,                               # Size of the markers
    fillOpacity = 1)                        # fillOpacity of 1 will have no transparency


mapshot(mapSimple, "mapSimple.html")




# This is a more complicated version of a similar map
# This is a great resource for understanding the possibilities for the leaflet package - 
# http://rstudio.github.io/leaflet/morefeatures.html

mapdf$color <- ifelse(mapdf$WaterbodyName == "Bunnell Brook", "#0080FF", "#CEE7FF")

mapComplex <- leaflet(data = mapdf, options = leafletOptions(minZoom = 8,
                                                  maxZoom = 16)) %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldGrayCanvas", group = "GrayCanvas") %>%
  addProviderTiles("Esri.WorldTopoMap", group = "Topography") %>%
  addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
  addLayersControl(baseGroups=c("GrayCanvas", "Topography", "Satellite"),
                   options = layersControlOptions(collapsed = T, autoZIndex = T)) %>%
  addCircleMarkers(~xlong, ~ylat,
                   label = ~Station.ID.,
                   labelOptions = labelOptions(permanent = TRUE, textOnly = FALSE,
                                               direction = "right",
                                               offset = c(10, 0), textsize = "15px",
                                               style = list(
                                                 "font-weight" = "bold", 
                                                 "box-shadow" = "3px 3px rgba(0,0,0,0.25)",
                                                 "font-size" = "14px",
                                                 "background-color" = "rgba(243,243,243,0.75)",
                                                 "border-color" = "rgba(78,78,78,0.75)"
                                               )),
                   popup = paste("Site ID:", "<b>", mapdf$Station.ID., "</b>", "<br/>",
                                 "Lake Name:", "<b>", mapdf$WaterbodyName, "</b>", "<br/>",
                                 "Latitude:", "<b>", mapdf$ylat, "</b>", "<br/>",
                                 "Longitude:", "<b>", mapdf$xlong, "</b>"),
                   radius = 8,
                   weight = 3,
                   stroke = TRUE,
                   color = "black",
                   opacity = 1,
                   fillOpacity = 1,
                   fillColor = ~color) %>%
  
  addEasyButton(easyButton(
    icon="fa-globe", title="Zoom Out to Connecticut",
    onClick=JS("function(btn, map){ map.setZoom(8); }"))) %>%
  
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    secondaryLengthUnit = "feet",
    primaryAreaUnit = "sqmeters",
    secondaryAreaUnit = "sqmiles",
    activeColor = "#FF8000",
    completedColor = "#FFFF00") %>%
  
  addLegend("bottomright", opacity = 1.0,
            colors = c("#0080FF", "#CEE7FF"),
            labels = c("Bunnell Brook", "Other Stations")) %>%
  
  addScaleBar(position = c("bottomleft"), options = scaleBarOptions(maxWidth = 200, 
                                                                    metric = TRUE, 
                                                                    imperial = TRUE)) %>%
  
  addMiniMap(
    # all the tiles in our basemap, display the first one
    tiles = c(
      "Esri.WorldGrayCanvas", "Esr.WorldTopoMap", "Esri.WorldImagery")[1],
    toggleDisplay = TRUE)

mapshot(mapComplex, "mapComplex.html")

