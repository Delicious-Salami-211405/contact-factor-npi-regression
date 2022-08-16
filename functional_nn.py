# Temporal neural network models

import torch
import math as m 
import numpy as np
import torch.nn.functional as F

################################
# Reconstruction Model Buildup #
################################

# Reconstruction model formulation 1
# re = r0 * f(t) * (S/N)
class fnNetwork_fhat1_prod(torch.nn.Module):
	def __init__(self, weight_dim, init_vals):
		"""
		Instantiate the weight matrix and the bias for single variable model
		"""
		super(fnNetwork_fhat1_prod, self).__init__()
		# w_1 - represents ln[f]
		self.w_1 = torch.nn.Parameter(torch.nn.init.normal_(torch.ones(weight_dim[0]), init_vals[0][0], init_vals[0][1]), requires_grad=True)
		# b0 - represents ln[r0]
		self.b0 = torch.nn.Parameter(torch.nn.init.normal_(torch.ones(weight_dim[1]), init_vals[1][0], init_vals[1][1]), requires_grad=True)
	# Forward step
	def forward(self, input_list):
		"""
		Forward pass of network
		Accept a tensor of size (n x t) ln[S/N] and outputs a tensor of size ln[Re] (n x t)
		"""
		# Hadamard product of input_list[0], weights, and the scalar b0
		out = input_list[0] * self.w_1 * self.b0
		return out

# Reconstruction model formulation 2
# log transform
# additive: ln[re] = ln[r0] + ln[f(t)] + ln[S/N]

class fnNetwork_fhat1_add(torch.nn.Module):
	def __init__(self, weight_dim, init_vals):
		"""
		Instantiate ln[f] and ln[r0] parameters
		"""
		super(fnNetwork_fhat1_add, self).__init__()
		# w_1 - represents ln[f]
		self.w_1 = torch.nn.Parameter(torch.nn.init.normal_(torch.ones(weight_dim[0]), init_vals[0][0], init_vals[0][1]), requires_grad=True)
		# b0 - represents ln[r0]
		self.b0 = torch.nn.Parameter(torch.nn.init.normal_(torch.ones(weight_dim[1]), init_vals[1][0], init_vals[1][1]), requires_grad=True)
	# Forward step
	def forward(self, input_list):
		"""
		Forward pass of network
		"""
		out = self.b0 + self.w_1 + input_list[0] # Input data of log of susceptible ratio
		return out


####################################
# Contact Factor Regression Models #
####################################

# Uppper triangular weight model with additive effects
# [NOT USED]
class fnNetwork_fhat2(torch.nn.Module):
	def __init__(self, lag, weight_dim, init_vals):
		"""
		Instantiate the weight matrix and the bias for single variable model
		"""
		super(fnNetwork_fhat2, self).__init__()
		# Boolean mask
		self.mask = torch.nn.Parameter(torch.tril(torch.ones(weight_dim[0]).triu(), diagonal=lag), requires_grad=False) # Boolean mask, non-trainable
		# Variable 1 - stringency index values
		self.w_1 = torch.nn.Parameter(torch.nn.init.normal_(torch.ones(weight_dim[1]), init_vals[0][0], init_vals[0][1]) * torch.tril(torch.ones(weight_dim[0]).triu(), diagonal=lag), requires_grad=True) # Instantiate with upper triangular weight matrix
		# Variable 2 - average temperature values
		self.w_2 = torch.nn.Parameter(torch.nn.init.normal_(torch.ones(weight_dim[2]), init_vals[1][0], init_vals[1][1]) * torch.tril(torch.ones(weight_dim[0]).triu(), diagonal=lag), requires_grad=True) # Average temperature input
	# Forward step
	def forward(self, input_list):
		# Input 1 -> stringency index
		w1_masked = self.mask * self.w_1
		x1_out = torch.matmul(input_list[0], w1_masked) # input_list[0] is control measure, input_list[1] is average temp
		# Input 2 -> average daily temp
		w2_masked = self.mask * self.w_2
		x2_out = torch.matmul(input_list[1], w2_masked) # input_list[0] is control measure, input_list[1] is average temp
		# Sum network outputs
		out = torch.tensor(1.) + x1_out + x2_out
		return out

# Upper triangular weight model with additive effects and diagonal wise initialisation
# [NOT USED]
class fnNetwork_fhat2_diag(torch.nn.Module):
	def __init__(self, lag, weight_dim, init_vals):
		"""
		Instantiate the weight matrix and the bias for single variable model
		"""
		super(fnNetwork_fhat2_diag, self).__init__()
		# Boolean mask
		self.mask = torch.tril(torch.ones(weight_dim[0]).triu(), diagonal=lag) # Boolean mask, non-trainable
		# Variable 1 = stringency index values, this is a weight vector (not matrix)
		self.w_1 = torch.nn.init.uniform_(torch.ones(weight_dim[1]), init_vals[0][0], init_vals[0][1])
		# Variable 2 = average temperature values
		self.w_2 = torch.nn.init.uniform_(torch.ones(weight_dim[2]), init_vals[1][0], init_vals[1][1])
		# Weight matrices initialise as upper triangular
		self.w_1_mat = torch.nn.Parameter(torch.ones(weight_dim[1], weight_dim[1]).triu(), requires_grad=True)
		self.w_2_mat = torch.nn.Parameter(torch.ones(weight_dim[2], weight_dim[2]).triu(), requires_grad=True)
		# Initialise with same values on each diagonal of upper triangular weight matrix
		for i in range(weight_dim[1]):
			# Fill each diagonal in weight matrix with same values as from element in w_1, and w_2 vectors
			self.w_1_mat.data[0:(i+1), i] = torch.flip(self.w_1[0:(i+1)], dims=[0])
			self.w_2_mat.data[0:(i+1), i] = torch.flip(self.w_2[0:(i+1)], dims=[0]) 
	def forward(self, input_list):
		# Boolean mask 1
		w1_masked = self.mask * self.w_1_mat
		x1_out = torch.matmul(input_list[0], w1_masked)
		# Boolean mask 2
		w2_masked = self.mask * self.w_2_mat
		x2_out = torch.matmul(input_list[1], w2_masked)
		# Sum network outputs
		out = torch.tensor(1.) + x1_out + x2_out
		return out

# Vector models
# Treatment of effects as a single vector
# Inputs become tensor
# Joint model: f = 1 + S x W_S + T x W_T
class fnNetwork_fhat2_vecbeta(torch.nn.Module):
	def __init__(self, lag, weight_dim, init_vals):
		super(fnNetwork_fhat2_vecbeta, self).__init__()
		# Vector mask for lag
		self.mask = torch.zeros((weight_dim[0]))
		self.mask[0:lag, :] = 1.
		# Beta vector for stringency effects
		self.w_1 = torch.nn.Parameter(self.mask * torch.nn.init.normal_(torch.ones(weight_dim[1]), init_vals[0][0], init_vals[0][1]), requires_grad=True)
		# Beta vector for temperature effects
		self.w_2 = torch.nn.Parameter(self.mask * torch.nn.init.normal_(torch.ones(weight_dim[2]), init_vals[1][0], init_vals[1][1]), requires_grad=True)
	def forward(self, input_list):
		# x1 output - stringency effects
		x1_out = torch.matmul(input_list[0], self.mask * self.w_1)
		x1_out.squeeze_(dim=2) # Remove last dimension of 3D tensor, output is (n x t)
		# x2 output - temperature effects
		x2_out = torch.matmul(input_list[1], self.mask * self.w_2)
		x2_out.squeeze_(dim=2) # Remove last dimension of 3D tensor, output is (n x t)
		# Sum outputs
		out = x1_out + x2_out + torch.tensor(1.) 
		return out

# Single effects model
# Inputs are tensors
# Partial models: f = 1 + S x W_S or f = 1 + T x W_T
class fnNetwork_fhat2_vecbeta_single(torch.nn.Module):
	def __init__(self, lag, weight_dim, init_vals):
		super(fnNetwork_fhat2_vecbeta_single, self).__init__()
		# Vector mask for lag
		self.mask = torch.zeros((weight_dim[0]))
		self.mask[0:lag, :] = 1.
		# Beta vector for stringency or temperature effects
		self.w_1 = torch.nn.Parameter(self.mask * torch.nn.init.normal_(torch.ones(weight_dim[1]), init_vals[0][0], init_vals[0][1]), requires_grad=True)
	def forward(self, input_list):
		# x1 output - stringency 
		x1_out = torch.matmul(input_list[0], self.mask * self.w_1)
		x1_out.squeeze_(dim=2) # Remove the last dimension of 3D tensor, output is (n x t)
		# Sum outputs
		out = torch.tensor(1.) + x1_out
		return out

