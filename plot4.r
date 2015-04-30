df <- read.table(file="C:/Users/HBurak/Documents/R/Exploratory Data Analysis/household_power_consumption.txt",
                   header=TRUE, sep=";",na.strings="?", 
                   colClasses=c("character", "character", "numeric","numeric","numeric","numeric","numeric","numeric","numeric"),
                   stringsAsFactors=FALSE)

df$Date <- as.Date(df$Date,"%d/%m/%Y")
df <- subset (df, Date == as.Date("2007-02-01") | Date == as.Date("2007-02-02"))

df$DateTime <- as.POSIXct(paste(df$Date, df$Time))

png("plot4.png")
plot4.par <- par(mfrow = c(2,2))
plot(x = df$DateTime, y = df$Global_active_power ,type = "l", ylab = "Global Active Power (kilowatts)", xlab = "")
plot(x = df$DateTime, y = df$Voltage ,type = "l", ylab = "Voltage", xlab = "datetime")
matplot(x = df$DateTime, y = cbind(df$Sub_metering_1,df$Sub_metering_2,df$Sub_metering_3), lty = c(1,1,1),
        type = "l", col = c(1,2,4), xlab = "", ylab = "Energy sub metering")
legend("topright",fill = "white", border = "white",legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), col = c(1,2,4),lwd = c(1,1,1))
plot(x = df$DateTime, y = df$Global_reactive_power ,type = "l", ylab = "Global_reactive_power", xlab = "datetime")
par(plot4.par)
plot4
dev.off()