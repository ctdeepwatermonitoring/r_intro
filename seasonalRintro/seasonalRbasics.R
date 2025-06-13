#seasonal intro R script
#the purpose of this script is to demonstrate some R basics and perform data 
#manipulation in a typical format of ambient environmental monitoring data

################################################################################
#######1. understanding comments################################################

# the hashtag or pound symbol (#) is used to indicate comments. R will not try to 
#run any text commented out. you can comment out a section with the shortcut ctrl + shift + C
#this is useful when you are trying to debug code or dont want to run some lines
#a good practice is to comment every step or every section of your code as is
#done in this code to make it clear to the reader (including future you!)

################################################################################
######2. setting working directory##############################################

#before we read or generate any files, we first need to set our working directory
#the working directory is where R will "look" to read/write files
  
getwd() #this will report the current working directory in the console

#If you open the project file first it will automatically set the working 
#directory to the folder the project file is in so that you do not need 
#to specify the working directory, otherwise you'll need to uncomment and run line below

#instructions to specify the working directory: create an "R" folder on your P drive. 
#then, copy the 'seasonalRintro'
#file you have been given to the R folder. the entire address will be P:\R\seasonalRintro
#setwd("P:/R/seasonalRintro") #this sets the working directory to the folder we just made
#getwd() #we can now see that the working directory has changed!

######3. installing and activating R packages###################################

#to manipulate data in R, we use functions. there are functions available in
#base R (ie what R comes with natively) and those developed externally. we can
#acquire new functions by installing packages. the code for that is below:

install.packages("dplyr") #dplyr is useful for manipulating and summarizing data

library(dplyr) #in the 'packages' view, this checks the box and makes the package active

################################################################################
######4. creating and manipulating data#########################################

#values and data frames are some of the ways R can temporarily store and visualize data
#data frames are like an Excel table, but you cant directly click on cells and 
#change values. thus, we use code to manipulate data frames instead

#we can create objects from scratch in R. "<-" is used to create something, pointing
#towards the thing you are making

x <- 2 #this creates a variable 'x' with the value 2
y <- 3 #this creates a variable 'y' with the value 3
x + y #this will print the evaluated expression in the console
z <- x + y #this assigns the result to a new variable, z
z #running just z will output the same result as x + y (5)

#we can also create characters and lists that may be useful for manipulating data
sitenames <- c("Salmon River", "Roaring Brook", "Hedge Brook")
sitenames #this prints the list of names that we just created

#most commonly, we will be reading in data files that already exist
#it is INCREDIBLY IMPORTANT that you make copies of any files you are going to
#manipulate in R - place the copy in your working directory is. do not simply 
#move a file off a drive into your own folder!

#lets make some data frames! often abbreviated to 'df' in online guides
hoboData <- read.csv("hoboData.csv") #this makes a dataframe called 'hoboData'
#click on the hoboData object in the 'Data' view to explore the columns
#columns can be filtered and sorted to quickly visualize their contents
hoboData #this prints the dataframe in the console
hoboData$ProbeID #this is how we refer to individual columns in a data frame
hoboData$NewCol <- NA #this is how we make new columns, this is populated with NA values
colnames(hoboData) #print the new column names
hoboData <- hoboData[c("Date_Time","Temp","UOM","ProbeID","SID" ,"Collector","ProbeType")] #removing NewCol
sapply(hoboData, class) #this prints the data types of our data frame in the console
#data types are important because we cannot manipulate data if we are assuming
#the incorrect data type. for example, we can't do math on a character or work
#with dates correctly unless we fix data types as needed. this is a critical first
#thing to check if you are finding that you cannot summarize or visualize data 
#correctly!

#if we try to plot the data with base R, we will get an error
plot(hoboData$Date_Time, hoboData$Temp)

#we have discovered that Date_Time and Temp are both character classes, but to
#manipulate them, they need to be a datetime and a numeric class, respectively
#sometimes we mess up when fixing data types, so lets create a new version of
#hoboData to compare to the original
hoboDataFix <- hoboData #without changes, the Fix version is identical to the original
hoboDataFix$Temp <- as.numeric(hoboDataFix$Temp) #this forces the data type of the Temp
#column to numeric. this will change any cells with character data to a NA null value
#which is an expected result and OK for what we are doing
hoboDataFix$Date_Time <- as.POSIXct(hoboDataFix$Date_Time, format = "%m/%d/%Y %H:%M")
#this converts the character Date_Time column to a POSIXct format, which stores date
#and time information. this means R will now "know" how to correctly handle this data
#as a datetime and not as a character. you may have datetimes that come in with
#very different formats. the 'format = ' argument is mapped to what the original data
#looks like. for example, another common format would be 2022-09-30 or %Y-%m-%d

#lets see if our fixes worked!
plot(hoboDataFix$Date_Time, hoboDataFix$Temp) #syntax: plot(x variable, y variable)
#you have now successfully made a plot of corrected data!

################################################################################
######5. binding and merging data##############################################


#there are many ways we might want to join data sets. commonly we may bind files
#vertically, which is essentially sticking gluing two datasets together. or we
#may bind datasets horizontally by a shared variable. lets see how the two methods 
#compare to each other

#vertically merging:
hoboDataBind <- read.csv("hoboDataBind.csv") #temperature data from a different site
colnames(hoboDataBind) #checking the column names
colnames(hoboData) #checking the column names
#the column names are the same as hoboData, so we can use rbind to vertically
#merge these two files
hoboDataVBound <- rbind(hoboDataBind, hoboData) #if we count the number of rows
#in hoboDataVBound, we can see that they equal the sum of the two files

#horizontally merging:
stations <- read.csv("stations.csv") #an output from our AWX stations table
colnames(stations) #checking the column names
#common monitoring terminology: "STA_SEQ" "AWX Station" "SID" all refer to the
#unique site ID that is stored in the AWX database. stations$STA_SEQ and 
#hoboDATA$SID refer to the same thing. we can horizontally merge by this shared
#parameter, but we first need to change the names of columns so that they match
#R needs to have a shared column name with shared values to be able to merge in this way
#here is how we can change the name of a single named column in a data frame
names(stations)[names(stations) == "STA_SEQ"] <- "SID" #the AWX column in hoboData
colnames(stations) #print to see changed names
hoboDataHBound <- merge(hoboData, stations, by = "SID")

#looking at hoboDataVBind and hoboDataHBind, we see that in one example, we appended
#rows to the original data frame, and in the other we added columns that are related
#by a shared variable. 

#we may also want to reorder or remove columns that we do not need
colnames(hoboDataHBound) #this is quite a lot of columns!
hoboDataTrimmed <- hoboDataHBound #a new version to compare column numbers to
hoboDataTrimmed <- hoboDataTrimmed[c("Date_Time", "WaterbodyName", "SID", "Temp", 
                                     "UOM", "ProbeID")] #specify which columns you want and in what order
colnames(hoboDataHBound) #compare the number and order of columns

#you now have files to look compare how vertical joining, horizontal merging,
#and removing columns affects the column and row numbers. what if we now wanted
#to transform some of our data into an entirely new data frame?

################################################################################
#####6. summarizing data with dplyr#############################################

#dplyr has a ton of handy functions for summarizing data. we will use hoboDataVBound
#because there are a few different variables that we can summarize

sapply(hoboDataVBound, class) #Date_Time and Temp are characters and we need to fix that
hoboDataVBound$Temp <- as.numeric(hoboDataVBound$Temp) #same code as before
hoboDataVBound$Date_Time <- as.POSIXct(hoboDataVBound$Date_Time, format = "%m/%d/%Y %H:%M") #same code as before
hoboDataVBound$Date <- as.Date(hoboDataVBound$Date_Time) #this makes a new column with Date from Date_Time

#dplyr portion! we will add a new kind of syntax, the pipe operator: %>%. this operator
#can be read as "and then." e.g. "make a new data frame and then group by (x) and then
#calculate the mean of (x)... etc
hoboDataSums <- hoboDataVBound %>% #pipe operator
  group_by(SID, Date) %>% #first group on site ID, then on the Date as we want 24hr averages
  summarize(Mean_24hr = mean(Temp)) #this creates a new column called 'Mean24hr' with the mean of Temp

#this new data frame contains 24hr Temp averages for each SID (site ID) and date 
#we can quickly plot and visualize it
plot(hoboDataSums$Date, hoboDataSums$Mean_24hr) #one issue with this graph is that
#it does not differentiate between the two sites, even though we differentiated 
#in our group_by line. R dataframes can also be subset according to logical rules
#lets try subsetting hoboDataSums by one of the site IDs
hoboDataSums_subset <- subset(hoboDataSums, hoboDataSums$SID == "15499")# syntax:
#subset hobodata sums where the SID column equals (==, not =) 15499. other logical 
#operators include & (and), | (or), >, <, >=, <=, etc. we could also try subsetting 
#for only certain values. for example:
hoboDataSums_subset <- subset(hoboDataSums, hoboDataSums$Mean_24hr >= 17) #now we
#only return rows for which the 24hr temperature is greater than or equal to 17 deg C
#checking for NAs can also be helpful and the syntax is different
hoboDataSumsNA <- subset(hoboDataSums, is.na(hoboDataSums$Mean_24hr)) #this returns 
#rows where the 24hr average was NA (this is due to having NAs in the original data)
#to have dplyr ignore NAs when summarizing, you can add modify the summarize line
#to look like summarize(Mean_24hr = mean(Temp, na.rm = TRUE)). this makes it calculate
#means even if the grouping has NAs

#another thing you may want to do is add calculated columns. the syntax is
#fairly straightforward
hoboDataSums$Mult <- hoboDataSums$Mean_24hr * 100 #making a new column that is 
#multiplying the mean column by 100. like Excel functions, you can also add, subtract
#divide, etc. use PEMDAS!

################################################################################
######7. Saving your data#######################################################

#dataframes can easily be exported with the write.csv function in base R
#make sure that you specify the file extension .csv or it will not work!
write.csv(hoboDataSums, "hoboDataSums.csv")
#by default it will save in your working directory. IMPORTANTLY, if there is a file
#with the name you are saving in that directory, R WILL overwrite it. don't lose
#work! also, if you work with a csv export, make sure to save as .xlsx file to preserve
#any functions, filtering, graphs you have made, etc. 

#plots or other objects in the viewer pane can be exported with the Export button
#or you can right click and copy/save them to quickly share them

################################################################################
######8. Conclusion#############################################################

#you should now be able to add comments, install packages, read in files, create data frames,
#create new columns in data frames, check data types, merge different data frames 
#summarize your data, subset your data, and export your data! this covers data
#manipulation basics in R. you can now move onto visualizing your data and some
#more advanced R programming

