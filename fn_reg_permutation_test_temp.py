# Permutation test for partial model of temperature

import torch
import math as m 
import random
import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt
import os

# Import custom built functional NN models
import functional_nn
import permutation_metric

####################################
# Permutation Test for Temperature #
####################################
random.seed(8)
# Read in contact factor and temperature
# Alignment dates
start_end_dates = pd.read_csv(os.getcwd()+'/data-regression/start_end_dates.csv')

# f_t estimate 
f_t = pd.read_csv(os.getcwd()+'/results-regression/f_t_hat.csv')
f_t = f_t.to_numpy()

# Functional feature (averaged country wide daily mean temperature)
daily_temp = pd.read_csv(os.getcwd()+'/data-temp/data_temp.csv')

# Mean monthly temperature (climatic effects)
monthly_temp = pd.read_csv(os.getcwd()+'/data-temp/data_month_avg_temp.csv')

# 14 day SMA of temperature (balance between monthly average and daily variations)
sma14_temp = pd.read_csv(os.getcwd()+'/data-temp/data_sma14_temp.csv')

# 30 day SMA of temperature
sma30_temp = pd.read_csv(os.getcwd()+'/data-temp/data_sma30_temp.csv')

# Convert y_hat to torch tensor
n_days, n_curves = f_t.T.shape
n_countries = 30
study_period = 60

# Extract each sequence of average daily temperature measurements for different start and end dates
daily_temp_tensor = np.zeros((n_days, n_curves))
for i in range(n_curves):
	start_idx = np.where(daily_temp.loc[:, "Date"] == start_end_dates.loc[:, "Start"][i])[0][0]
	end_idx = np.where(daily_temp.loc[:, "Date"] == start_end_dates.loc[:, "End"][i])[0][0]
	daily_temp_tensor[:, i] = daily_temp.iloc[:, (i+1)][start_idx:(end_idx+1)]

# Mean monthly temperature
monthly_temp_tensor = np.zeros((n_days, n_curves))
for i in range(n_curves):
	start_idx = np.where(monthly_temp.loc[:, "Date"] == start_end_dates.loc[:, "Start"][i])[0][0]
	end_idx = np.where(monthly_temp.loc[:, "Date"] == start_end_dates.loc[:, "End"][i])[0][0]
	monthly_temp_tensor[:, i] = monthly_temp.iloc[:, (i+1)][start_idx:(end_idx+1)]

# 14 day SMA temperature
sma14_temp_tensor = np.zeros((n_days, n_curves))
for i in range(n_curves):
	start_idx = np.where(sma14_temp.loc[:, "Date"] == start_end_dates.loc[:, "Start"][i])[0][0]
	end_idx = np.where(sma14_temp.loc[:, "Date"] == start_end_dates.loc[:, "End"][i])[0][0]
	sma14_temp_tensor[:, i] = sma14_temp.iloc[:, (i+1)][start_idx:(end_idx+1)]

# 30 day SMA temperature
sma30_temp_tensor = np.zeros((n_days, n_curves))
for i in range(n_curves):
	start_idx = np.where(sma30_temp.loc[:, "Date"] == start_end_dates.loc[:, "Start"][i])[0][0]
	end_idx = np.where(sma30_temp.loc[:, "Date"] == start_end_dates.loc[:, "End"][i])[0][0]
	sma30_temp_tensor[:, i] = sma30_temp.iloc[:, (i+1)][start_idx:(end_idx+1)]

# Unroll w_n and f_t
f_t_vec = f_t.reshape((n_curves*n_days))
sma14_temp_vec = sma14_temp_tensor.T.reshape((n_curves*n_days))

# Scatter plot contact factor vs. white noise
plt.scatter(sma14_temp_vec, f_t_vec)
plt.title("Contact Factor vs. Temp (14D SMA)")
plt.xlabel("Temperature (14 SMA) Celsius")
plt.ylabel("Contact Factor (f)")
plt.show()

# Convert to tensor
f_t_tensor = torch.tensor(f_t, requires_grad=False).float()

# Reshape temp data into 3D tensors
daily_temp_tensor_list = []
for j in range(n_countries):
	t_mat = np.zeros((study_period, study_period))	
	for i in range(study_period):
		t_mat[i, 0:(i+1)] = np.flip(daily_temp_tensor[0:(i+1), j])
	daily_temp_tensor_list.append(torch.tensor(t_mat, requires_grad=False).float())

# Convert to 3D tensor
daily_temp_tensor_3D = torch.stack(daily_temp_tensor_list)

# Reshape SMA 14 temp data into 3D tensors
sma14_temp_tensor_list = []
for j in range(n_countries):
	t_mat = np.zeros((study_period, study_period))
	for i in range(study_period):
		t_mat[i, 0:(i+1)] = np.flip(sma14_temp_tensor[0:(i+1), j])
	sma14_temp_tensor_list.append(torch.tensor(t_mat, requires_grad=False).float())

# Convert to 3D tensor
sma14_temp_tensor_3D = torch.stack(sma14_temp_tensor_list)

# Reshape SMA 30 temp data into 3D tensors
sma30_temp_tensor_list = []
for j in range(n_countries):
	t_mat = np.zeros((study_period, study_period))
	for i in range(study_period):
		t_mat[i, 0:(i+1)] = np.flip(sma30_temp_tensor[0:(i+1), j])
	sma30_temp_tensor_list.append(torch.tensor(t_mat, requires_grad=False).float())

# Convert to 3D tensor
sma30_temp_tensor_3D = torch.stack(sma30_temp_tensor_list)

# Introduce lag
lag = 60
# Input weight dims
weight_dim = [[study_period, 1], [study_period, 1]]

# Glorot normal initialisation
sd_init = np.sqrt(2. / (study_period + 1))
# Initialisation values
init_vals = [[0, sd_init]]

# Total input list
# Input list is immutable
input_list = [sma14_temp_tensor_3D]
y = f_t_tensor

# Define number of permutations and training epochs per permutation
n_perm = 2000 # Number of permutations is one less than desired to account for the first iteration being the baseline
n_epoch = 25000

# Learning rate
lr = 0.005
# L1 reg
l1_lambda = 0.05
L1_reg = True
# Constrained optimisation
constrained_opt = False
# Define accumulators to track training and validation loss
train_loss = []

# Collect pointwise metric
test_metric = np.zeros((study_period, n_perm+1))
# Collect maximum across time of pointwise metric for each iteration
norm_metric = []

# Start permutation iterations
for i in range(n_perm+1):
	# Instantiate new model
	print("Iteration {}".format(i+1))
	fn_model_stringency_vec_temp = functional_nn.fnNetwork_fhat2_vecbeta_single(lag, weight_dim, init_vals)
	loss_fn = torch.nn.MSELoss(reduction='mean')
	optimizer = torch.optim.Adam(fn_model_stringency_vec_temp.parameters(), lr=lr, betas=(0.9, 0.999))
	# Permute y
	if i == 0:
		y_perm = y # First iteration compute baseline test statistic with un-permuted y
	else:
		y_perm = y[torch.randperm(n_countries), :]
	for t in range(n_epoch):
		# Forward pass
		y_pred = fn_model_stringency_vec_temp(input_list)
		# Vanilla loss
		loss = loss_fn(y_pred, y_perm)
		if L1_reg:
			# Compute L1 loss (used for backprop, not recorded)
			l1_loss = loss + l1_lambda * sum([param.abs().sum() for param in fn_model_stringency_vec_temp.parameters()])
			optimizer.zero_grad()
			l1_loss.backward()
			optimizer.step()
		else:
			optimizer.zero_grad()
			loss.backward()
			optimizer.step()
		# Constrain the stringency weight matrix to be non-positive
		if constrained_opt:
			with torch.no_grad():
				fn_model_stringency_vec_temp.w_1.data = fn_model_stringency_vec_temp.w_1.data.clamp(max=0.0)
		if t % 1000 == 999:
			# Append loss from training
			train_loss.append(loss.item())
			# Print epoch latest training and validation loss
			print("Epcoch {}".format(t), train_loss[-1])
	# Obtain y_hat estimate from model and compute test metric
	fn_model_stringency_vec_temp.eval()
	y_hat = fn_model_stringency_vec_temp(input_list).detach().numpy()
	# Call permutation_metric for specific criterion to evaluate each permutation
	perm_eval = permutation_metric.mse_inv(y_hat, y.data.numpy())
	test_metric[:, i] = perm_eval
	pointwise_norm = np.linalg.norm(perm_eval, ord=2) # L2 norm
	norm_metric.append(pointwise_norm)
	print(pointwise_norm)

# Get baseline estimates for the model with unpermuted y
baseline_pointwise = test_metric[:, 0]
baseline_norm = norm_metric[0]

# Get critical values for each pointwise
p_val = 0.05
crit_vals = []
for i in range(study_period):
	edf = np.flip(np.sort(test_metric[i, 1:]))
	crit_vals.append(edf[int(p_val*(n_perm+1)-1)])

# Get crit level for max metric
edf = np.flip(np.sort(norm_metric[1:]))
norm_crit_val = edf[int(p_val*n_perm-1)]

# Norm p-value
norm_pval = (np.sum(norm_metric[1:] >= baseline_norm) + 1) / (n_perm + 1)

# Also calculate pointwise p-values
pointwise_pval = []
for i in range(study_period):
	pointwise_pval.append((np.sum(test_metric[i, 1:] >= test_metric[i, 0]) + 1)/ (n_perm + 1))

baseline_norm
norm_crit_val
norm_pval
# Plot histogram of test metrics
plt.hist(norm_metric, bins=80)
plt.axvline(x=baseline_norm, color='orange', linestyle='--')
plt.axvline(x=norm_crit_val, color='red', linestyle='--')
plt.title("Null Distribution for L2 Norm Statistic (Temp.)")
plt.xlabel("L2 Norm of Pointwise Inverse MSE")
plt.ylabel("Frequency")
plt.legend(["Baseline Model Stat: 156.624", "5% Significance Crit. Val: 166.264", "Baseline Model p-value: 0.546"])
plt.show()

# Plot pointwise effects, pointwise crit vals, and max value
plt.plot(baseline_pointwise, color='orange')
plt.plot(crit_vals, color='blue')
plt.show()

# Plot pointwise difference between baseline and crit vals
plt.plot(baseline_pointwise - crit_vals)
plt.show()

# Calculate CI for p-value
lower = norm_pval - 1.96 * (norm_pval * (1 - norm_pval) / 2000) ** 0.5
upper = norm_pval + 1.96 * (norm_pval * (1 - norm_pval) / 2000) ** 0.5
lower
upper

# Save test metric
test_metric_df = pd.DataFrame(test_metric)
test_metric_df.to_csv(os.getcwd()+'/results-permutation/rt_3/partial_temp_pointwise.csv', header=True, index=False)

