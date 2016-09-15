cat("\014")# Clear Console
#dev.off()# Clear All Graphs in the plot area
rm(list=ls(all=TRUE)) # clear variable from the previous run
closeAllConnections() # close any file connections if any
require (digest) # install and load required package for MD5 and SHA algorithms

PNC_NameList <-read.delim2("your_path_to_the_file/your_file_name/file_name", 
                             header = TRUE, sep = "|", row.names=NULL, quote="", comment.char="") # the file fields sep must be '|' separated, however, you can replace the separator with your file fields separator


PData <- PNC_NameList[,c(2,3,4)] # select the patient Date of birth, gender, and last name as the composite ID message


MD5 <- data.frame(PData, uid = apply(PData, 1, digest,algo="md5"),stringsAsFactors=FALSE) # run the MD5 algorithm on the composite message
SHA <- data.frame(PData, uid = apply(PData, 1, digest,algo="sha1"),stringsAsFactors=FALSE) # run the SHA-1 algorithm on the composite message

PNC_NameList<-cbind(PNC_NameList,MD5$uid,SHA$uid) # bind the new encrypted message to your original data for comaprison

con<-file("your_path_to_the_file/UIDs.csv",encoding="UTF-8") # save the new generated IDs in "UIDs.csv" on your current folder
write.table(PNC_NameList,con,row.names=FALSE,col.names=TRUE, sep=",")