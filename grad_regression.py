# Gradient check for contact factor regression model

import torch
import math as m 
import random
import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt
import os

# Import custom built temporal NN models
import functional_nn

n_countries = 30
n_curves = 30
study_period = 60

X_unrolled_S = np.ones((study_period, n_countries))
X_unrolled_T = np.ones((study_period, n_countries))

for i in range(study_period):
	X_unrolled_S[:, i] = X_unrolled_S[:, i] * np.random.random()
	X_unrolled_T[:, i] = X_unrolled_T[:, i] * np.random.random()

# Response
C_factor = 0.8 * torch.ones((30, 60))

# Make covariates into stacked tensors
# Reshape input data into 3D tensors
stringency_tensor_list = []
for j in range(n_countries):
	s_mat = np.zeros((study_period, study_period))	
	for i in range(study_period):
		s_mat[i, 0:(i+1)] = np.flip(X_unrolled_S[0:(i+1), j])
	stringency_tensor_list.append(torch.tensor(s_mat, requires_grad=False).float())

# Convert to 3D tensor
stringency_tensor_3D = torch.stack(stringency_tensor_list, dim=0)

# Temp
sma14_temp_tensor_list = []
for j in range(n_countries):
	t_mat = np.zeros((study_period, study_period))
	for i in range(study_period):
		t_mat[i, 0:(i+1)] = np.flip(X_unrolled_T[0:(i+1), j])
	sma14_temp_tensor_list.append(torch.tensor(t_mat, requires_grad=False).float())

# Convert to 3D tensor
sma14_temp_tensor_3D = torch.stack(sma14_temp_tensor_list)

# Define model
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

lr = 5e-4
l1_lambda = 0.1
# Instantiate model
fn_model_stringency_vec = functional_nn.fnNetwork_fhat2_vecbeta(lag, weight_dim, init_vals)
loss_fn = torch.nn.MSELoss(reduction='mean')
optimizer = torch.optim.Adam(fn_model_stringency_vec.parameters(), lr=lr, betas=(0.9, 0.999))

# Forward step
Y_pred = fn_model_stringency_vec(input_list)
loss = loss_fn(Y_pred, C_factor)
# L1 loss
l1_loss = loss + l1_lambda * sum([param.abs().sum() for param in fn_model_stringency_vec.parameters()])

######################
# Check L1 loss calc #
######################

L = 1/(n_countries * study_period) * torch.norm(Y_pred - C_factor, p='fro') ** 2 + l1_lambda * sum([param.abs().sum() for param in fn_model_stringency_vec.parameters()])
print(l1_loss - L)
# Check OK

####################################
# Check vectorised gradient update #
####################################

# Grad check with lambda
optimizer.zero_grad()
l1_loss.backward()

# Get W_S vector and gradient update vector from autograd
W_S_grad = fn_model_stringency_vec.w_1.grad.detach()
# Get W_S vector
W_S_vec = fn_model_stringency_vec.w_1.detach()

# Check for vectorised W_S grad
ones_left = torch.ones((1, n_countries))
ones_right = torch.ones((study_period, 1))

# S_tensor
s_tensor_list = []
for i in range(study_period):
	if i > 0:
		s_mat = X_unrolled_S.T
		s_mat[:, 0:i] = 0
	else:
		s_mat = X_unrolled_S.T
	s_tensor_list.append(torch.tensor(s_mat, requires_grad=False).float())

# Conver to 3D tensor
s_tensor_3D = torch.stack(s_tensor_list)

# L1 penalised grad
dL_dWS = torch.matmul(ones_left, -2/(n_countries * study_period) * (C_factor - Y_pred) * s_tensor_3D)
dL_dWS = torch.matmul(dL_dWS, ones_right)
dL_dWS = torch.squeeze(dL_dWS, dim=2) + l1_lambda * torch.sign(W_S_vec)

print(dL_dWS - W_S_grad)
# Check OK
