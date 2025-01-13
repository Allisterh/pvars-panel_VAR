pvars
=====

VAR Modeling for Heterogeneous Panels

## Overview
This package implements (1) panel cointegration rank tests, 
(2) estimators for panels of VAR, and (3) panel-based 
identification methods for structural vector autoregressive 
(SVAR) models. The implemented functions allow to account 
for cross-sectional dependence in the residuals and for 
structural breaks in the deterministic term of the VAR process.

**(1)** The panel functions to determine the cointegration rank are:
-   `pcoint.JO()`: panel Johansen procedures,
-   `pcoint.BR()`: panel test with pooled two-step estimation,
-   `pcoint.SL()`: panel SL-procedures,
-   `pcoint.CAIN()`: correlation-augmented inverse normal test.

**(2)** The panel functions to estimate the VAR models are:
-   `pvarx.VAR()`: mean-group of a panel of VAR models,
-   `pvarx.VEC()`: pooled cointegrating vectors in a panel VECM.

**(3)** The panel functions to retrieve structural impact matrices are:
-   `pid.chol()`: identification of panel SVAR models using Cholesky decomposition to impose recursive causality,
-   `pid.grt()`: identification of panel SVEC models,
-   `pid.iv()`: identification of panel SVAR models by means of proxy variables.
-   `pid.dc()`: independence-based identification of panel SVAR models using distance covariance (DC) statistic,
-   `pid.cvm()`: independence-based identification of panel SVAR models using Cramer-von Mises (CVM) distance.

Supporting tools like the panel block bootstrap procedure (`sboot.pmb()`) 
and the provided data sets allow for the replication of the implemented literature. 


## Installation
Install the development version

```r
install.packages("devtools")
devtools::install_github("Lenni89/pvars")
```

```r
library("pvars")
```


