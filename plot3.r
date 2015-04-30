df <- read.table(file="C:/Users/HBurak/Documents/R/Exploratory Data Analysis/household_power_consumption.txt",
                 header=TRUE, sep=";",na.strings="?", 
                 colClasses=c("character", "character", "numeric","numeric","numeric","numeric","numeric","numeric","numeric"),
                 stringsAsFactors=FALSE)

df$Date <- as.Date(df$Date,"%d/%m/%Y")
df <- subset (df, Date == as.Date("2007-02-01") | Date == as.Date("2007-02-02"))

df$DateTime <- as.POSIXct(paste(df$Date, df$Time))

png("plot3.png")
plot3 <- matplot(x = df$DateTime, y = cbind(df$Sub_metering_1,df$Sub_metering_2,df$Sub_metering_3), lty = c(1,1,1),
                 type = "l", col = c(1,2,4), xlab = "", ylab = "Energy sub metering")
legend("topright",legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), col = c(1,2,4),lwd = c(1,1,1))
dev.off()