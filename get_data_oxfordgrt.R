# Get Oxford GRT data

# Install packages if required
install.packages('RCurl')
install.packages('lubridate')

# Import libraries
library(RCurl)
library(lubridate)

# Get data for each response variable
# Stringency Index
# Containment & Health Index
# Government Response Index
# C1 - School Closure
# C2 - Workplace Closing
# C3 - Cancel Public Events
# C4 - Restrictions on Gatherings
# C5 - Close Public Transport
# C6 - Stay At Home Requirements (Lockdowns)
# C7 - Restrictions on Internal Movement
# C8 - International Travel Controls
# E1 - Income Support
# E2 - Debt / Contract Relief
# H1 - Public Information Campaigns 
# H2 - Testing Policy
# H3 - Contact Tracing
# H6 - Facial Coverings
# H7 - Vaccination Policy
# H8 - Protection of Elderly People

# Stringency + Containment & Health Index may be more useful

####################
# Stringency Index #
####################

# Link to raw data on Github
link_stringency <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/stringency_index.csv')
data_raw <- read.csv(text=link_stringency)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_stringency <- data_raw
rm(data_raw)

# Transpose C1 data set
data_stringency <- t(data_stringency)
data_stringency <- data_stringency[-1, ]
data_stringency <- data.frame(data_stringency)
data_stringency$Date <- rownames(data_stringency)

# Re-arrange columns
data_stringency <- data_stringency[, c(dim(data_stringency)[2], 1:(dim(data_stringency)[2]-1))]
rownames(data_stringency) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_stringency)[1])) {
	date_col <- c(date_col, gsub("X", "", data_stringency$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_stringency$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_stringency, file=paste(getwd(), "/data-grt/data_grt_stringency.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

##############################
# Contaimment & Health Index #
##############################

# Link to raw data on Github
link_containment <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/containment_health_index.csv')
data_raw <- read.csv(text=link_containment)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_containment <- data_raw
rm(data_raw)

# Transpose C1 data set
data_containment <- t(data_containment)
data_containment <- data_containment[-1, ]
data_containment <- data.frame(data_containment)
data_containment$Date <- rownames(data_containment)

# Re-arrange columns
data_containment <- data_containment[, c(dim(data_containment)[2], 1:(dim(data_containment)[2]-1))]
rownames(data_containment) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_containment)[1])) {
	date_col <- c(date_col, gsub("X", "", data_containment$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_containment$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_containment, file=paste(getwd(), "/data-grt/data_grt_containment.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

##############################
# Government Response Index ##
##############################

# Link to raw data on Github
link_grt <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/government_response_index.csv')
data_raw <- read.csv(text=link_grt)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_grt <- data_raw
rm(data_raw)

# Transpose C1 data set
data_grt <- t(data_grt)
data_grt <- data_grt[-1, ]
data_grt <- data.frame(data_grt)
data_grt$Date <- rownames(data_grt)

# Re-arrange columns
data_grt <- data_grt[, c(dim(data_grt)[2], 1:(dim(data_grt)[2]-1))]
rownames(data_grt) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_grt)[1])) {
	date_col <- c(date_col, gsub("X", "", data_grt$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_grt$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_grt, file=paste(getwd(), "/data-grt/data_grt_govresponse.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


#####################
# C1 School Closure #
#####################

# Link to raw data on Github
link1 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c1_school_closing.csv')
data_raw <- read.csv(text=link1)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c1 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c1 <- t(data_c1)
data_c1 <- data_c1[-1, ]
data_c1 <- data.frame(data_c1)
data_c1$Date <- rownames(data_c1)

# Re-arrange columns
data_c1 <- data_c1[, c(dim(data_c1)[2], 1:(dim(data_c1)[2]-1))]
rownames(data_c1) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c1)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c1$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c1$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c1, file=paste(getwd(), "/data-grt/subindex/data_grt_c1.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

###########
# C1 Flag #
###########

# Link to raw data on Github
link1_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c1_flag.csv')
data_raw <- read.csv(text=link1_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c1_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c1_f <- t(data_c1_f)
data_c1_f <- data_c1_f[-1, ]
data_c1_f <- data.frame(data_c1_f)
data_c1_f$Date <- rownames(data_c1_f)

# Re-arrange columns
data_c1_f <- data_c1_f[, c(dim(data_c1_f)[2], 1:(dim(data_c1_f)[2]-1))]
rownames(data_c1_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c1_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c1_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c1_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c1_f, file=paste(getwd(), "/data-grt/subindex/data_grt_c1_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

########################
# C2 Workplace Closing #
########################

# Link to raw data on Github
link2 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c2_workplace_closing.csv')
data_raw <- read.csv(text=link2)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c2 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c2 <- t(data_c2)
data_c2 <- data_c2[-1, ]
data_c2 <- data.frame(data_c2)
data_c2$Date <- rownames(data_c2)

# Re-arrange columns
data_c2 <- data_c2[, c(dim(data_c2)[2], 1:(dim(data_c2)[2]-1))]
rownames(data_c2) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c2)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c2$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c2$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c2, file=paste(getwd(), "/data-grt/subindex/data_grt_c2.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#############################
# C2 Workplace Closing Flag #
#############################

# Link to raw data on Github
link2_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c2_flag.csv')
data_raw <- read.csv(text=link2_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c2_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c2_f <- t(data_c2_f)
data_c2_f <- data_c2_f[-1, ]
data_c2_f <- data.frame(data_c2_f)
data_c2_f$Date <- rownames(data_c2_f)

# Re-arrange columns
data_c2_f <- data_c2_f[, c(dim(data_c2_f)[2], 1:(dim(data_c2_f)[2]-1))]
rownames(data_c2_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c2_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c2_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c2_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c2_f, file=paste(getwd(), "/data-grt/subindex/data_grt_c2_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

###########################
# C3 Cancel Public Events #
###########################

# Link to raw data on Github
link3 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c3_cancel_public_events.csv')
data_raw <- read.csv(text=link3)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c3 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c3 <- t(data_c3)
data_c3 <- data_c3[-1, ]
data_c3 <- data.frame(data_c3)
data_c3$Date <- rownames(data_c3)

# Re-arrange columns
data_c3 <- data_c3[, c(dim(data_c3)[2], 1:(dim(data_c3)[2]-1))]
rownames(data_c3) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c3)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c3$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c3$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c3, file=paste(getwd(), "/data-grt/subindex/data_grt_c3.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

################################
# C3 Cancel Public Events Flag #
################################

# Link to raw data on Github
link3_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c3_flag.csv')
data_raw <- read.csv(text=link3_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c3_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c3_f <- t(data_c3_f)
data_c3_f <- data_c3_f[-1, ]
data_c3_f <- data.frame(data_c3_f)
data_c3_f$Date <- rownames(data_c3_f)

# Re-arrange columns
data_c3_f <- data_c3_f[, c(dim(data_c3_f)[2], 1:(dim(data_c3_f)[2]-1))]
rownames(data_c3_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c3_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c3_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c3_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c3_f, file=paste(getwd(), "/data-grt/subindex/data_grt_c3_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


#################################
# C4 Restrictions on Gatherings #
#################################

# Link to raw data on Github
link4 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c4_restrictions_on_gatherings.csv')
data_raw <- read.csv(text=link4)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c4 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c4 <- t(data_c4)
data_c4 <- data_c4[-1, ]
data_c4 <- data.frame(data_c4)
data_c4$Date <- rownames(data_c4)

# Re-arrange columns
data_c4 <- data_c4[, c(dim(data_c4)[2], 1:(dim(data_c4)[2]-1))]
rownames(data_c4) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c4)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c4$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c4$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c4, file=paste(getwd(), "/data-grt/subindex/data_grt_c4.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


######################################
# C4 Restrictions on Gatherings Flag #
######################################

# Link to raw data on Github
link4_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c4_flag.csv')
data_raw <- read.csv(text=link4_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c4_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c4_f <- t(data_c4_f)
data_c4_f <- data_c4_f[-1, ]
data_c4_f <- data.frame(data_c4_f)
data_c4_f$Date <- rownames(data_c4_f)

# Re-arrange columns
data_c4_f <- data_c4_f[, c(dim(data_c4_f)[2], 1:(dim(data_c4_f)[2]-1))]
rownames(data_c4_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c4_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c4_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c4_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c4_f, file=paste(getwd(), "/data-grt/subindex/data_grt_c4_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


#################################
# C5 Close Public Transport #####
#################################

# Link to raw data on Github
link5 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c5_close_public_transport.csv')
data_raw <- read.csv(text=link5)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c5 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c5 <- t(data_c5)
data_c5 <- data_c5[-1, ]
data_c5 <- data.frame(data_c5)
data_c5$Date <- rownames(data_c5)

# Re-arrange columns
data_c5 <- data_c5[, c(dim(data_c5)[2], 1:(dim(data_c5)[2]-1))]
rownames(data_c5) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c5)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c5$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c5$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c5, file=paste(getwd(), "/data-grt/subindex/data_grt_c5.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

######################################
# C5 Close Public Transport Flag #####
######################################

# Link to raw data on Github
link5_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c5_flag.csv')
data_raw <- read.csv(text=link5_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c5_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c5_f <- t(data_c5_f)
data_c5_f <- data_c5_f[-1, ]
data_c5_f <- data.frame(data_c5_f)
data_c5_f$Date <- rownames(data_c5_f)

# Re-arrange columns
data_c5_f <- data_c5_f[, c(dim(data_c5_f)[2], 1:(dim(data_c5_f)[2]-1))]
rownames(data_c5_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c5_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c5_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c5_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c5_f, file=paste(getwd(), "/data-grt/subindex/data_grt_c5_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


####################################
# C6 Stay At Home Requirements #####
####################################

# Link to raw data on Github
link6 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c6_stay_at_home_requirements.csv')
data_raw <- read.csv(text=link6)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c6 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c6 <- t(data_c6)
data_c6 <- data_c6[-1, ]
data_c6 <- data.frame(data_c6)
data_c6$Date <- rownames(data_c6)

# Re-arrange columns
data_c6 <- data_c6[, c(dim(data_c6)[2], 1:(dim(data_c6)[2]-1))]
rownames(data_c6) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c6)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c6$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c6$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c6, file=paste(getwd(), "/data-grt/subindex/data_grt_c6.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#########################################
# C6 Stay At Home Requirements Flag #####
#########################################

# Link to raw data on Github
link6_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c6_flag.csv')
data_raw <- read.csv(text=link6_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c6_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c6_f <- t(data_c6_f)
data_c6_f <- data_c6_f[-1, ]
data_c6_f <- data.frame(data_c6_f)
data_c6_f$Date <- rownames(data_c6_f)

# Re-arrange columns
data_c6_f <- data_c6_f[, c(dim(data_c6_f)[2], 1:(dim(data_c6_f)[2]-1))]
rownames(data_c6_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c6_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c6_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c6_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c6_f, file=paste(getwd(), "/data-grt/subindex/data_grt_c6_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


############################################
# C7 Restrictions on Internal Movement #####
############################################

# Link to raw data on Github
link7 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c7_movementrestrictions.csv')
data_raw <- read.csv(text=link7)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c7 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c7 <- t(data_c7)
data_c7 <- data_c7[-1, ]
data_c7 <- data.frame(data_c7)
data_c7$Date <- rownames(data_c7)

# Re-arrange columns
data_c7 <- data_c7[, c(dim(data_c7)[2], 1:(dim(data_c7)[2]-1))]
rownames(data_c7) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c7)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c7$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c7$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c7, file=paste(getwd(), "/data-grt/subindex/data_grt_c7.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#################################################
# C7 Restrictions on Internal Movement Flag #####
#################################################

# Link to raw data on Github
link7_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c7_flag.csv')
data_raw <- read.csv(text=link7_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c7_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c7_f <- t(data_c7_f)
data_c7_f <- data_c7_f[-1, ]
data_c7_f <- data.frame(data_c7_f)
data_c7_f$Date <- rownames(data_c7_f)

# Re-arrange columns
data_c7_f <- data_c7_f[, c(dim(data_c7_f)[2], 1:(dim(data_c7_f)[2]-1))]
rownames(data_c7_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c7_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c7_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c7_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c7_f, file=paste(getwd(), "/data-grt/subindex/data_grt_c7_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


############################################
# C8 International Travel Controls #########
############################################

# Link to raw data on Github
link8 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c8_internationaltravel.csv')
data_raw <- read.csv(text=link8)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_c8 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_c8 <- t(data_c8)
data_c8 <- data_c8[-1, ]
data_c8 <- data.frame(data_c8)
data_c8$Date <- rownames(data_c8)

# Re-arrange columns
data_c8 <- data_c8[, c(dim(data_c8)[2], 1:(dim(data_c8)[2]-1))]
rownames(data_c8) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_c8)[1])) {
	date_col <- c(date_col, gsub("X", "", data_c8$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_c8$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_c8, file=paste(getwd(), "/data-grt/subindex/data_grt_c8.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# E1 Income Support #
#####################

# Link to raw data on Github
link9 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/e1_income_support.csv')
data_raw <- read.csv(text=link9)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_e1 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_e1 <- t(data_e1)
data_e1 <- data_e1[-1, ]
data_e1 <- data.frame(data_e1)
data_e1$Date <- rownames(data_e1)

# Re-arrange columns
data_e1 <- data_e1[, c(dim(data_e1)[2], 1:(dim(data_e1)[2]-1))]
rownames(data_e1) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_e1)[1])) {
	date_col <- c(date_col, gsub("X", "", data_e1$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_e1$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_e1, file=paste(getwd(), "/data-grt/subindex/data_grt_e1.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

##########################
# E1 Income Support Flag #
##########################

# Link to raw data on Github
link9_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/e1_flag.csv')
data_raw <- read.csv(text=link9_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_e1_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_e1_f <- t(data_e1_f)
data_e1_f <- data_e1_f[-1, ]
data_e1_f <- data.frame(data_e1_f)
data_e1_f$Date <- rownames(data_e1_f)

# Re-arrange columns
data_e1_f <- data_e1_f[, c(dim(data_e1_f)[2], 1:(dim(data_e1_f)[2]-1))]
rownames(data_e1_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_e1_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_e1_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_e1_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_e1_f, file=paste(getwd(), "/data-grt/subindex/data_grt_e1_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


#############################
# E2 Debt / Contract Relief #
#############################

# Link to raw data on Github
link10 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/e2_debtrelief.csv')
data_raw <- read.csv(text=link10)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_e2 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_e2 <- t(data_e2)
data_e2 <- data_e2[-1, ]
data_e2 <- data.frame(data_e2)
data_e2$Date <- rownames(data_e2)

# Re-arrange columns
data_e2 <- data_e2[, c(dim(data_e2)[2], 1:(dim(data_e2)[2]-1))]
rownames(data_e2) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_e2)[1])) {
	date_col <- c(date_col, gsub("X", "", data_e2$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_e2$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_e2, file=paste(getwd(), "/data-grt/subindex/data_grt_e2.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


###################################
# H1 Public Information Campaigns #
###################################

# Link to raw data on Github
link11 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h1_public_information_campaigns.csv')
data_raw <- read.csv(text=link11)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h1 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h1 <- t(data_h1)
data_h1 <- data_h1[-1, ]
data_h1 <- data.frame(data_h1)
data_h1$Date <- rownames(data_h1)

# Re-arrange columns
data_h1 <- data_h1[, c(dim(data_h1)[2], 1:(dim(data_h1)[2]-1))]
rownames(data_h1) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h1)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h1$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h1$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h1, file=paste(getwd(), "/data-grt/subindex/data_grt_h1.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

########################################
# H1 Public Information Campaigns Flag #
########################################

# Link to raw data on Github
link11_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h1_flag.csv')
data_raw <- read.csv(text=link11_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h1_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h1_f <- t(data_h1_f)
data_h1_f <- data_h1_f[-1, ]
data_h1_f <- data.frame(data_h1_f)
data_h1_f$Date <- rownames(data_h1_f)

# Re-arrange columns
data_h1_f <- data_h1_f[, c(dim(data_h1_f)[2], 1:(dim(data_h1_f)[2]-1))]
rownames(data_h1_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h1_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h1_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h1_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h1_f, file=paste(getwd(), "/data-grt/subindex/data_grt_h1_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


#####################
# H2 Testing Policy #
#####################

# Link to raw data on Github
link12 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h2_testing_policy.csv')
data_raw <- read.csv(text=link12)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h2 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h2 <- t(data_h2)
data_h2 <- data_h2[-1, ]
data_h2 <- data.frame(data_h2)
data_h2$Date <- rownames(data_h2)

# Re-arrange columns
data_h2 <- data_h2[, c(dim(data_h2)[2], 1:(dim(data_h2)[2]-1))]
rownames(data_h2) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h2)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h2$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h2$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h2, file=paste(getwd(), "/data-grt/subindex/data_grt_h2.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


######################
# H3 Contact Tracing #
######################

# Link to raw data on Github
link13 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h3_contact_tracing.csv')
data_raw <- read.csv(text=link13)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h3 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h3 <- t(data_h3)
data_h3 <- data_h3[-1, ]
data_h3 <- data.frame(data_h3)
data_h3$Date <- rownames(data_h3)

# Re-arrange columns
data_h3 <- data_h3[, c(dim(data_h3)[2], 1:(dim(data_h3)[2]-1))]
rownames(data_h3) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h3)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h3$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h3$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h3, file=paste(getwd(), "/data-grt/subindex/data_grt_h3.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


#######################
# H6 Facial Coverings #
#######################

# Link to raw data on Github
link14 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h6_facial_coverings.csv')
data_raw <- read.csv(text=link14)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h6 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h6 <- t(data_h6)
data_h6 <- data_h6[-1, ]
data_h6 <- data.frame(data_h6)
data_h6$Date <- rownames(data_h6)

# Re-arrange columns
data_h6 <- data_h6[, c(dim(data_h6)[2], 1:(dim(data_h6)[2]-1))]
rownames(data_h6) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h6)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h6$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h6$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h6, file=paste(getwd(), "/data-grt/subindex/data_grt_h6.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

############################
# H6 Facial Coverings Flag #
############################

# Link to raw data on Github
link14_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h6_flag.csv')
data_raw <- read.csv(text=link14_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h6_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h6_f <- t(data_h6_f)
data_h6_f <- data_h6_f[-1, ]
data_h6_f <- data.frame(data_h6_f)
data_h6_f$Date <- rownames(data_h6_f)

# Re-arrange columns
data_h6_f <- data_h6_f[, c(dim(data_h6_f)[2], 1:(dim(data_h6_f)[2]-1))]
rownames(data_h6_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h6_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h6_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h6_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h6_f, file=paste(getwd(), "/data-grt/subindex/data_grt_h6_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


#########################
# H7 Vaccination Policy #
#########################

# Link to raw data on Github
link15 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h7_vaccination_policy.csv')
data_raw <- read.csv(text=link15)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h7 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h7 <- t(data_h7)
data_h7 <- data_h7[-1, ]
data_h7 <- data.frame(data_h7)
data_h7$Date <- rownames(data_h7)

# Re-arrange columns
data_h7 <- data_h7[, c(dim(data_h7)[2], 1:(dim(data_h7)[2]-1))]
rownames(data_h7) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h7)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h7$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h7$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h7, file=paste(getwd(), "/data-grt/subindex/data_grt_h7.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

##############################
# H7 Vaccination Policy Flag #
##############################

# Link to raw data on Github
link15_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h7_flag.csv')
data_raw <- read.csv(text=link15_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h7_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h7_f <- t(data_h7_f)
data_h7_f <- data_h7_f[-1, ]
data_h7_f <- data.frame(data_h7_f)
data_h7_f$Date <- rownames(data_h7_f)

# Re-arrange columns
data_h7_f <- data_h7_f[, c(dim(data_h7_f)[2], 1:(dim(data_h7_f)[2]-1))]
rownames(data_h7_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h7_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h7_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h7_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h7_f, file=paste(getwd(), "/data-grt/subindex/data_grt_h7_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


###################################
# H8 Protection of Elderly People #
###################################

# Link to raw data on Github
link16 <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h8_protection_of_elderly_people.csv')
data_raw <- read.csv(text=link16)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h8 <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h8 <- t(data_h8)
data_h8 <- data_h8[-1, ]
data_h8 <- data.frame(data_h8)
data_h8$Date <- rownames(data_h8)

# Re-arrange columns
data_h8 <- data_h8[, c(dim(data_h8)[2], 1:(dim(data_h8)[2]-1))]
rownames(data_h8) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h8)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h8$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h8$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h8, file=paste(getwd(), "/data-grt/subindex/data_grt_h8.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

########################################
# H8 Protection of Elderly People Flag #
########################################

# Link to raw data on Github
link16_f <- getURL('https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/h8_flag.csv')
data_raw <- read.csv(text=link16_f)

# EU + UK countries (use country codes)
selection_countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Ireland", "Italy", 
	"Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom")

# Remove other countries
selection_index <- c()
for (i in 1:length(selection_countries)) {
	selection_index <- c(selection_index, which(data_raw$country_name == selection_countries[i]))
}

# Remove other countries
data_raw <- data_raw[selection_index, ]
# Drop the first column "X" and "country codes"
data_raw <- data_raw[, -which(names(data_raw) == "X")]
data_raw <- data_raw[, -which(names(data_raw) == "country_code")]

# Rename the rows
rownames(data_raw) <- selection_countries
data_h8_f <- data_raw
rm(data_raw)

# Transpose C1 data set
data_h8_f <- t(data_h8_f)
data_h8_f <- data_h8_f[-1, ]
data_h8_f <- data.frame(data_h8_f)
data_h8_f$Date <- rownames(data_h8_f)

# Re-arrange columns
data_h8_f <- data_h8_f[, c(dim(data_h8_f)[2], 1:(dim(data_h8_f)[2]-1))]
rownames(data_h8_f) <- NULL

# Convert date column to add separating "." between days / month, month / year
date_col <- c()
for (i in 1:(dim(data_h8_f)[1])) {
	date_col <- c(date_col, gsub("X", "", data_h8_f$Date[i]))
	date_col[i] <- sub("(.{2})(.*)", "\\1.\\2", date_col[i])
	date_col[i] <- sub("(.{6})(.*)", "\\1.\\2", date_col[i])
}

month_strings <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
# Convert the string months into numerics
for (i in 1:length(date_col)) {
	filter <- which(month_strings == substring(date_col[i], 4, 6)) # Index positon 4 to 6 for string months
	date_col[i] <- gsub(month_strings[filter], filter, date_col[i])
}

# Convert to date format
date_col <- as.Date(date_col, "%d.%m.%Y")
for (i in 1:length(date_col)) {
	date_col[i] <- toString(date_col[i])
}

# Relabel date column in dataframe
data_h8_f$Date <- date_col

# Save dataframe into separate Oxford GRT folder
write.table(data_h8_f, file=paste(getwd(), "/data-grt/subindex/data_grt_h8_flag.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)



