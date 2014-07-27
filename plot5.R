## Downloading and extracting the file
if(!(
    file.exists("./data/Source_Classification_Code.rds") & file.exists("./data/summarySCC_PM25.rds")
)) {
    
    url = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    if(!(file.exists("./data/NEI_data-archieve.zip"))) {
        download.file(url,destfile="./data/NEI_data-archieve.zip", method="curl")
    }
    unzip("./data/NEI_data-archieve.zip", exdir = "./data/")
}

# Reading the data
if(!("NEI" %in% ls())) {
    NEI <- readRDS("./data/summarySCC_PM25.rds")
}
if(!("SCC" %in% ls())) {
    SCC <- readRDS("./data/Source_Classification_Code.rds")
}

# Subsetting the data
library(reshape2)
vehiclerows <- grep("Vehicles",SCC$EI.Sector)
vehicledata <- SCC[vehiclerows,]
colnames(vehicledata)[2]<-"type"
vehicledata[,2]<-toupper(vehicledata[,2])
vehicledata$type <- gsub("ROAD","-ROAD",vehicledata$type)
NEIvehicle <- merge(NEI,vehicledata[,1:2])
baltimoreNEIvehicle <- NEIvehicle[NEIvehicle$fips=="24510",]
cleanbaltimoreNEIvehicle <- melt(baltimoreNEIvehicle,id = c("SCC","type","year"),measure.vars="Emissions")
castbaltimoreNEIvehicle <- dcast(cleanbaltimoreNEIvehicle, year + type ~ variable, sum)
colnames(castbaltimoreNEIvehicle) <- c("Year","Source_Type","Total_Emission")

# Plotting data
library(ggplot2)
graph <- qplot(Year, Total_Emission, data=castbaltimoreNEIvehicle, geom = c("point","smooth"), method="lm", se = FALSE, ylab = "Total Emission (tons)", main = "Total Emission for Motor Vehicle Sources in Baltimore City")
print(graph)

if (!(file.exists("./NEI_Analysis/"))) {
    dir.create("./NEI_Analysis/")
}
dev.copy(png,file="./NEI_Analysis/plot5.png",height=480, width=480)
dev.off()




