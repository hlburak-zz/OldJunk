pollutantmean <-function(directory, pollutant, id) {
		data_to_analyze = NA
    for(i in id) {
        csv <- read.csv(paste(directory, "/", sprintf("%03d",id[i]), ".csv", sep=''), header=TRUE)
        data_to_analyze <- rbind(data_to_analyze, csv)
    }
    return(mean(data_to_analyze[[pollutant]], na.rm=TRUE))
}