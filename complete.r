complete <-function(directory, id) {
	nobs<-numeric('0')
    for(i in id) {						
        csv <- read.csv(paste(directory, "/",sprintf("%03d", i), ".csv", sep=''), header=TRUE)
        compl_obs<-nrow(na.omit(csv))
        nobs<-c(nobs,compl_obs)
    }

	data<-data.frame(id,nobs)
	return(data)
    }