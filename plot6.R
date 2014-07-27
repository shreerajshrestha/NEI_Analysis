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
baltimoreNEIvehicle$fips <- "Baltimore"
losangelesNEIvehicle <- NEIvehicle[NEIvehicle$fips=="06037",]
losangelesNEIvehicle$fips <- "Los Angeles"
mergedNEIvehicle <- rbind(baltimoreNEIvehicle,losangelesNEIvehicle)
cleanmergedNEIvehicle <- melt(mergedNEIvehicle,id = c("SCC","type","year","fips"),measure.vars="Emissions")
castmergedNEIvehicle <- dcast(cleanmergedNEIvehicle, year + type + fips ~ variable, sum)
colnames(castmergedNEIvehicle) <- c("Year","Source_Type","City","Total_Emission")

# Plotting data
library(ggplot2)
graph <- qplot(Year, log(Total_Emission), data=castmergedNEIvehicle, facets = ~ City, geom = c("point","line","smooth"), method="lm", se = FALSE, ylab = "log [ Total Emission (tons) ]", main = "Total Emission for Motor Vehicle Sources in Baltimore City and California")
print(graph)

if (!(file.exists("./NEI_Analysis/"))) {
    dir.create("./NEI_Analysis/")
}
dev.copy(png,file="./NEI_Analysis/plot6.png",height=480, width=520)
dev.off()