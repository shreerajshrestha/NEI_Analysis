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
baltimoredata <- NEI[NEI$fips==24510,]
baltimoresourcedata <-  aggregate(baltimoredata$Emissions, list(Year = baltimoredata$year, Source_Type = baltimoredata$type), FUN = sum)
colnames(baltimoresourcedata)[3] <- "Total_Emission"
baltimoresourcedata$Total_Emission <- baltimoresourcedata$Total_Emission/1000
baltimoresourcedata$Source_Type <- as.factor(baltimoresourcedata$Source_Type)

# Plotting total emission in Baltimore by source type
library(ggplot2)
graph <- qplot(Year, Total_Emission, data = baltimoresourcedata, geom = c("point","smooth"), method = "lm", se = FALSE, facets = ~ Source_Type, ylab = "Total Emission (thousand tons)", main = "Total Emission for Baltimore City By Source Type And Year")
print(graph)

if (!(file.exists("./NEI_Analysis/"))) {
    dir.create("./NEI_Analysis/")
}
dev.copy(png,file="./NEI_Analysis/plot3.png",height=480, width=480)
dev.off()
