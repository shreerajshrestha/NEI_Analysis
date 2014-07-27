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
coalrows <- grep("Coal",SCC$EI.Sector)
coaldata <- SCC[coalrows,]
colnames(coaldata)[2]<-"type"
coaldata[,2]<-toupper(coaldata[,2])
NEIcoal <- merge(NEI,coaldata[,1:2])
cleanNEIcoal <- melt(NEIcoal,id = c("SCC","type","year"),measure.vars="Emissions")
castNEIcoal <- dcast(cleanNEIcoal, year + type ~ variable, sum)
colnames(castNEIcoal) <- c("Year","Source_Type","Total_Emission")
castNEIcoal$Total_Emission <- castNEIcoal$Total_Emission/1000

# Plotting data
library(ggplot2)
graph <- qplot(Year, log(Total_Emission), data=castNEIcoal, facets = ~Source_Type, geom = c("point","smooth"), method="lm", se = FALSE, ylab = "log[ Total Emission (thousand tons) ]", main = "Total Emission for Coal Combustion Related Sources By Source Type")
print(graph)

if (!(file.exists("./NEI_Analysis/"))) {
    dir.create("./NEI_Analysis/")
}
dev.copy(png,file="./NEI_Analysis/plot4.png",height=480, width=480)
dev.off()



