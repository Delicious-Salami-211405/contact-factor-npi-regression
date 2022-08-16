# Get clean temperature averages

# Install packages if not already installed
install.packages('dplyr')
install.packages('rnoaa')

# Load R NOAA library
# dplyr package must be imported
library(dplyr)
library(rnoaa)

# Countries selected
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Number of countries
n_countries <- length(selection_countries)

# Get list of all weather stations
# Filtered by average daily temperature and liveness constraint from 2020 to 2022
stations_global <- ghcnd_stations()

# Get country codes and filter for all stations
country_codes <- ghcnd_countries()

# Get country codes
country_codes_list <- c()
for (i in 1:n_countries) {
	idx <- which(country_codes$name == selection_countries[i])
	country_codes_list <- c(country_codes_list, country_codes$code[idx])
}

# Get all weather station data for average temperature for each country from Jan 2020 to June 2022
# Get accumulator

# Define start end dates
start_date <- "2020-01-01"
end_date <- "2022-05-31"
period <- as.Date(end_date, "%Y-%m-%d") - as.Date(start_date, "%Y-%m-%d") + 1
period <- as.numeric(period)

# Average daily temperature df, taken as simple average of daily average temperature across all weather stations in a country
avg_temp_df <- matrix(0, nrow=period, ncol=n_countries)
for (i in 1:n_countries) {
	# Country accumulator
	station_count <- 0
	country_accum <- matrix(0, nrow=period, ncol=1)
	stations_country <- filter(stations_global, grepl(paste("^", country_codes_list[i], sep=""), id), grepl("TAVG", element))
	for (j in 1:length(stations_country$id)) {
		print(stations_country$id[j])
		temp_celsiusx10 <- ghcnd_search(stations_country$id[j], var="TAVG", date_min=start_date, date_max=end_date) # Results given back in Celsius * 10, need to divide by 10 for raw temperature
		if (dim(temp_celsiusx10$tavg)[1] == period) {
			station_count <- station_count + 1
			station_temp <- matrix(temp_celsiusx10$tavg$tavg, nrow=period, ncol=1)
			station_temp[is.na(station_temp)] <- 0 # Map small amounts of NAs to 0
			country_accum <- country_accum + station_temp
			print("Station included")
			print(station_count)
		} else {
			print("Station not included")
			print(station_count)
			next
		}
	}
	# Average accumulated temperatures and divide by 10 as figures are reported as celsius * 10
	country_accum <- country_accum / (station_count * 10)
	avg_temp_df[, i] <- country_accum
}

# Modify and save data frame
dates <- seq(0, period-1)
dates <- dates + as.Date(start_date, "%Y-%m-%d")

# Dataframe
avg_temp_df <- data.frame(avg_temp_df)
names(avg_temp_df) <- selection_countries
avg_temp_df$Date <- dates

# Switch order
avg_temp_df <- avg_temp_df[, c(n_countries+1, 1:n_countries)]

# Save dataframe
write.table(avg_temp_df, file=paste(getwd(), "/data-temp/data_temp.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

###################################
# Average monthly temp data frame #
###################################

m <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")
y <- c("2020", "2021", "2022")

search_idx <- c()
for (i in 1:length(y)) {
	res <- paste(y[i], "-", m, sep="")
	search_idx <- c(search_idx, res)
}

# Assign new dataframe for monthly average temp
avg_month_temp_df <- avg_temp_df
date_char <- as.character(avg_temp_df$Date)

# Calculate average of daily temperatures and assign monthly average to each day in given month
for (i in 1:n_countries) {
	for (j in 1:length(search_idx)) {
		idx <- grepl(search_idx[j], date_char)
		if (sum(idx) > 0) {
			mean_temp <- sum(avg_temp_df[idx, i+1]) / sum(idx)
			avg_month_temp_df[idx, i+1] <- mean_temp
		}
	}
}

# Save dataframe
write.table(avg_month_temp_df, file=paste(getwd(), "/data-temp/data_month_avg_temp.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

################################################
# N day trailing average of daily temperatures #
################################################

n_days <- 7
# SMA temperature
sma7_month_temp_df <- avg_temp_df[(n_days:dim(avg_temp_df)[1]), ]

# SMA calculation
for (i in 1:n_countries) {
	for (j in 1:dim(sma7_month_temp_df)[1]) {
		sma <- mean(avg_temp_df[j:(j+n_days-1), i+1])
		sma7_month_temp_df[j, i+1]
	}
}

# Save dataframe
write.table(sma7_month_temp_df, file=paste(getwd(), "/data-temp/data_sma7_temp.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

# 14 days SMA
n_days <- 14
# SMA temperature
sma14_month_temp_df <- avg_temp_df[(n_days:dim(avg_temp_df)[1]), ]

# SMA calculation
for (i in 1:n_countries) {
	for (j in 1:dim(sma14_month_temp_df)[1]) {
		sma <- mean(avg_temp_df[j:(j+n_days-1), i+1])
		sma14_month_temp_df[j, i+1]
	}
}

# Save dataframe
write.table(sma14_month_temp_df, file=paste(getwd(), "/data-temp/data_sma14_temp.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

# 30 days SMA
n_days <- 30
# SMA temperature
sma30_month_temp_df <- avg_temp_df[(n_days:dim(avg_temp_df)[1]), ]

# SMA calculation
for (i in 1:n_countries) {
	for (j in 1:dim(sma30_month_temp_df)[1]) {
		sma <- mean(avg_temp_df[j:(j+n_days-1), i+1])
		sma30_month_temp_df[j, i+1]
	}
}

# Save dataframe
write.table(sma30_month_temp_df, file=paste(getwd(), "/data-temp/data_sma30_temp.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

