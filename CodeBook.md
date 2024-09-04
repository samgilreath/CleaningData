# Getting and Cleaning Data Project - Samsung Accelerometer

## About the dataset

<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details.

For each record it is provided: - Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.\
- Triaxial Angular velocity from the gyroscope.\
- A 561-feature vector with time and frequency domain variables.\
- Its activity label.\
- An identifier of the subject who carried out the experiment.

## Reproduce the analysis

### 1. Install [dplyr](https://dplyr.tidyverse.org/)

```         
if (!require("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
  library(dplyr)
}
```

### 2. Download and unzip the source data

<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

```         
if(!file.exists("./data")) {
  dir.create("./data")
}
dataset_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataset_url, destfile = "./data/getdata_projectfiles_UCI HAR Dataset.zip")
unzip(zipfile = "./data/getdata_projectfiles_UCI HAR Dataset.zip", exdir = "./data")
```

### 3. Execute the following script (run_analysis.R)

```         
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

# Write second tidy dataset to a txt file
write.table(TidyDataset, "TidyDataset.txt", row.names = FALSE)
```
