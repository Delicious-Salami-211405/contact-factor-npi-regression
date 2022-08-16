# Main model for smoothing incidence and estimating Re

# Get packages if not installed
install.packages('fda')
install.packages('ggplot2')
install.packages('reshape')

# Set random seed
set.seed(8)

# Load libraries
library(fda)
library(ggplot2)
library(reshape)

# Load the formatted cumulative case data
# Pre-process for daily case data

# Load daily cases
# Data excludes Luxembourg due to early cumulative cases issues
data_case_cum <- read.csv(paste(getwd(), "/data/europe_case_cum.csv", sep=""))
data_case_daily <- read.csv(paste(getwd(), "/data/europe_case_daily.csv", sep=""))

# Normalise both sets of data by population size
# Load population size
pop_size <- read.csv(paste(getwd(), "/data/population_data.csv", sep=""))
pop_size_1m <- pop_size / 1e6

# Data dimensions
n_curves <- dim(data_case_daily)[2] - 1
n_rows <- dim(data_case_daily)[1]

# Filteirng and smoothing of daily data
# 1. Make all negative values NAs
for (i in 1:n_curves) {
	idx <- which(data_case_daily[, i+1] < 0)
	if (length(idx) > 0) {
		for (j in 1:length(idx)) {
			data_case_daily[idx[j], i+1] <- NA # Make NA negative imputed daily case figures. These reflect downard adjustments
		}
	}
}

# 2. Local administrative day reporting smoothing
# Administrative days in which local authorities do not report cases are smoothed out
data_case_daily_smooth <- data_case_daily
for (i in 1:n_curves) {
	idx <- which(data_case_daily_smooth[, i+1] == 0)
	idx_consec <- split(idx, cumsum(c(1, diff(idx) != 1)))
	for (j in 1:length(idx_consec)) {
		last_idx <- tail(idx_consec[[j]], 1) # Get the last index of the consecutive numbers list
		total_val <- data_case_daily_smooth[last_idx+1 , i + 1] # Get the first day of reporting after admin break
		smoothed_val <- total_val / (length(idx_consec[[j]]) + 1) # Divide by number of 0 days + 1, as first reporting day includes that day's figures
		data_case_daily_smooth[idx_consec[[j]], i + 1] <- smoothed_val # Assign smoothed average val to 0 days admin days
		data_case_daily_smooth[last_idx + 1, i + 1] <- smoothed_val # Assign first admin reporting day smoothed val
	}
}

# Convert data frame dates
data_case_cum$Date <- as.Date(data_case_cum$Date, "%Y-%m-%d")
data_case_daily$Date <- as.Date(data_case_daily$Date, "%Y-%m-%d")
data_case_daily_smooth$Date <- as.Date(data_case_daily_smooth$Date, "%Y-%m-%d")

# Choose start and end dates for subsets
start_date <- "2020-01-31" 
end_date <- "2020-09-01"
start_date <- as.Date(start_date, "%Y-%m-%d")
end_date <- as.Date(end_date, "%Y-%m-%d")

# Get indices for start and end dates
start_idx <- which(data_case_daily_smooth$Date==start_date)
end_idx <- which(data_case_daily_smooth$Date==end_date)

# Get dataframe for study period and remove NAs in incidnece data
data_case_daily_smooth_nona <- na.omit(data_case_daily_smooth[start_idx:end_idx, ])

# Get data matrix
dailycase <- as.matrix(data_case_daily_smooth_nona[, 2:(n_curves+1)])
abscissa <- as.numeric(rownames(data_case_daily_smooth_nona))
abscissa <- abscissa - min(abscissa) + 1

# Log of daily incidence for functional form ln(y(t)) = phi(t) x c
ln_dailycase <- log(dailycase)

# Set out parameters for fitting curves
num_order <- 4 # Cubic spline
# Number of basis
nbasis <- length(abscissa) + num_order - 2
rng <- c(min(abscissa), max(abscissa))
casebasis <- create.bspline.basis(rng, nbasis, num_order, abscissa)
deriv_penalty <- 2 # 2nd derivative roughness penalty
cvecf <- matrix(0, nbasis, n_curves) # Init matrix
Wfd_init <- fd(coef = cvecf, basisobj = casebasis)

# Choose optimal lambda bbased on GCV
lambda <- 10 ** seq(-3, 7, by = 0.05)
gcv <- numeric(length(lambda)) # Sum all GCVs for each country curve
dof <- numeric(length(lambda)) # trace(S), S = phi %*% y2cMap
for (i in 1:length(lambda)){
	functionalPar <- fdPar(fdobj=Wfd_init, Lfdobj=deriv_penalty, lambda=lambda[i])
	ln_smooth_curve <- smooth.basis(abscissa, ln_dailycase, functionalPar)
	gcv[i] <- sum(ln_smooth_curve$gcv)
	dof[i] <- ln_smooth_curve$df
}

# Find lambda for global minimum of GCV
min_gcv <- min(gcv)
lambda_min <- lambda[which(gcv == min_gcv)]

# Calculate GCV standard error
gcv_sd <- sqrt(var(gcv))
gcv_se <- gcv_sd / sqrt(length(gcv))
gcv_lower <- min_gcv - gcv_se
gcv_upper <- min_gcv + gcv_se

# Choose lambda
lambda_opt <- 1e2 # Choose 100, which has GCV score within 1 SE of global min of GCV
lambda_idx <- which(lambda==lambda_opt)
gcv[lambda_idx]

# Plot the GCV vs. log lambda
plot(log(lambda[1:161], base=10), gcv[1:161], main="GCV Score vs. Roughness Penalty", xlab="Log(10) Lambda", ylab="GCV Score", type="l")
legend(-3, 30, legend=c("Selected Log Lambda", "Log Lambda (Min GCV)"), col=c("blue", "red"), lty=1, lwd=3, cex=1.0, box.lty=0)
abline(v=log(lambda_opt, base=10), col="blue")
abline(v=log(lambda_min, base=10), col="red")

# Fit model on log data
# Set growfdPar
growfdPar <- fdPar(Wfd_init, deriv_penalty, lambda_opt)

# Smoothing splines on log of daily cases
pos_dailycase_fd <- smooth.basis(abscissa, ln_dailycase, growfdPar) 

# Get fd object
Wfdobj <- pos_dailycase_fd$fd

# Evaluate functional form on abscissa 
# Model y(t) = exp(phi * c)
country_daily_val <- exp(eval.basis(abscissa, casebasis, Lfdobj=0) %*% Wfdobj$coefs)

# Convert to dataframe
country_daily_val <- data.frame(country_daily_val)
country_daily_val$Days <- abscissa
country_daily_val <- country_daily_val[, c(n_curves+1, 1:n_curves)]
names(country_daily_val) <- names(data_case_daily_smooth_nona)

# Confidence intervals
smooth_mat <- eval.basis(abscissa, casebasis) %*% pos_dailycase_fd$y2cMap
dof <- sum(diag(smooth_mat))

# Log the basis expansion
ln_yhat <- eval.basis(abscissa, casebasis, Lfdobj=0) %*% Wfdobj$coefs

# Calculate SSE and estimate of sigma^2
SSE <- diag(t(ln_yhat - ln_dailycase) %*% (ln_yhat - ln_dailycase))
sigma2 <- SSE / (length(abscissa) - dof)

# Pointwise variance for each country curve
var_mat <- matrix(0, length(abscissa), n_curves)
diag_smooth_mat <- diag(smooth_mat %*% t(smooth_mat))
for (i in 1:n_curves) {
	var_mat[, i] <- sigma2[[i]] * diag_smooth_mat
}

# Upper and lower CI matrices
ln_lowerbound <- ln_yhat - qnorm(0.975) * sqrt(var_mat)
ln_upperbound <- ln_yhat + qnorm(0.975) * sqrt(var_mat)

# Transform the CIs from log into daily case CIs
yhat <- exp(ln_yhat)
lowerbound <- exp(ln_lowerbound)
upperbound <- exp(ln_upperbound)

# Convert to data frames and fill with NAs to align on abscissa
lowerbound <- data.frame(lowerbound)
names(lowerbound) <- names(data_case_daily_smooth)[2:(n_curves+1)]
lowerbound$Days <- abscissa
lowerbound <- lowerbound[, c(n_curves+1, 1:n_curves)]

# Upperbound for CIs
upperbound <- data.frame(upperbound)
names(upperbound) <- names(data_case_daily_smooth)[2:(n_curves+1)]
upperbound$Days <- abscissa
upperbound <- upperbound[, c(n_curves+1, 1:n_curves)]

# Fit values over entire abscissa (inference for missing values)
abscissa_new <- seq(min(abscissa), max(abscissa))
# Evaluate across entire 215 day period
country_daily_val_full <- exp(eval.basis(abscissa_new, casebasis, Lfdobj=0) %*% Wfdobj$coefs)
output_date <- data_case_daily_smooth$Date[start_idx:end_idx]

# Convert to df
country_daily_val_full <- data.frame(country_daily_val_full)
country_daily_val_full$Date <- output_date
country_daily_val_full <- country_daily_val_full[, c(n_curves+1, 1:n_curves)]
names(country_daily_val_full) <- names(data_case_daily_smooth)

# Save interpolated incidence output
write.table(country_daily_val_full, file=paste(getwd(), "/data-regression/data_smoothed_incidence.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

# Numerical integration to calculate smoothed incidence
x0 <- min(abscissa_new) # Start of abscissa
xn <- max(abscissa_new) # End of abscissa

# Define fine grid
x_fine <- seq(x0, xn, by=1e-2)
# Compute the values for the fitted functions
y_fine <- exp(eval.basis(x_fine, casebasis, Lfdobj=0) %*% Wfdobj$coefs)
# Get index of points
discrete_points <- c()
for (i in 1:length(abscissa_new)) {
	idx <- which(x_fine==abscissa_new[i])
	discrete_points <- c(discrete_points, idx)
}

# Define trapezoid integration rule
trapezoid_integration <- function(h, y_fine, xn, discrete_points) {
	integral <- matrix(0, xn, n_curves)
	x0_val <- y_fine[1, ]
	for (i in 1:n_curves) {
		for (j in 2:xn) {
			integral_sum <- x0_val[i] + 2*sum(y_fine[2:(discrete_points[j]-1), i]) + y_fine[discrete_points[j], i]
			integral[j, i] <- (h/2) * integral_sum
		}
	}
	integral[1, ] <- x0_val
	return(integral)
}

# Calculate integrals I(b) - I(a) = area under incidence curve
# I(b) = I(a) + area under incidence curve
integral_cumulative <- trapezoid_integration(1e-2, y_fine, xn, discrete_points)

# Estimate I(a) as cumulative sum of cases before start date (31 Jan 2020)
# Index is 1:9 since first available date is 23 Jan 2020
Ia <- as.vector(colSums(as.matrix(data_case_daily[1:9, 2:(n_curves+1)])))
integral_cumulative <- integral_cumulative + rep(Ia, each=nrow(integral_cumulative))

# Susceptible proportion
susceptible_prop <- matrix(0, max(abscissa_new), 30)

# Calculate time varying susceptible proportion for each country
for (i in 1:n_curves) {
	susceptible_prop[, i] <- 1 - integral_cumulative[, i] / pop_size[[i]]
}

# Convert to dataframe
susceptible_prop <- data.frame(susceptible_prop)
susceptible_prop$Date <- country_daily_val_full$Date
names(susceptible_prop) <- names(data_case_daily)[2:(n_curves+1)]
susceptible_prop <- susceptible_prop[, c(n_curves+1, 1:n_curves)]
names(susceptible_prop) <- names(country_daily_val_full)

# Save dataframe for regression models
write.table(susceptible_prop, file=paste(getwd(), "/data-regression/susceptible_prop.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

########################################
# Multple plots of fits of daily cases #
########################################

countries <- names(data_case_daily_smooth_nona[2:(n_curves+1)])
quartz()
par(mfrow=c(2, 3))
for (i in 1:6){
	plot(abscissa, data_case_daily_smooth_nona[, i+1], main=countries[i], xlab="Days Since Jan 31 2020", ylab="Daily Incidence", col=1, cex.lab=1., cex=1.)
	lines(abscissa, country_daily_val[, i+1], col=4, lwd=2)
	lines(abscissa, lowerbound[, i+1], col=6, lwd=2)
	lines(abscissa, upperbound[, i+1], col=6, lwd=2)
}

#########################################
# Cislaghi's r(t) on smoothed incidence #
#########################################

tfine <- seq(1, (end_idx-start_idx+1), by=1)
# Evaluate over entire abscissa estimating for days with missing values
incidence_hat <- exp(eval.basis(tfine, casebasis, Lfdobj=0) %*% Wfdobj$coefs)

# Cislaghi r(t) from initial outbreak
t_incubation <- 3
rt_hat <- incidence_hat[(t_incubation+1):(dim(incidence_hat)[1]), ] / incidence_hat[1:(dim(incidence_hat)[1]-t_incubation), ]

##########################################
# Registration on max of r(t) (Cislaghi) #
##########################################

# Find max of r(t) Cislaghi method
max_idx <- c()
for (i in 1:n_curves) {
	max_rt <- max(rt_hat[1:100, i])
	max_idx <- c(max_idx, which(rt_hat[1:100, i]==max_rt)) 
}

# Study period
study_period <- 60
start <- 5 # days after max
end <- start + study_period

# Get aligned data on max of r(t)
data_rt_aligned <- matrix(0, nrow=study_period, ncol=n_curves)
for (i in 1:n_curves) {
	data_rt_aligned[, i] = rt_hat[(max_idx[i]+start):(max_idx[i]+end-1), i]
}

# Prepare as data frame
data_rt_aligned <- data.frame(data_rt_aligned)
data_rt_aligned$Days <- seq(1, study_period, by=1)
data_rt_aligned <- data_rt_aligned[c(n_curves+1, 1:n_curves)]
names(data_rt_aligned) <- names(data_case_daily_smooth)

# Save as input into regression model
write.table(data_rt_aligned, file=paste(getwd(), "/data-regression/data_rt_aligned.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)

########################################
# Start end end dates for study period #
########################################

# Max registration method

# Calculate the start and end dates for each curve
rt_period_start <- c()
for (i in 1:n_curves) {
	rt_period_start <- c(rt_period_start, start_date + t_incubation + (max_idx[i] + start - 1)) # Add incubation time
}

# Calculate the end dates
rt_period_end <- c()
for (i in 1:n_curves) {
	rt_period_end <- c(rt_period_end, rt_period_start[i] + (study_period-1))
}

# Adjust dates
rt_period_start <- as.Date(rt_period_start, origin='1970-01-01')
rt_period_end <- as.Date(rt_period_end, origin='1970-01-01')

# Convert to string
for (i in 1:n_curves){
	rt_period_start[i] <- toString(rt_period_start[i])
	rt_period_end[i] <- toString(rt_period_end[i])
}

# Save start and end dates together
start_end_dates <- data.frame(matrix(0, nrow=n_curves, ncol=2))
start_end_dates$Country <- names(data_case_daily_smooth)[2:(n_curves+1)]
start_end_dates <- start_end_dates[, c(3, 1:2)]
start_end_dates[, 2] <- rt_period_start
start_end_dates[, 3] <- rt_period_end

# Rename
names(start_end_dates) <- c("Country", "Start", "End")

# Save start and end dates
write.table(start_end_dates, file=paste(getwd(), "/data-regression/start_end_dates.csv", sep=""), sep=",", row.names=FALSE, col.names=TRUE)






