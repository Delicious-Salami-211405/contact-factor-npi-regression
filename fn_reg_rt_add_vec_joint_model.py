# Temporal vector effects model
# Joint model

import torch
import math as m 
import random
import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt
import os

# Import custom built functional NN models
import functional_nn

random.seed(8)
# Read in contact factor, stringency index and temperature covariates
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

# Functional feature
stringency = pd.read_csv(os.getcwd()+'/data-grt/data_grt_stringency.csv')

# Susceptible proportion input
susceptible = pd.read_csv(os.getcwd()+'/data-regression/susceptible_prop.csv')

# Convert y_hat to torch tensor
n_days, n_curves = f_t.T.shape
n_countries = n_curves
study_period = n_days

# Extract each sequence of stringency index measurements for different start and end dates
stringency_tensor = np.zeros((n_days, n_curves))
for i in range(n_curves):
	start_idx = np.where(stringency.loc[:, "Date"] == start_end_dates.loc[:, "Start"][i])[0][0]
	end_idx = np.where(stringency.loc[:, "Date"] == start_end_dates.loc[:, "End"][i])[0][0]
	stringency_tensor[:, i] = stringency.iloc[:, (i+1)][start_idx:(end_idx+1)]

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

###########################
# Second Step: Model f(t) #
###########################

# Convert to tensor
f_t_tensor = torch.tensor(f_t, requires_grad=False).float()

# Reshape input data into 3D tensors
stringency_tensor_list = []
for j in range(n_countries):
	s_mat = np.zeros((study_period, study_period))	
	for i in range(study_period):
		s_mat[i, 0:(i+1)] = np.flip(stringency_tensor[0:(i+1), j])
	stringency_tensor_list.append(torch.tensor(s_mat, requires_grad=False).float())

# Convert to 3D tensor
stringency_tensor_3D = torch.stack(stringency_tensor_list, dim=0)

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
weight_dim = [[study_period, 1], [study_period, 1], [study_period, 1]]

# Glorot uniform initialisation
sd_init = np.sqrt(2 / (study_period + 1))

# Initialisation values
init_vals = [[0, sd_init], [0, sd_init]]

# Split train and validation
n_val = 6
n_train = n_curves - n_val
val_idx = random.sample(range(n_curves), n_val)
train_idx = [i for i in range(n_curves) if i not in val_idx]

# Total input list
input_list = [stringency_tensor_3D, sma14_temp_tensor_3D]
y = f_t_tensor

lr = 5e-4
# Instantiate model
fn_model_stringency_vec = functional_nn.fnNetwork_fhat2_vecbeta(lag, weight_dim, init_vals)
loss_fn = torch.nn.MSELoss(reduction='mean')
optimizer = torch.optim.Adam(fn_model_stringency_vec.parameters(), lr=lr, betas=(0.9, 0.999))

l1_lambda = 0.1
L1_reg = True
constrained_opt = False

# Define accumulators to track training and validation loss
train_loss = []

n_epoch = 20500
# Start training loop
# Weight clamped model for stringency index
for t in range(n_epoch):
	# Forward pass
	y_pred = fn_model_stringency_vec(input_list)
	# Vanilla loss
	loss = loss_fn(y_pred, y)
	if L1_reg:
		# Compute L1 loss (used for backprop, not recorded)
		l1_loss = loss + l1_lambda * sum([param.abs().sum() for param in fn_model_stringency_vec.parameters()])
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
			fn_model_stringency_vec.w_1.data = fn_model_stringency_vec.w_1.data.clamp(max=0.0)
			fn_model_stringency_vec.w_2.data = fn_model_stringency_vec.w_2.data.clamp(max=0.0)
	# Validation step
	if t % 500 == 499:
		# Append train loss
		train_loss.append(loss.item())
		# Print the training loss
		print(t, train_loss[-1])

# Get both weight vectors
B_S, B_T = fn_model_stringency_vec.w_1.detach().numpy(), fn_model_stringency_vec.w_2.detach().numpy()

# Plot the stringency weights
plt.plot(B_S, color='blue')
plt.plot(B_T, color='orange')
plt.axhline(y=0.0, color="grey")
plt.title("Coefficients for Stringency Index & Temp.")
plt.xlabel("Lag (from 0)")
plt.ylabel("Coefficient Value")
plt.legend(["Stringency Index", "Tenperature"])
plt.show()

# Evaluate outputs
fn_model_stringency_vec.eval()
f_t_pred =  fn_model_stringency_vec(input_list).detach().numpy()

# Plot all curves used in training and validation set against predictions made by network
for i in range(n_curves):
	plt.plot(range(1, n_days+1), f_t[i, :], color="green")
	plt.plot(range(1, n_days+1), f_t_pred[i, :], color="orange")
	plt.show()

# Reshape
B_S, B_T = B_S.reshape((study_period, )), B_T.reshape((study_period, ))
# Save the betas as dataframe
beta_data = {'Stringency': B_S, 'Temperature': B_T}
beta_df = pd.DataFrame(beta_data)

# Save beta dataframe for use in R
beta_df.to_csv(os.getcwd()+'/results-regression/sgd_stringency_temp_beta.csv', header=True, index=False)

# Save train and val loss
train_val_loss = {'Train': train_loss, 'Val': val_loss}
train_val_df = pd.DataFrame(train_val_loss)
train_val_df.to_csv(os.getcwd()+'/results-regression/sgd_stringency_temp_losses.csv', header=True, index=False)

