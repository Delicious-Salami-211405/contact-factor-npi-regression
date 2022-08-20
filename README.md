# Contact Factor Regression Overview

This repository includes code for the project titled "The effect of non-pharmaceutical interventions on COVID-19 contact factors". This study was conducted on 30 countries and code is written in both R and Python

## Abstract

**Introduction:** The early phase of the COVID-19 pandemic in 2020 represented a unique time period over which non-pharmaceutical interventions (NPIs) were introduced to contain the global outbreak of novel airborne communicable disease spreading across a previously unexposed global population. This study aimed to look at the associations between the contact factor, NPIs and temperature using functional data analysis and regression models to account for lagged effects.

**Methods:** A sample 30 countries from the European Union (EU) plus Norway, Switzerland and the United Kingdom was chosen for the study. Functional data analysis was used to smooth COVID-19 incidence and interpolate missing values. This smoothed incidence was subsequently used to estimate the effective reproductive number (Re) for each country and as a corollary a time varying contact factor. The estimated time varying contact factor was regressed against NPIs and temperature. Permutation tests on the regression models were run to test for association and a plot was produced for all covariates’ effects with respect to lag.

**Results:** Permutation tests for NPIs suggest strong evidence for rejection of the null hypothesis of no association. Conversely, there was no evidence to reject the null for the temperature covariate. These results were robust to changes in the assumed incubation period used to calculate Re from smoothed incidence.

**Discussion:** NPIs displayed a negative association with the estimated contact factor, conversely increasing temperature for the chosen study period displayed no association with the estimated contact factor. These results are broadly consistent with other studies looking at the effects of NPIs and temperature. The framework used in this study could be applied to study the effects of specific NPIs given higher resolution and continuous data proxies for individual NPI policies.

## Code Context & Usage

**Data Acquisition:** All dated collection and cleaning was done in R

**Functional Data Analysis:** Functional data smoothing and representation, plus numerical integration done in R

**Temporal Models:** All temporal models, cross-validation and permutation tests done in Python