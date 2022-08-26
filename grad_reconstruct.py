# Grad test reconstruction model

import torch
import math as m 
import random
import numpy as np
import pandas as pd 
import matplotlib.pyplot as plt
import os

# Import custom built temporal NN models
import functional_nn

X_dat = 0.5*torch.ones((30, 60))
Y_dat = torch.ones((30, 60))

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

# Forward prop 
Y_pred = fn_model_ft(X_dat)
loss = loss_fn(Y_pred, Y_dat)

############################
# Check loss function calc #
############################

L = 1/(n_countries * study_period) * torch.norm(Y_pred - Y_dat, p='fro') ** 2

# Check equivalency
print(L - loss)
# Check OK

###################
# Check gradients #
###################

# Loss backward
optimizer.zero_grad()
loss.backward()

# Get gradients from autograd
w1_grad = fn_model_ft.w_1.grad.detach()
b0_grad = fn_model_ft.b0.grad.detach()

# Manual computation of vectorised gradients
dL_dw = -2/(n_countries * study_period) * (Y_dat - Y_pred)
print(dL_dw - w1_grad)
# OK - manual gradients are correct

# Manual grad check - b0
ones_right = torch.ones((60, 1))
dL_db0 = -2/(n_countries * study_period) * torch.matmul((Y_dat - Y_pred), ones_right)
print(dL_db0 - b0_grad)
# OK - manual gradients are correct

