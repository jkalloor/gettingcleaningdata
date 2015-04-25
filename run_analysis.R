
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