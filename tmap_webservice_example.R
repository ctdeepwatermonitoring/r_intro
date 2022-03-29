library(tmap)
library(sf)

# The base urls needed to make a webservice request
r_base <- 'https://www.waterqualitydata.us/data/Result/search?'
s_base <- 'https://www.waterqualitydata.us/data/Station/search?'

# Query parameters
org <- 'organization=CT_DEP01_WQX'
chr <- 'characteristicName=Specific%20conductance'
prj <- 'project=lakesABM'
sdt <- 'startDateLo=01-01-2019'
edt <- 'startDateHi=01-01-2020'
typ <- 'mimeType=csv'
zip <- 'zip=no'
dpf <- 'dataProfile=resultPhysChem'

r_qry <- paste(org,chr,prj,sdt,edt,typ,zip,dpf,sep = "&")
s_qry <- paste(org,chr,prj,sdt,edt,typ,zip, sep = "&")

req_data <- paste0(r_base,r_qry)
req_site <- paste0(s_base,s_qry)

# read in WQP request data
data <- read.csv(req_data,header=TRUE,stringsAsFactors = FALSE)
site <- read.csv(req_site,header=TRUE,stringsAsFactors = FALSE)
site <- site[,c(3:6,12:13)] #select needed cols

# CT DEEP Open Data Request
m_base  <- 'https://services1.arcgis.com/FjPcSmEFuDYlIdKC/arcgis/rest/services/'
lyr     <- 'Major_Drainage_Basin_Set/FeatureServer/1/query?'
m_qry   <- 'where=1%3D1&outFields=*&outSR=4326&f=json'

m_basn  <- paste0(m_base,lyr,m_qry)



data_loc <- merge(data,site, by = "MonitoringLocationIdentifier")
data_loc <- data_loc[data_loc$ActivityDepthHeightMeasure.MeasureValue == 0,
                     c(1,4,8,42,43,82:86)]
data_loc <- aggregate(ResultMeasureValue~MonitoringLocationIdentifier+
                        MonitoringLocationName.y+LatitudeMeasure+
                        LongitudeMeasure,data=data_loc,FUN="mean")

data_sf <- sf::st_as_sf(data_loc,
                        coords = c("LongitudeMeasure","LatitudeMeasure"),
                        crs = 4326)
basin_sf <- st_read(m_basn)


tmap_mode("plot")
tm_shape(basin_sf) +
  tm_polygons("MAJOR",palette = "PuBu",legend.show = FALSE)+
tm_shape(data_sf, title = "Conductivity") + 
  tm_bubbles(size = "ResultMeasureValue") +
#tm_style("classic")+
tm_layout('2019 Lake Conductivity',
  title.position = c("right","top"),
  bg.color = "grey",
  legend.title.size = 1,
  legend.text.size = 0.6,
  legend.position = c("right","bottom"),
  legend.bg.color = "grey",
  legend.bg.alpha = 0.5)

tmap_mode("view")
tm_basemap("Stamen.Watercolor") +
  tm_shape(basin_sf) +
  tm_polygons("MAJOR",alpha = 0,lwd = 3,legend.show = FALSE)+
  tm_shape(data_sf) + 
  tm_bubbles(size = "ResultMeasureValue") +
  tm_layout('2019 Lake Conductivity',
            title.position = c("right","top"))
  



