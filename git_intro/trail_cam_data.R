# set the working directory
f_path <- file.path("C:","Users","deepuser","Documents","GitHub",sep="/")
setwd(paste0(f_path,"git_intro"))

# add a new folder
dir.create(paste0(getwd(),"/data"))

# read in data
img_data <- read.csv("data/trail_cam_data_012222.csv",header=TRUE)

# get all streams that went dry(Category 1)
unique(img_data[img_data$Category==1,c("staSeq","locationName")])

# count the number of observations in a dry category
aggregate(Category~staSeq+locationName,data=img_data[img_data$Category==1,],"length")


