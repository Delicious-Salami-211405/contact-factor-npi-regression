# K-fold CV for partial temperature (14 day SMA) model

import torch
import math as m 
import random
import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt
import os
import statsmodels.api as sm

# Import custom NN 
import functional_nn

#######################
# Import Data & Align #
#######################
random.seed(8)
# Read in contact factor and temperature covariates
# Alignment dates
start_end_dates = pd.read_csv(os.getcwd()+'/data-regression/start_end_dates.csv')

# f_t estimate 
f_t = pd.read_csv(os.getcwd()+'/results-regression/f_t_hat.csv')

# Functional feature (averaged country wide daily mean temperature)
daily_temp = pd.read_csv(os.getcwd()+'/data-temp/data_temp.csv')

# Mean monthly temperature (climatic effects)
monthly_temp = pd.read_csv(os.getcwd()+'/data-temp/data_month_avg_temp.csv')

# 14 day SMA of temperature (balance between monthly average and daily variations)
sma14_temp = pd.read_csv(os.getcwd()+'/data-temp/data_sma14_temp.csv')

# 30 day SMA of temperature
sma30_temp = pd.read_csv(os.getcwd()+'/data-temp/data_sma30_temp.csv')

# Convert y_hat to torch tensor
n_days, n_curves = 60, 30

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

############################
# Convert to Tensor Inputs #
############################

n_countries = n_curves
study_period = n_days

# Convert to tensor
f_t_tensor = torch.tensor(np.matrix(f_t), requires_grad=False).float()

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

#############
# K-fold CV #
#############

# Lag in the model (i.e. full study period used)
lag = 60

# N folds
K = 5
n_fold = n_curves / K

# Shuffle index for folds
shuffle_index = np.arange(0, n_curves)
np.random.shuffle(shuffle_index)

# Set epochs
n_epoch = 30000
epoch_list = np.arange(500, n_epoch+1, 500)
n_measure = n_epoch / 500

# Set lambdas
l1_lamb = [1e-4, 5e-4, 1e-3, 5e-3, 1e-2, 5e-2, 1e-1]
n_lamb = len(l1_lamb)

# Set learning rates
lr = [5e-5, 1e-4, 5e-4, 1e-3, 5e-3, 1e-2]

# Input weight dims
weight_dim = [[study_period, 1], [study_period, 1]]

# Glorot normal initialisation
sd_init = np.sqrt(2. / (study_period + 1))

# Initialisation values
init_vals = [[0, sd_init]]

# Set up collection table
kf_results = pd.DataFrame({"Key": [str(n_epoch) + '-' + 'Lambda-{}'.format(str(l1_lamb[0])) + '-' + 'LR-{}'.format(str(lr[0]))] * int(n_epoch/500), "Epoch": epoch_list, "Average Train": [0] * int(n_epoch/500), "Average Val": [0] * int(n_epoch/500)})

# Start CV
for i in range(n_lamb):
	for j in range(len(lr)):
		# Define accumulators
		train_mat = np.zeros((K, int(n_epoch/500)))
		val_mat = np.zeros((K, int(n_epoch/500)))
		for k in range(K):
			val_idx = shuffle_index[int(n_fold * k):int(n_fold * k + n_fold)]
			train_idx = [idx for idx in range(n_curves) if idx not in val_idx]
			# Prepare training and validation input lists
			train_list = [sma14_temp_tensor_3D[train_idx, :, :]]
			y = f_t_tensor[train_idx, :]
			# Validation set
			val_list = [sma14_temp_tensor_3D[val_idx, :, :]]
			y_val = f_t_tensor[val_idx, :]
			# Set up model
			fn_model = functional_nn.fnNetwork_fhat2_vecbeta_single(lag, weight_dim, init_vals)
			loss_fn = torch.nn.MSELoss(reduction='mean')
			optimizer = torch.optim.Adam(fn_model.parameters(), lr=lr[j], betas=(0.9, 0.999))
			# Start training loop on (K-1) folds
			train_loss = []
			val_loss = []
			for t in range(n_epoch):
				# Forward pass
				y_pred = fn_model(train_list)
				# Compute train loss
				loss = loss_fn(y_pred, y)
				# Compute L1 loss (used for backprop)
				l1_loss = loss + l1_lamb[i] * sum([param.abs().sum() for param in fn_model.parameters()])
				optimizer.zero_grad()
				l1_loss.backward()
				optimizer.step()
				if t % 500 == 499:
					# Switch to evaluation mode
					fn_model.eval()
					# Append loss from training
					train_loss.append(loss.item())
					# Validate out on held out fold
					with torch.no_grad():
						y_pred = fn_model(val_list)
						# Validation loss on val set
						v_loss = loss_fn(y_pred, y_val)
						val_loss.append(v_loss.item())
					# Train model
					fn_model.train()
					# Print epoch latest training and validation loss
					print(t, train_loss[-1], val_loss[-1])
			# Assign train and val loss to their rows
			train_mat[k, :] = train_loss
			val_mat[k, :] = val_loss
		# Average fold results for training and validation
		train_avg = np.mean(train_mat, axis=0)
		val_avg = np.sum(val_mat, axis=0)
		if i == 0 and j == 0:
			kf_results.iloc[:, 2] = train_avg
			kf_results.iloc[:, 3] = val_avg
		else:
			fold_res = pd.DataFrame({"Key": [str(n_epoch) + '-' + 'Lambda-{}'.format(str(l1_lamb[i])) + '-' + 'LR-{}'.format(str(lr[j]))] * int(n_epoch/500), "Epoch": epoch_list, "Average Train": train_avg, "Average Val": val_avg})
			kf_results = pd.concat([kf_results, fold_res], axis=0)
	# Print iteration i
	print(i)

# Plot validation curves
for i in range(n_lamb*len(lr)):
	plt.plot(kf_results.iloc[int(i*n_measure):int((i+1)*n_measure), 3])

plt.show()

# Find absolute minimum on val curve
val_min = np.min(kf_results.iloc[:, 3])
# Find index associated with minimum
min_idx = np.where(kf_results.iloc[:, 3] == val_min)[0][0]

# Get parameters
best_params = kf_results.iloc[min_idx, :]
print(best_params)

# Key              30000-Lambda-0.05-LR-0.005
# Epoch                                 25000
# Average Train                      0.082386
# Average Val                        0.394245

# Save K-fold results dataframe
kf_results.to_csv(os.getcwd()+'/results-cv/kf_results_temp.csv', header=True, index=False)

# Plot the temperature over the study period
plt.plot(sma14_temp_tensor)
plt.xlabel("Days in Study Period")
plt.ylabel("Temperature (Celsius)")
plt.title("Temperature (14D SMA) Over Study Period")
plt.show()