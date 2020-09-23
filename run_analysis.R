library(data.table)
fileurl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("./UCI HAR Dataset.zip")){
        download.file(fileurl,"./UCI HAR Dataset.zip")
        unzip("UCI HAR Dataset.zip", exdir = getwd())
}

features <- read.csv("./UCI HAR Dataset/features.txt", header = F, sep = " ")
features <- as.character(features[,2]) 

subject_train <- read.csv("./UCI HAR Dataset/train/subject_train.txt", header = F)
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt", header = F) 
Y_train <- read.csv("./UCI HAR Dataset/train/y_train.txt", header = F)

train_data <- data.frame(subject_train,Y_train, X_train)
names(train_data) <- c(c('subject', 'activity'), features)

subject_test <- read.csv("./UCI HAR Dataset/test/subject_test.txt", header = F)
X_test<- read.table("./UCI HAR Dataset/test/X_test.txt", header = F) 
Y_test <- read.csv("./UCI HAR Dataset/test/y_test.txt", header = F)

test_data <-  data.frame(subject_test,Y_test, X_test)
names(test_data) <- c(c('subject', 'activity'), features)

merged_dataset <- rbind(train_data, test_data)


meansd_data <- grep("mean|std", features)
replaceddata <- merged_dataset[,c(1,2, meansd_data + 2)] 

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = F)
activity_labels <- as.character(activity_labels[,2])

replaceddata$activity <- activity_labels[replaceddata$activity]

new_names <- names(replaceddata)
new_names <- gsub("[(][)]", "", new_names)
new_names <- gsub("^t", "timedomain", new_names)
new_names <- gsub("^f", "frequencydomain", new_names)
new_names <- gsub("Acc", "accelerometer", new_names)
new_names <- gsub("Gyro", "gyroscope", new_names)
new_names <- gsub("Mag", "magnitude", new_names)
new_names <- gsub("Body", "body", new_names)
new_names <- gsub("-mean-", "mean", new_names)
new_names <- gsub("-std-", "sd", new_names)
new_names <- gsub("-", "", new_names)
new_names <- gsub(",", "", new_names)
names(replaceddata) <- new_names

output_data <- aggregate(replaceddata[,3:length(replaceddata)], by = list(activity = replaceddata$activity, subject = replaceddata$subject),FUN = mean)
write.table(output_data, "output_data.txt", row.name=FALSE )

