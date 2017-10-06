###########################
# SmartPhone Parsing.R
# michael t yamada
# assumes that data are stored in ./UCI-Har-dataset
# outputs tidy data set text file in working directory
##########################

library(data.table)
library(dplyr)
library(tidyr)

## Read & process tables common to train and test
features <- read.table("./UCI-Har-dataset/features.txt", stringsAsFactors = FALSE)
colnames(features) <- c("measureID", "description")

activityLabels <- read.table("./UCI-Har-dataset/activity_labels.txt")
colnames(activityLabels) <- c("activityID","description")

# Clean up names
features$description <- gsub("-",".",gsub("[()]*","",features$description))

# Generate vector of column numbers (features) to keep (with string mean or std)
featuresKeep <- grep("mean|std", features[,"description"])


## Training data
# Read the activity table and provide it with a description field name
activity.train <- read.table("./UCI-Har-dataset/train/y_train.txt", stringsAsFactors = FALSE)
colnames(activity.train) <- "activityID"

# Create a description column in activity.train table by joining the labels with the activity
# left_join returns a dataframe, but we only need the description for this purpose
activity.train$description <- (left_join(activity.train, activityLabels, by = "activityID"))[,"description"]

# Read subjects table and convert to vector
subject.train <- (read.table("./UCI-Har-dataset/train/subject_train.txt", header = FALSE))$V1

# Read data
rawD.train <- read.table("./UCI-Har-dataset/train/X_train.txt", sep = "", header = FALSE)

# Label columns of the raw data
colnames(rawD.train) <- features$description

# remove unnecessary columns
rawD.train <- rawD.train[ , featuresKeep]

# append subject and activity columns
rawD.train$subject <- subject.train
rawD.train$activity <- activity.train$description

## Test data
# Read the activity table and provide it with a description field name
activity.test <- read.table("./UCI-Har-dataset/test/y_test.txt", stringsAsFactors = FALSE, header = FALSE)
colnames(activity.test) <- "activityID"

# Create a description column in activity.test table by joining the labels with the activity
activity.test$description <- (left_join(activity.test, activityLabels, by = "activityID"))[,"description"]

# Read subjects table and convert to vector
subject.test <- (read.table("./UCI-Har-dataset/test/subject_test.txt", header = FALSE))$V1

# Read the test data
rawD.test <- read.table("./UCI-Har-dataset/test/X_test.txt", sep = "", header = FALSE)

# Label columns of the raw data
colnames(rawD.test) <- features$description

# remove unnecessary columns
rawD.test <- rawD.test[ , featuresKeep]

# append subject and activity columns
rawD.test$subject <- subject.test
rawD.test$activity <- activity.test$description

# merge rows of test and train and reorder columns to put "ID" columns first
rawD <- rbind(rawD.test, rawD.train)

# Convert the raw data set to a tidy one
tidyD <- gather(rawD, Measure, Value, 1:79)

write.table(tidyD, file = "tidydata.txt", row.names = FALSE)
