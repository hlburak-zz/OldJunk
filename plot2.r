df <- read.table(file="C:/Users/HBurak/Documents/R/Exploratory Data Analysis/household_power_consumption.txt",
                 header=TRUE, sep=";",na.strings="?", 
                 colClasses=c("character", "character", "numeric","numeric","numeric","numeric","numeric","numeric","numeric"),
                 stringsAsFactors=FALSE)

df$Date <- as.Date(df$Date,"%d/%m/%Y")
df <- subset (df, Date == as.Date("2007-02-01") | Date == as.Date("2007-02-02"))

df$DateTime <- as.POSIXct(paste(df$Date, df$Time))

png("plot2.png")
plot2 <- plot(x = df$DateTime, y = df$Global_active_power ,type = "l", ylab = "Global Active Power (kilowatts)", xlab = "")
dev.off()