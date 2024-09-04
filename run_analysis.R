# Check and install 'dplyr' if not already installed
if (!require("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
  library(dplyr)
}

# Download and unzip the dataset
if(!file.exists("./data")) {
  dir.create("./data")
}
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "./data/getdata_projectfiles_UCI HAR Dataset.zip")
unzip(zipfile = "./data/getdata_projectfiles_UCI HAR Dataset.zip", exdir = "./data")

# Merge the training and the test sets to create one data set (1)
# Read the training and test datasets
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Read activity labels and features vector
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
colnames(activityLabels) <- c("activityID", "activityType")
features <- read.table("./data/UCI HAR Dataset/features.txt")

# Assign variable names
colnames(x_train) <- features[, 2]
colnames(y_train) <- "activityID"
colnames(subject_train) <- "subjectID"
colnames(x_test) <- features[, 2]
colnames(y_test) <- "activityID"
colnames(subject_test) <- "subjectID"

# Merge datasets
TrainingDataset<- cbind(y_train, subject_train, x_train)
TestDataset <- cbind(y_test, subject_test, x_test)
MergedDataset <- rbind(TrainingDataset, TestDataset)

# Extract only the measurements on the mean and standard deviation for each measurement 
SampleCalculations <- grepl("activityID|subjectID|mean|std", colnames(MergedDataset))
SetSample <- MergedDataset[, SampleCalculations]

# Use descriptive activity names to name the activities in the data set (3)
DescriptiveVariableNames <- merge(SetSample, activityLabels, by = "activityID", all.x = TRUE)

# Appropriately label the data set with descriptive variable names (4)
colnames(DescriptiveVariableNames) <- gsub("Acc", "Accelerometer", colnames(DescriptiveVariableNames))
colnames(DescriptiveVariableNames) <- gsub("BodyBody", "Body", colnames(DescriptiveVariableNames))
colnames(DescriptiveVariableNames) <- gsub("^f", "Frequency", colnames(DescriptiveVariableNames))
colnames(DescriptiveVariableNames) <- gsub("Gravity", "Gravity", colnames(DescriptiveVariableNames))
colnames(DescriptiveVariableNames) <- gsub("Gyro", "Gyroscope", colnames(DescriptiveVariableNames))
colnames(DescriptiveVariableNames) <- gsub("Jerk", "Jerk", colnames(DescriptiveVariableNames))
colnames(DescriptiveVariableNames) <- gsub("Mag", "Magnitude", colnames(DescriptiveVariableNames))
colnames(DescriptiveVariableNames) <- gsub("mean()", "Mean", colnames(DescriptiveVariableNames))
colnames(DescriptiveVariableNames) <- gsub("^t", "Time", colnames(DescriptiveVariableNames))

# From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject (5)
TidyDataset <- DescriptiveVariableNames %>%
  group_by(subjectID, activityID, activityType) %>% summarise_all(mean)

# Write second tidy dataset to a csv file
write.table(TidyDataset, "TidyDataset.txt", row.names = FALSE)