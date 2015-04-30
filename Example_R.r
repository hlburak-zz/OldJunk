
#Read in district data
readdistricts <- read.table("N:/Transfer/HBurak/Specs task/ag092a.txt", header = T, sep = "\t", stringsAsFactors = F, 
                            quote = "",comment.char = "",fill = T, blank.lines.skip=FALSE)
readdistricts <- transform(readdistricts, PK1209 = as.numeric(readdistricts$PK1209))
dim(readdistricts)

##Flag districts with over 30,000 students
dist_over30k <- readdistricts[which(readdistricts$PK1209>=30000),]
dim(dist_over30k)

#Read in school data
readschools <- read.table("N:/Transfer/HBurak/Specs task/sc092a.txt", header = T, sep = "\t", stringsAsFactors = F,
                          quote = "",comment.char = "",fill = T, blank.lines.skip=FALSE)
readschools <- transform(readschools, G0309 = as.numeric(readschools$G0309), G0409 = as.numeric(readschools$G0409), G0509 = as.numeric(readschools$G0509),
                     HI03M09 = as.numeric(readschools$HI03M09), HI03F09 = as.numeric(readschools$HI03F09), 
                     HI04M09 = as.numeric(readschools$HI04M09), HI04F09 = as.numeric(readschools$HI04F09), 
                     HI05M09 = as.numeric(readschools$HI05M09), HI05F09 = as.numeric(readschools$HI05F09), 
                     BL03M09 = as.numeric(readschools$BL03M09), BL03F09 = as.numeric(readschools$BL03F09), 
                     BL04M09 = as.numeric(readschools$BL04M09), BL04F09 = as.numeric(readschools$BL04F09), 
                     BL05M09 = as.numeric(readschools$BL05M09), BL05F09 = as.numeric(readschools$BL05F09), 
                     WH03M09 = as.numeric(readschools$WH03M09), WH03F09 = as.numeric(readschools$WH03F09), 
                     WH04M09 = as.numeric(readschools$WH04M09), WH04F09 = as.numeric(readschools$WH04F09), 
                     WH05M09 = as.numeric(readschools$WH05M09), WH05F09 = as.numeric(readschools$WH05F09))
dim(readschools)
#Subset school data to schools with students in grades 3-5 in districts with over 30k students
schools_largedist <- merge(dist_over30k,readschools, by = "LEAID", all = FALSE)
dim(schools_largedist)
str(as.factor(schools_largedist$LEAID))

schools_largedist <- schools_largedist[which(schools_largedist$G0309 > 0 & schools_largedist$G0409 > 0 & schools_largedist$G0509 > 0),]
dim(schools_largedist)

summary(schools_largedist$G0309)
summary(schools_largedist$G0409)
summary(schools_largedist$G0509)

#Add variables ofinterest
schools_largedist$totalstud  <- schools_largedist$G0309 + schools_largedist$G0409 + schools_largedist$G0509
schools_largedist$more_300 <- ifelse(schools_largedist$totalstud > 300,1,0) 
schools_largedist$avgstud_3to5 <- schools_largedist$totalstud / 3

summary(schools_largedist$totalstud)
summary(schools_largedist$more_300)
summary(schools_largedist$avgstud_3to5)

#Find percent of students by race
##drop observations with invalid race data
schools <- schools_largedist[schools_largedist$HI03M09 >= 0 & schools_largedist$HI03F09 >= 0 & 
                                     schools_largedist$BL03M09 >=0 & schools_largedist$BL03F09 >= 0 & 
                                     schools_largedist$WH03M09 >= 0 & schools_largedist$WH03F09 >= 0 &  
                                     schools_largedist$HI04M09 >= 0 & schools_largedist$HI04F09 >= 0 &  
                                     schools_largedist$BL04M09 >= 0 & schools_largedist$BL04F09 >= 0 & 
                                     schools_largedist$WH04M09 >= 0 & schools_largedist$WH04F09 >= 0 & 
                                     schools_largedist$HI05M09 >= 0 & schools_largedist$HI05F09 >= 0 & 
                                     schools_largedist$BL05M09 >= 0 & schools_largedist$BL05F09 >= 0 &
                                     schools_largedist$WH05M09 >= 0 & schools_largedist$WH05F09 >= 0, ]
dim(schools)

##generate percent race variables
schools$per_hispanic <- ((schools$HI03M09 + schools$HI03F09 + 
                                 schools$HI04M09 + schools$HI04F09 +
                                 schools$HI05M09 + schools$HI05F09)/ schools$totalstud)
schools$per_black <- ((schools$BL03M09 + schools$BL03F09 + 
                                  schools$BL04M09 + schools$BL04F09 +
                                  schools$BL05M09 + schools$BL05F09)/ schools$totalstud)
schools$per_white <- ((schools$WH03M09 + schools$WH03F09 + 
                                  schools$WH04M09 + schools$WH04F09 +
                                  schools$WH05M09 + schools$WH05F09)/ schools$totalstud)

#drop unnecessary variables

keepcols <- c(match("LEAID",names(schools)), match("NAME09",names(schools)),match("FIPST.x",names(schools)),
              match("SCHNO",names(schools)),match("SCHNAM09",names(schools)),
              match("totalstud",names(schools)),match("more_300",names(schools)),match("per_hispanic",names(schools)),
              match("per_white",names(schools)),match("per_black",names(schools)),match("avgstud_3to5",names(schools)))
schools <- schools[keepcols]
names(schools) <- c("leaid","lea_name", "state", "schid", "schoolname", "totalstud", "more_300", "per_hispanic", "per_white", "per_black","avgstud_3to5")

#creat percent variables for schools with over 300 students
schools$hispanic_300p  <- ifelse(schools$more_300 == 1,schools$per_hispanic,NA)
schools$black_300p  <- ifelse(schools$more_300 == 1,schools$per_black,NA)
schools$white_300p  <- ifelse(schools$more_300 == 1,schools$per_white,NA)

dim(schools)
##save school level file

write.csv(schools,"N:/Transfer/HBurak/Specs task/schools.csv",row.names=FALSE)

#create a district level file
library(doBy)
districtsums <- summaryBy(per_hispanic + per_black + per_white + hispanic_300p + black_300p +white_300p
                  ~ leaid,FUN=(mean), id= c("state","lea_name"), data=schools, full.dimension = FALSE, na.rm = TRUE)

names(districtsums) <- c("leaid", "avg_hispanic_all", "avg_black_all", "avg_white_all", 
                         "avg_hispanic_300p", "avg_black_300p", "avg_white_300p", "state", "lea_name")
dim(districtsums)

summary(districtsums$avg_hispanic_all)
summary(districtsums$avg_black_all)
summary(districtsums$avg_white_all)
summary(districtsums$avg_hispanic_300p)
summary(districtsums$avg_black_300p)
summary(districtsums$avg_white_300p)

##save district level file
write.csv(districtsums,"N:/Transfer/HBurak/Specs task/districts.csv",row.names=FALSE)

