library(reshape2)
filename <- "getdata_dataset.zip"
## First download and unzip the dataset from the net if does not exists on your system:
if (!file.exists(filename))
{
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, method="curl")
}  

if (!file.exists("UCI HAR Dataset")) 
{ 
    unzip(filename) 
}


## Load activity labels and the features
Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
Labels[,2] <- as.character(Labels[,2])
x <- read.table("UCI HAR Dataset/features.txt")
x[,2] <- as.character(x[,2])



## Extract only the data on mean and standard deviation to save the time taken in 
## processing the complete data
y <- grep(".*mean.*|.*std.*", x[,2])
y.names <- x[y,2]
y.names = gsub('-mean', 'Mean', y.names)
y.names = gsub('-std', 'Std', y.names)
y.names <- gsub('[-()]', '', y.names)



## Load the datasets in R Studio
tr <- read.table("UCI HAR Dataset/train/X_train.txt")[y]
trAct <- read.table("UCI HAR Dataset/train/y_train.txt")
trSub <- read.table("UCI HAR Dataset/train/subject_train.txt")
tr <- cbind(trSub, trAct, tr)

te <- read.table("UCI HAR Dataset/test/X_test.txt")[y]
teAct <- read.table("UCI HAR Dataset/test/y_test.txt")
teSub <- read.table("UCI HAR Dataset/test/subject_test.txt")
te <- cbind(teSub, teAct, te)


## merge datasets and add labels
Data <- rbind(tr, te)
colnames(Data) <- c("subject", "activity", y.names)


## turn activities & subjects into factors
Data$activity <- factor(Data$activity, levels = Labels[,1], labels = Labels[,2])
Data$subject <- as.factor(Data$subject)


##Convert data frame in to moten data frame
Data.melted <- melt(Data, id = c("subject", "activity"))


##Put means of the molten data frame on array
Data.mean <- dcast(Data.melted, subject + activity ~ variable, mean)


## Write data to the text file names tidy data
write.table(Data.mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)