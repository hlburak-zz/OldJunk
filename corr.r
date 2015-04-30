corr<-function(directory,threshold=0){

corr_el<-vector('numeric')
corr_vec<-vector('numeric')

    for(i in 1:322) {
        csv <- read.csv(paste(directory, "/", sprintf("%03d", i), ".csv", sep=''), header=TRUE)
        compl_obs<-nrow(na.omit(csv))
					if (compl_obs >= threshold) {corr_el<-cor(csv$nitrate,csv$sulfate, use="complete")
					} else {corr_el<- NA}
    		corr_vec<-c(corr_vec,round(corr_el,digits=5))
    		}
  corr_vec<-corr_vec[!is.na(corr_vec)]
  return(corr_vec)
   }
   