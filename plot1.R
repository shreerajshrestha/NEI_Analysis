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

# Aggregating total emission by year
aggdata <- aggregate(NEI$Emissions, list(Year = NEI$year), FUN = sum)
colnames(aggdata)[2] <- "Total_Emission"
aggdata$Total_Emission <- aggdata$Total_Emission/1000000

# Plotting graph with linear fit line
plot(aggdata, type = "n", xaxp=c(1999,2008,3), main = "Total PM 2.5 Emission From All Sources By Year", ylab = "Total Emission (million tons)")
points(aggdata, pch=19)
abline(lm(aggdata$Total_Emission~aggdata$Year), col = 2, lty = 2, lwd = 2)

# Exporting to png file
if (!(file.exists("./NEI_Analysis/"))) {
    dir.create("./NEI_Analysis/")
}
dev.copy(png,file="./NEI_Analysis/plot1.png",height=480, width=480)
dev.off()