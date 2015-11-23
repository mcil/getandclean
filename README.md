# getandclean
repo for Coursera get and clean data project

The code in the run_analysis.R script is well commented and explains the process of setting the R workspace and data folder, downloading the original data file and the process of melding the several data text files into a single tidy data set.
This is the only script used, and should be selfcontained. It was created and run in a current version of R studio.

# run_analysis.R
# get and clean data class project:
###
# What this script does 
# A.	Sets working directory
# B.	Creates data directory if necessary 
# C.	Downloads zip file if necessary
# D.	Extracts data from zip if necessary 
# E.  Reads data into data frames
# F.  Adds subject and activity(as text) columns to data


# 1.	Merges the training and the test sets to create one data set.
# 2.	Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3.	Uses descriptive activity names to name the activities in the data set
# 4.	Appropriately labels the data set with descriptive variable names. 
# 5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# 

	
###
# set working directory
mywd <- "~/coursera/getcleandata/project"
setwd(mywd)
###
# if necessary, create the data directory
if (!file.exists("data")) {
      dir.create("data")
}
###
# download the data files
# define the file url
#
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# define the destination file
destination <- "./data/mydata.zip"
#
#download.file(fileUrl, destfile = destination, method = "curl")
if (!file.exists("./data/mydata.zip")) {
      dateDownloaded <- date()
      download.file(fileUrl, destfile = destination)
}      
# unzip data
library(utils)
# unzip(zipfile, files = NULL, list = FALSE, overwrite = TRUE,junkpaths = FALSE, exdir = ".", unzip = "internal",setTimes = FALSE)
if (!file.exists("./data/UCI HAR Dataset")) {
      unzip("./data/mydata.zip", exdir = "./data")
} 

# ##
# use read.table to create the train and test data frames, combine both with rbind to dfall
# - './data/UCI HAR Dataset/train/X_train.txt': Training set.
# - './data/UCI HAR Dataset/test/X_test.txt': Test set.
dftrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
dftrainsubjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
dfytrain <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
dftest <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
# use read.table to create a df of column names for the dataset from features.txt
dff <- read.table("./data/UCI HAR Dataset/features.txt")
# replace colnames in data with text names from features.txt
colnames(dftrain) <- dff[,2]
colnames(dftest) <- dff[,2]
# drop unwanted columns
dftrain <- dftrain[, grep("-mean\\(\\)|-std\\(\\)", names(dftrain)) ]
dftest <- dftest[, grep("-mean\\(\\)|-std\\(\\)", names(dftest)) ]
# need to add subjects and activities to data
# subjects
dftestubjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
dfytest <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
dfactivity <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
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

# use aggregrate to calculate mean for columns grouped by activity and subjects
mytidy <- aggregate.data.frame(dfall, by=list(activity, subjects), FUN = mean, simplify = TRUE)
# create a text file of the tidy data
write.table(mytidy, "tidytable.txt" ,row.names = FALSE)
# end 

