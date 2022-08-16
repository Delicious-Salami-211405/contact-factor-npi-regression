# Calculate sub-index component scores according to Oxford GRT
# Subindex calculation from Oxford GRT github: 
# https://github.com/OxCGRT/covid-policy-tracker/blob/master/documentation/index_methodology.md#calculating-sub-index-scores-for-each-indicator

# Number of countries
n_countries = 30

# Calc the sub-index scores
index_scores <- function(max, flag, c_score, c_flag, n_countries) {
	if (flag==1) {
		index_mat <- 100 * (as.matrix(c_score[ ,2:(n_countries+1)])-0.5*(flag - as.matrix(c_flag[, 2:(n_countries+1)]))) / max
		index_mat[is.na(index_mat)] <- 0.0}
	else {
		index_mat <- 100 * as.matrix(c_score[ ,2:31]) / max
		index_mat[is.na(index_mat)] <- 0.0}
	return(index_mat)
}

#####################
# C1 Subindex Score #
#####################

# Max of variable = 3, flag = 1
c1 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c1.csv", sep=""))
c1_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c1_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
c1 <- c1[1:nobs, ]
c1_flag <- c1_flag[1:nobs, ]

# Calculate score matrix
c1_score <- index_scores(3, 1, c1, c1_flag, n_countries)
c1_score <- data.frame(c1_score)
c1_score$Date <- c1$Date
c1_score = c1_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(c1_score, file=paste(getwd(), "/data-grt/data_c1_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# C2 Subindex Score #
#####################

# Max of variable = 3, flag = 1
c2 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c2.csv", sep=""))
c2_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c2_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
c2 <- c2[1:nobs, ]
c2_flag <- c2_flag[1:nobs, ]

# Calculate score matrix
c2_score <- index_scores(3, 1, c2, c2_flag, n_countries)
c2_score <- data.frame(c2_score)
c2_score$Date <- c2$Date
c2_score = c2_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(c2_score, file=paste(getwd(), "/data-grt/data_c2_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# C3 Subindex Score #
#####################

# Max of variable = 2, flag = 1
c3 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c3.csv", sep=""))
c3_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c3_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
c3 <- c3[1:nobs, ]
c3_flag <- c3_flag[1:nobs, ]

# Calculate score matrix
c3_score <- index_scores(2, 1, c3, c3_flag, n_countries)
c3_score <- data.frame(c3_score)
c3_score$Date <- c3$Date
c3_score = c3_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(c3_score, file=paste(getwd(), "/data-grt/data_c3_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# C4 Subindex Score #
#####################

# Max of variable = 4, flag = 1
c4 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c4.csv", sep=""))
c4_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c4_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
c4 <- c4[1:nobs, ]
c4_flag <- c4_flag[1:nobs, ]

# Calculate score matrix
c4_score <- index_scores(4, 1, c4, c4_flag, n_countries)
c4_score <- data.frame(c4_score)
c4_score$Date <- c4$Date
c4_score = c4_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(c4_score, file=paste(getwd(), "/data-grt/data_c4_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# C5 Subindex Score #
#####################

# Max of variable = 2, flag = 1
c5 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c5.csv", sep=""))
c5_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c5_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
c5 <- c5[1:nobs, ]
c5_flag <- c5_flag[1:nobs, ]

# Calculate score matrix
c5_score <- index_scores(2, 1, c5, c5_flag, n_countries)
c5_score <- data.frame(c5_score)
c5_score$Date <- c5$Date
c5_score = c5_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(c5_score, file=paste(getwd(), "/data-grt/data_c5_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# C6 Subindex Score #
#####################

# Max of variable = 3, flag = 1
c6 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c6.csv", sep=""))
c6_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c6_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
c6 <- c6[1:nobs, ]
c6_flag <- c6_flag[1:nobs, ]

# Calculate score matrix
c6_score <- index_scores(3, 1, c6, c6_flag, n_countries)
c6_score <- data.frame(c6_score)
c6_score$Date <- c6$Date
c6_score = c6_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(c6_score, file=paste(getwd(), "/data-grt/data_c6_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# C7 Subindex Score #
#####################

# Max of variable = 2, flag = 1
c7 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c7.csv", sep=""))
c7_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c7_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
c7 <- c7[1:nobs, ]
c7_flag <- c7_flag[1:nobs, ]

# Calculate score matrix
c7_score <- index_scores(2, 1, c7, c7_flag, n_countries)
c7_score <- data.frame(c7_score)
c7_score$Date <- c7$Date
c7_score = c7_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(c7_score, file=paste(getwd(), "/data-grt/data_c7_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# C8 Subindex Score #
#####################

# Max of variable = 4, flag = 0
c8 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_c8.csv", sep=""))

# Choose two years of observations
nobs <- 730
c8 <- c8[1:nobs, ]

# Calculate score matrix
c8_score <- index_scores(max=4, flag=0, c_score=c8, n_countries=n_countries)
c8_score <- data.frame(c8_score)
c8_score$Date <- c8$Date
c8_score = c8_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(c8_score, file=paste(getwd(), "/data-grt/data_c8_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# E1 Subindex Score #
#####################

# Max of variable = 2, flag = 1
e1 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_e1.csv", sep=""))
e1_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_e1_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
e1 <- e1[1:nobs, ]
e1_flag <- e1_flag[1:nobs, ]

# Calculate score matrix
e1_score <- index_scores(2, 1, e1, e1_flag, n_countries)
e1_score <- data.frame(e1_score)
e1_score$Date <- e1$Date
e1_score = e1_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(e1_score, file=paste(getwd(), "/data-grt/data_e1_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# E2 Subindex Score #
#####################

# Max of variable = 2, flag = 0
e2 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_e2.csv", sep=""))

# Choose two years of observations
nobs <- 730
e2 <- e2[1:nobs, ]

# Calculate score matrix
e2_score <- index_scores(max=2, flag=0, c_score=e2, n_countries=n_countries)
e2_score <- data.frame(e2_score)
e2_score$Date <- e2$Date
e2_score = e2_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(e2_score, file=paste(getwd(), "/data-grt/data_e2_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# H1 Subindex Score #
#####################

# Max of variable = 2, flag = 1
h1 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h1.csv", sep=""))
h1_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h1_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
h1 <- h1[1:nobs, ]
h1_flag <- h1_flag[1:nobs, ]

# Calculate score matrix
h1_score <- index_scores(2, 1, h1, h1_flag, n_countries)
h1_score <- data.frame(h1_score)
h1_score$Date <- h1$Date
h1_score = h1_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(h1_score, file=paste(getwd(), "/data-grt/data_h1_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# H2 Subindex Score #
#####################

# Max of variable = 3, flag = 0
h2 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h2.csv", sep=""))

# Choose two years of observations
nobs <- 730
h2 <- h2[1:nobs, ]

# Calculate score matrix
h2_score <- index_scores(max=3, flag=0, c_score=h2, n_countries=n_countries)
h2_score <- data.frame(h2_score)
h2_score$Date <- h2$Date
h2_score = h2_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(h2_score, file=paste(getwd(), "/data-grt/data_h2_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# H3 Subindex Score #
#####################

# Max of variable = 2, flag = 0
h3 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h3.csv", sep=""))

# Choose two years of observations
nobs <- 730
h3 <- h3[1:nobs, ]

# Calculate score matrix
h3_score <- index_scores(max=2, flag=0, c_score=h3, n_countries=n_countries)
h3_score <- data.frame(h3_score)
h3_score$Date <- h3$Date
h3_score = h3_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(h3_score, file=paste(getwd(), "/data-grt/data_h3_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

#####################
# H6 Subindex Score #
#####################

# Max of variable = 4, flag = 1
h6 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h6.csv", sep=""))
h6_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h6_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
h6 <- h6[1:nobs, ]
h6_flag <- h6_flag[1:nobs, ]

# Calculate score matrix
h6_score <- index_scores(4, 1, h6, h6_flag, n_countries)
h6_score <- data.frame(h6_score)
h6_score$Date <- h6$Date
h6_score = h6_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(h6_score, file=paste(getwd(), "/data-grt/data_h6_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


#####################
# H7 Subindex Score #
#####################

# Max of variable = 5, flag = 1
h7 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h7.csv", sep=""))
h7_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h7_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
h7 <- h7[1:nobs, ]
h7_flag <- h7_flag[1:nobs, ]

# Calculate score matrix
h7_score <- index_scores(5, 1, h7, h7_flag, n_countries)
h7_score <- data.frame(h7_score)
h7_score$Date <- h7$Date
h7_score = h7_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(h7_score, file=paste(getwd(), "/data-grt/data_h7_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)


#####################
# H8 Subindex Score #
#####################

# Max of variable = 3, flag = 1
h8 <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h8.csv", sep=""))
h8_flag <- read.csv(paste(getwd(), "/data-grt/subindex/data_grt_h8_flag.csv", sep=""))

# Choose two years of observations
nobs <- 730
h8 <- h8[1:nobs, ]
h8_flag <- h8_flag[1:nobs, ]

# Calculate score matrix
h8_score <- index_scores(3, 1, h8, h8_flag, n_countries)
h8_score <- data.frame(h8_score)
h8_score$Date <- h8$Date
h8_score = h8_score[, c(n_countries+1, 1:n_countries)]

# Save scores in main GRT data folder
write.table(h8_score, file=paste(getwd(), "/data-grt/data_h8_scores.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

##################################################
# Check index reconstruction from sub-components #
##################################################

# Check for stringency and containment index
stringency <- read.csv(paste(getwd(), "/data-grt/data_grt_stringency.csv", sep=""))
stringency <- stringency[1:nobs,]

# Stringency estimate (average of 9 component scores)
estimate <- as.matrix(c1_score[,2:31]) + as.matrix(c2_score[,2:31]) + as.matrix(c3_score[,2:31]) + as.matrix(c4_score[,2:31]) + as.matrix(c5_score[,2:31]) + as.matrix(c6_score[,2:31]) + 
as.matrix(c7_score[,2:31]) + as.matrix(c8_score[,2:31]) + as.matrix(h1_score[,2:31])
# Average and round to two decimal places
estimate <- round(estimate / 9.0, 2)

y = as.matrix(stringency[,2:31])

# Check residual of index construction against reported index value
residual = estimate - y
residual  == 0

# Check OK - subcomponents score calcs reconstruct reported stringency index

# Containment index check
containment <- read.csv(paste(getwd(), "/data-grt/data_grt_containment.csv", sep=""))
containment <- containment[1:nobs,]

# Stringency estimate (average of 14 component scores)
estimate <- as.matrix(c1_score[,2:31]) + as.matrix(c2_score[,2:31]) + as.matrix(c3_score[,2:31]) + as.matrix(c4_score[,2:31]) + as.matrix(c5_score[,2:31]) + as.matrix(c6_score[,2:31]) + 
as.matrix(c7_score[,2:31]) + as.matrix(c8_score[,2:31]) + as.matrix(h1_score[,2:31]) + as.matrix(h2_score[,2:31]) + as.matrix(h3_score[,2:31]) + as.matrix(h6_score[,2:31]) + as.matrix(h7_score[,2:31]) + as.matrix(h8_score[,2:31])
# Average and round to two decimal places
estimate <- round(estimate / 14.0, 2)

y = as.matrix(containment[, 2:31])

# Check residual of index construction against reported index value
residual = estimate - y
residual == 0

# Check OK - subcomponents score calcs reconstruct reported containment index

