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

# Aggregating total emissions by year for baltimore data
baltimoreaggdata <- aggregate(baltimoredata$Emissions, list(Year = baltimoredata$year), FUN = sum)
colnames(baltimoreaggdata)[2] <- "Total_Emission"
baltimoreaggdata$Total_Emission <- baltimoreaggdata$Total_Emission/1000

# Plotting graph with linear fit line
plot(baltimoreaggdata, type = "n", xaxp=c(1999,2008,3), main = "Total PM 2.5 Emission For Baltimore City By Year", ylab = "Total Emission (thousand tons)")
points(baltimoreaggdata, pch = 19)
abline(lm(baltimoreaggdata$Total_Emission~baltimoreaggdata$Year), col = 2, lty = 2, lwd = 2)

# Exporting to png file
if (!(file.exists("./NEI_Analysis/"))) {
    dir.create("./NEI_Analysis/")
}
dev.copy(png,file="./NEI_Analysis/plot2.png",height=480, width=480)
dev.off()