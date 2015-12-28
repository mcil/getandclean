# run_analysis.R
# get and clean data class project:
###
###
# What this script does 
# A.	Sets working directory
# B.	Creates data directory if necessary 
# C.	Downloads zip file if necessary
# D.	Extracts data from zip if necessary 
# E.  Reads data into data frames


# 1.	Merges the training and the test sets to create one data set.
# 2.	Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3.	Uses descriptive activity names to name the activities in the data set
# 4.	Appropriately labels the data set with descriptive variable names. 
# 5.	From the data set in step 4, creates a second, independent tidy data set with the average of 
#     each variable for each activity and each subject.
# 

	
###
# set my working directory (yours may differ, so commited out)
mywd <- "~/coursera/getcleandata/project1"
setwd(mywd)
###
# download the data files
# define the file url
#
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# define the destination file
destination <- "mydata.zip"
#
#download.file(fileUrl, destfile = destination, method = "curl")
if (!file.exists("mydata.zip")) {
      dateDownloaded <- date()
      download.file(fileUrl, destfile = destination)
}      
# unzip data
library(utils)
# unzip(zipfile, files = NULL, list = FALSE, overwrite = TRUE,junkpaths = FALSE, exdir = ".", unzip = "internal",setTimes = FALSE)
if (!file.exists("UCI HAR Dataset")) {
      unzip("mydata.zip")
} 

# ##
# use read.table to create the train and test data frames, combine both with rbind to dfall
# - './UCI HAR Dataset/train/X_train.txt': Training set.
# - './UCI HAR Dataset/test/X_test.txt': Test set.
dftrain <- read.table("UCI HAR Dataset/train/X_train.txt")
dftrainsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
dfytrain <- read.table("UCI HAR Dataset/train/Y_train.txt")
dftest <- read.table("UCI HAR Dataset/test/X_test.txt")
# use read.table to create a df of column names for the dataset from features.txt
dff <- read.table("UCI HAR Dataset/features.txt")
# replace colnames in data with text names from features.txt
colnames(dftrain) <- dff[,2]
colnames(dftest) <- dff[,2]
# drop unwanted columns
dftrain <- dftrain[, grep("-mean\\(\\)|-std\\(\\)", names(dftrain)) ]
dftest <- dftest[, grep("-mean\\(\\)|-std\\(\\)", names(dftest)) ]
# need to add subjects and activities to data
# subjexts
dftestubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
dfytest <- read.table("UCI HAR Dataset/test/Y_test.txt")
dfactivity <- read.table("UCI HAR Dataset/activity_labels.txt")
#
#create vector with activities
values <- dfactivity[,2]
# add column with activity names to both
dfytrain$activity <- values[dfytrain[,1]]
dfytest$activity <- values[dfytest[,1]]
# add activity column to both
dftrain$activity <- dfytrain$activity
dftest$activity <- dfytest$activity
# add subject column to both
dftest$subjects <- dftestubjects$V1
dftrain$subjects <- dftrainsubjects$V1

# this is the combined data set 
dfall <- rbind(dftrain, dftest)
# fix the column names
cnames <- colnames(dfall)
cnames <- gsub("-","",cnames)
cnames <- gsub("[()]","",cnames)
cnames <- gsub("[,]","",cnames)
cnames <- tolower(cnames)
colnames(dfall) <- cnames
dfall$subjects <- as.factor(dfall$subjects)
# str(dfall)
tidyData    = aggregate(dfall[,names(dfall) != c('activity','subjects')],by=list(activity=dfall$activity,subjects = dfall$subjects),mean)

write.table(tidyData, './tidyData.txt',row.names=FALSE)
