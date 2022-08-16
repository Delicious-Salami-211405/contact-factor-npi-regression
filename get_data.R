# Get data from John Hopkins github

# Install package if not already installed
install.packages('RCurl')

# Import library
library(RCurl)

# Get data from Github repo
link <- getURL('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv')
data_raw <- read.csv(text=link)

# Remove minor territories for UK, France, Denmark and Netherlands
remove_index <- which(data_raw$Province.State != "")
data_raw <- data_raw[-remove_index, ]

# Get EU + Norway, Switzerland, UK
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czechia", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$Country.Region == selection_countries[i]))
}

# Number of countries
n_countries <- length(selection_countries)

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the province / state, longitude and latitude column
data_raw <- data_raw[, -which(names(data_raw) == "Province.State")]
data_raw <- data_raw[, -which(names(data_raw) == "Lat")]
data_raw <- data_raw[, -which(names(data_raw) == "Long")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_case_cum <- data_raw
rm(data_raw)

# Transpose cumulative data set
data_case_cum <- t(data_case_cum)
data_case_cum <- data_case_cum[-1, ]
data_case_cum <- data.frame(data_case_cum)

# Convert date column
date_col <- c()
for (i in 1:(dim(data_case_cum)[1])) {
	date_col <- c(date_col, gsub("X", "", rownames(data_case_cum)[i]))
}

# Add date column
data_case_cum$Date <- date_col
rownames(data_case_cum) <- NULL
# Re-order columns
data_case_cum <- data_case_cum[, c((n_countries+1), 1:n_countries)]

# Convert date format
data_case_cum$Date <- as.Date(data_case_cum$Date, "%m.%d.%y")

# Convert to numeric
data_case_cum[, 2:dim(data_case_cum)[2]] <- data.frame(lapply(data_case_cum[, 2:dim(data_case_cum)[2]], as.numeric))

# Save the data to the data directory within the project folder
wd <- paste(getwd(), "/data", sep="")
setwd(wd)

# Save data case cumulative
write.table(data_case_cum, file=paste(getwd(), "/europe_case_cum.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

# Compute daily case backward difference, save data and extract separate aligned dataset for smoothing
# Number of curves
n_curves = dim(data_case_cum)[2] - 1

# Calculate daily case loads
num_row <- dim(data_case_cum)[1]

# Daily case data
data_case_daily <- as.matrix(data_case_cum[2:num_row,2:(n_curves+1)])-as.matrix(data_case_cum[1:(num_row-1),2:(n_curves+1)])

# Convert to data frame
data_case_daily <- data.frame(data_case_daily)
data_case_daily$Date <- data_case_cum$Date[2:num_row]

# Re-arrange date column
data_case_daily <- data_case_daily[, c((n_curves+1), 1:n_curves)]

# Save data case daily
write.table(data_case_daily, file=paste(getwd(), "/europe_case_daily.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)
