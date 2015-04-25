The data provided are in different files. We need to use these files and create tidy database.
Download the files using the given URL and unzip it.
There are three main pieces of data : data from test,data from train, and the information 
about the variable in these files. 

R-script run_analysis.R  will be using   R verion 3.1.2 with dplyr and reshape2 libraries.
Modules grep,gsub,merge, cbind,melt,cast , dcast ,and lapply   used.

First the script will read the activity_labels.txt into activitylabels  and assign column names
activityid, activityname
Now we read the features.txt file and cleanup te names a bit by removing the “()” and 
Store it in feature_names .
We will load the testdata from load X_test.txt file.  And  assign clonames  form feature_names
Load the test subject data by reading subject_test.txt and we assign column namesto subjectid.
Read test activity id data from y_test.txt load to testactivityid and assign column namesas activityid.
Now merge the testsubjectid,testactivityid and testdata to create the complete test data DF testdata2 
using cbind.

Now process the training data
Load training data to R df traindta  from X_train.txt and assign column namesfrom feature_names.
Now load train subject data for training from subject_train.txt to R df  trainsubjectid and assign column 
namessubjectid. 
Read train activity id data from y_train.txt to R df  trainactivityid and assign column namesactivityid.
Merge trainsubjectid,trainactivityid and traindata to complete df traindata2 using cbind
# now combine test and train dataframes  to create dataframe alldata
alldata <- rbind(testdata2,traindata2)
# now select only variable with mean and std. for this we will select column names using grep 
And we also select subjectid and activityid from alldata and created datafram “msdata” from alldata.
Now merge msdata with activitylabels by acivityid  to produce dataframe msdescriptdata
Now melt the msdescriptdata using activityid ,activityname and subjectid to a logformated data  
msmeltdata (ref good read:- http://seananderson.ca/2013/10/19/reshape.html)
Since activityid actvityname represent same info let us drop activityid and keep descriptive name
Decast the melted data msmletdata1 with the mean of each variable for each activity
and each subjectid in wide format to create dataframe meandata.
We will also change the column names to Lowercase and also change “-“ to “_” in names.
And finally write the table out to mean_HARUS_tidydata.txt
=======================================
Here is the R-script run_analysis.R: -

{
        #R verion 3.1.2 with dplyr and reshape2 libraries
        library(dplyr)
        library(reshape2)
        
        # read information files from the downloaded and unzipped files
        # read activity label files and assign column names 
        activitylabels <- read.table("C:/Users/JOSEPH/Coursera/HARdata/activity_labels.txt")
        #set colnames as activityid and activityname
        colnames(activitylabels) <-c("activityid","activityname")
        
        #Load features.txt data to R 
        F <- read.table("./HARdata/features.txt")
        # get rid of"()" from  the names 
        F[2] <- lapply(F[2],function(x) (gsub("()", "" , x,fixed=TRUE)))
        feature_names <- F[,2]
        #get rid of temp data 
        rm("F")
        
        #load X_test.txt to R and assign column names
        testdata <- read.table("./HARdata/test/X_test.txt")
        colnames(testdata) <- feature_names
        
        #load test subject data to R and assign column names
        testsubjectid <- read.table("./HARdata/test/subject_test.txt")
        colnames(testsubjectid)<- "subjectid"
        
        #load test activity id data to R and assign column 
        testactivityid <- read.table("./HARdata/test/y_test.txt")
        colnames(testactivityid)<- "activityid"
        
        #merge testsubjectid,testactivityid and testdata dataframes to create dataframe testdata2
        testdata2 <- cbind(testsubjectid,testactivityid,testdata)
        
        #now process the training data
        
        #read training data to R and asign column names
        traindata <- read.table("./HARdata/train/X_train.txt")
        colnames(traindata) <- feature_names
        
        #load train subject data to R ans assign column names
        trainsubjectid <- read.table("./HARdata/train/subject_train.txt")
        colnames(trainsubjectid)<- "subjectid"
        
        #load train activity id data to R ans assign column names
        trainactivityid <- read.table("./HARdata/train/y_train.txt")
        colnames(trainactivityid)<- "activityid"
        
        #merge trainsubjectid,trainactivityid and traindata to complete traindata2
        traindata2 <- cbind(trainsubjectid,trainactivityid,traindata)
        
        # now combine test and train datas to create alldata
        alldata <- rbind(testdata2,traindata2)
        
        # now select only variable with mean and std
        mcolsidx <- grep("mean",names(alldata),ignore.case=TRUE)
        mcolnames <- names(alldata)[mcolsidx]
        scolidx <- grep( "std",names(alldata),ignore.case=TRUE)
        scolnames <- names(alldata)[scolidx]
        #now the required msdata (means & std) is selected from the alldata using colnames 
        msdata <- alldata[,c("subjectid","activityid",c(mcolnames),c(scolnames))]
        
        #Merge actvities data with selected msdata  to  msdesriptdata
        msdescriptdata  <- merge(activitylabels,msdata,by.x="activityid",by.y="activityid",all=TRUE)
        
        #melt the msdescriptdata by id acivityid activityname and subjectid to a longformated data
        # ref: good read:- http://seananderson.ca/2013/10/19/reshape.html
        msmeltdata <- melt(msdescriptdata,id=c("activityid","activityname","subjectid"))
        
        # since activityid actvityname represent same info let us drop activityid and keep descriptive name
        msmeltdata1 <- select(msmeltdata,-(activityid))
        
        #decast the melted data msmletdata1 with the mean of each variable for each activiy
        # and each subject in wide format.
        meandata <- dcast(msmeltdata1,activityname+subjectid~variable,mean)
        
        # change colnames to lowercase. 
        colnames(meandata) <- tolower(names(meandata))
        # change the "-" in column names to "_" 
        colnames(meandata) <- gsub("-", "_" , colnames(meandata),fixed=TRUE)
        # write to txt file
        write.table(meandata,"./HARdata/mean_HARUS_tidydata.txt",row.names=FALSE)
}
==============================
Here are the varibales names in the final data : 
"activityname"
"subjectid"
"tbodyacc_mean_x"
"tbodyacc_mean_y"
"tbodyacc_mean_z"
"tgravityacc_mean_x"
"tgravityacc_mean_y"
"tgravityacc_mean_z"
"tbodyaccjerk_mean_x"
"tbodyaccjerk_mean_y"
"tbodyaccjerk_mean_z"
"tbodygyro_mean_x"
"tbodygyro_mean_y"
"tbodygyro_mean_z"
"tbodygyrojerk_mean_x"
"tbodygyrojerk_mean_y"
"tbodygyrojerk_mean_z"
"tbodyaccmag_mean"
"tgravityaccmag_mean"
"tbodyaccjerkmag_mean"
"tbodygyromag_mean"
"tbodygyrojerkmag_mean"
"fbodyacc_mean_x"
"fbodyacc_mean_y"
"fbodyacc_mean_z"
"fbodyacc_meanfreq_x"
"fbodyacc_meanfreq_y"
"fbodyacc_meanfreq_z"
"fbodyaccjerk_mean_x"
"fbodyaccjerk_mean_y"
"fbodyaccjerk_mean_z"
"fbodyaccjerk_meanfreq_x"
"fbodyaccjerk_meanfreq_y"
"fbodyaccjerk_meanfreq_z"
"fbodygyro_mean_x"
"fbodygyro_mean_y"
"fbodygyro_mean_z"
"fbodygyro_meanfreq_x"
"fbodygyro_meanfreq_y"
"fbodygyro_meanfreq_z"
"fbodyaccmag_mean"
"fbodyaccmag_meanfreq"
"fbodybodyaccjerkmag_mean"
"fbodybodyaccjerkmag_meanfreq"
"fbodybodygyromag_mean"
"fbodybodygyromag_meanfreq"
"fbodybodygyrojerkmag_mean"
"fbodybodygyrojerkmag_meanfreq"
"angle(tbodyaccmean,gravity)"
"angle(tbodyaccjerkmean),gravitymean)"
"angle(tbodygyromean,gravitymean)"
"angle(tbodygyrojerkmean,gravitymean)"
"angle(x,gravitymean)"
"angle(y,gravitymean)"
"angle(z,gravitymean)"
"tbodyacc_std_x"
"tbodyacc_std_y"
"tbodyacc_std_z"
"tgravityacc_std_x"
"tgravityacc_std_y"
"tgravityacc_std_z"
"tbodyaccjerk_std_x"
"tbodyaccjerk_std_y"
"tbodyaccjerk_std_z"
"tbodygyro_std_x"
"tbodygyro_std_y"
"tbodygyro_std_z"
"tbodygyrojerk_std_x"
"tbodygyrojerk_std_y"
"tbodygyrojerk_std_z"
"tbodyaccmag_std"
"tgravityaccmag_std"
"tbodyaccjerkmag_std"
"tbodygyromag_std"
"tbodygyrojerkmag_std"
"fbodyacc_std_x"
"fbodyacc_std_y"
"fbodyacc_std_z"
"fbodyaccjerk_std_x"
"fbodyaccjerk_std_y"
"fbodyaccjerk_std_z"
"fbodygyro_std_x"
"fbodygyro_std_y"
"fbodygyro_std_z"
"fbodyaccmag_std"
"fbodybodyaccjerkmag_std"
"fbodybodygyromag_std"
"fbodybodygyrojerkmag_std"
