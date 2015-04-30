best <- function(state, outcome) {
setwd("C:/Users/HBurak/Documents/R/hospitaldata")
	##Read in the data
	outcomes <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
	
	## validate the arguments
	valid_outs<-c("heart failure","heart attack","pneumonia")
	
	validate_st <-  state %in% outcomes$State
	validate_out <- outcome %in% valid_outs
	
	if (validate_st == FALSE) stop('invalid state')
	
	if (validate_out == FALSE) stop('invalid outcome')

	##Create a new dataframe
	STATE <- outcomes$State
	Hospital.Name<- outcomes$Hospital.Name
	ha_30d <- as.numeric(outcomes[, 11])
	hf_30d <- as.numeric(outcomes[, 17])
	pn_30d <- as.numeric(outcomes[, 23])
			
	library(dplyr)
	
	##Limit dataframe with arguments and evaluate best outcome		
	statematrix <- filter(data.frame(STATE, Hospital.Name, ha_30d, hf_30d, pn_30d), STATE == state)
			
	if (outcome == "heart attack") {
			best_outcome <- filter(statematrix,statematrix$ha_30d == min(statematrix$ha_30d,na.rm=T))
			as.character(best_outcome$Hospital.Name)
				}
			else if (outcome == "heart failure"){
					best_outcome <- filter(statematrix,statematrix$hf_30d == min(statematrix$hf_30d,na.rm=T))
					as.character(best_outcome$Hospital.Name)
					}	
				else if (outcome == "pneumonia"){
						best_outcome <- filter(statematrix,statematrix$pn_30d == min(statematrix$pn_30d,na.rm=T))
						as.character(best_outcome$Hospital.Name)
						}
setwd("C:/Users/HBurak/Documents/R")
}
