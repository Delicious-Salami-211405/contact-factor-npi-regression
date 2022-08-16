# Additive reconstruction model

import torch
import math as m 
import random
import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt
import os

# Import custom built temporal NN models
import functional_nn

#############################
# Estimate Contact Factor f #
#############################
random.seed(8)
# Read in stringency index and functional response plus start, end dates
# Alignment dates
start_end_dates = pd.read_csv(os.getcwd()+'/data-regression/start_end_dates.csv')

# Estimate of Re
# Use the data_rt_aligned_rt file
rt = pd.read_csv(os.getcwd()+'/data-regression/data_rt_aligned.csv')

# Susceptible proportion input
susceptible = pd.read_csv(os.getcwd()+'/data-regression/susceptible_prop.csv')

# Convert y_hat to torch tensor
n_days, n_curves = rt.shape
n_curves -= 1

# Extract susceptible tensor
susceptible_tensor = np.zeros((n_days, n_curves))
for i in range(n_curves):
	start_idx = np.where(susceptible.loc[:, "Date"] == start_end_dates.loc[:, "Start"][i])[0][0]
	end_idx = np.where(susceptible.loc[:, "Date"] == start_end_dates.loc[:, "End"][i])[0][0]
	susceptible_tensor[:, i] = susceptible.iloc[:, (i+1)][start_idx:(end_idx+1)]

# Convert susceptible proportions into torch tensor
susceptible_tensor = torch.tensor(susceptible_tensor.T, requires_grad=False).float()

# Convert transpose of Re to torch tensor
rt_tensor = rt.T.iloc[1:(n_curves+1),:].values
rt_tensor = torch.tensor(rt_tensor, requires_grad=False).float()

# Log response and input
ln_susceptible_tensor = torch.log(susceptible_tensor)
y = torch.log(rt_tensor)

# Plot aligned Re curves
plt.plot(rt_tensor.T)
plt.xlabel("Days in Study Period")
plt.ylabel("Effective Reproductive Number (Re)")
plt.title("Aligned Re Curves (n=30)")
plt.axhline(y=1.0, color="black")
plt.show()

#############################
# First Step: Estimate f(t) #
#############################

# Input dims
study_period = 60
n_countries = 30
# 1 r(0) estimate for each country
weight_dim = [[n_countries, study_period], [n_countries, 1]]

# Use Glorot normal initialisation
sd_w_ft = (2 / (n_countries + study_period)) ** 0.5
sd_b0 = (2 / (n_countries + 1)) ** 0.5
init_vals = [[-0.1, sd_w_ft], [0.1, sd_b0]]

# Input list
train_list = [ln_susceptible_tensor]

# Instantiate model 
lr1 = 5e-4
fn_model_ft = functional_nn.fnNetwork_fhat1_add(weight_dim, init_vals)
# Define the loss and optimizer
loss_fn = torch.nn.MSELoss(reduction='mean')
optimizer = torch.optim.Adam(fn_model_ft.parameters(), lr=lr1)

# Constrained optimisation
constrained_opt = True

# Define accumulators to track training and validation loss
train_loss = []

n_epoch = 30000
# Start training loop
# Weight clamped model for stringency index
for t in range(n_epoch):
	# Forward pass
	y_pred = fn_model_ft(train_list)
	# Compute loss
	loss = loss_fn(y_pred, y)
	# Zero gradients, perform backward pass, and update weights
	optimizer.zero_grad()
	loss.backward()
	optimizer.step()
	# Constrain the stringency weight matrix to be non-positive
	if constrained_opt:
		with torch.no_grad():
			fn_model_ft.w_1.data = fn_model_ft.w_1.data.clamp(max=0.0)
	if t % 1000 == 999:
		train_loss.append(loss.item())
		print(t, train_loss[-1])

# Get ln(f(t)) and ln(b0)
ln_f, ln_b0 = fn_model_ft.w_1.detach().numpy(), fn_model_ft.b0.detach().numpy() 

# Exponentiate values
f_t = np.exp(ln_f)
b0 = np.exp(ln_b0)

# Plot the contact factors for each country
plt.plot(f_t.T)
plt.xlabel("Days in Study Period")
plt.ylabel("Contact Factor f(t)")
plt.title("Estimated Contact Factor Curves (n=30)")
plt.show()

# Convert to data frame
f_t_hat_df = pd.DataFrame(f_t)

# Save beta dataframe for use in R
f_t_hat_df.to_csv(os.getcwd()+'/results-regression/f_t_hat.csv', header=True, index=False)



