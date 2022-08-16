# Custom permutation metrics
import numpy as np

#################
# Scalar Metric #
#################

def eval_metric(y_hat, y):
	# Calculate variance from mean curve (constant value through time)
	# Sample variance, not estimator of population variance
	curve_var = np.var(y_hat, ddof=1)
	point_res_sq = np.mean((y_hat - y) ** 2, axis=0)
	return var_trace / l2_residuals

# MSE metric
def mse(y_hat, y):
	return np.mean((y_hat - y) ** 2)

# MSE inv metric total
def mse_inv_total(y_hat, y):
	return 1 / np.mean((y_hat - y) ** 2)	

# L1 metric
def l1(y_hat, y):
	return np.mean(np.abs(y_hat - y))

####################
# Pointwise Metric #
####################

# MSE inverse
def mse_inv(y_hat, y):
	mse = np.mean((y_hat - y) ** 2, axis=0)
	return 1 / mse

# L1 inverse
def l1_inv(y_hat, y):
	l1 = np.mean(np.abs(y_hat - y), axis=0)
	return 1 / l1