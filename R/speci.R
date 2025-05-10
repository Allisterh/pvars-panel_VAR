

#' @title Criteria on the number of common factors
#' @description Determines the number of factors in an approximate factor model
#'   for a data panel, where both dimensions \eqn{(T \times KN)} are large, 
#'   and calculates the factor time series and corresponding list of \eqn{N} idiosyncratic components.
#'   See Corona et al. (2017) for an overview and further details.
#' @param L.data List of \eqn{N} \code{data.frame} objects each collecting the \eqn{K_i} time series along the rows \eqn{t=1,\ldots,T}.
#'   The \eqn{\sum_{i=1}^{N} K_i} time series are immediately combined into the \eqn{T \times KN} data panel \code{X}.
#' @param k_max Integer. The maximum number of factors to consider.
#' @param n.iterations Integer. Number of iterations for the Onatski criterion.
#' @param differenced Logical. If \code{TRUE}, each time series of the panel \code{X} is first-differenced prior to any further transformation.
#'   Thereby, all criteria are calculated as outlined by Corona et al. (2017).
#' @param centered Logical. If \code{TRUE}, each time series of the panel \code{X} is centered.
#' @param scaled Logical. If \code{TRUE}, each time series of the panel \code{X} is scaled.
#'   Thereby, the PCA is applied via the correlation matrix instead of the covariance matrix of \code{X}.
#' @param n.factors Integer. A presumed number of factors under which the idiosyncratic component \code{L.idio} is calculated. 
#'   Deactivated if NULL (the default).
#' 
#' @return A list of class '\code{speci}', which contains the elements:
#' \item{eigenvals}{Data frame. The eigenvalues of the PCA, which have been used to calculate the criteria, 
#'      and their respective share on the total variance in the data panel.}
#' \item{Ahn}{Matrix. The eigenvalue ratio  \eqn{ER(k)} and growth rate \eqn{GR(k)} 
#'      by Ahn, Horenstein (2013) for \eqn{k=0,\ldots,}\code{k_max} factors.}
#' \item{Onatski}{Matrix. The calibrated threshold \eqn{\delta} and suggested number of factors \eqn{\hat{r}(\delta)} 
#'      by Onatski (2010) for each iteration.}
#' \item{Bai}{Array. The values of the criteria \eqn{PC(k)}, \eqn{IC(k)}, and \eqn{IPC(k)}
#'      with penalty weights \eqn{p1}, \eqn{p2}, and \eqn{p3} for \eqn{k=0,\ldots,}\code{k_max} factors.}
#' \item{selection}{List of the optimal number of common factors:
#'      (1) A matrix of \eqn{k^*} which minimizes each information criterion with each penalty weight. 
#'      (2) A vector of \eqn{k^*} which maximizes \code{ER} and \code{GR} respectively. 
#'      \code{ED} denotes the result by Onatski's (2010) "edge distribution" after convergence.}
#' \item{Ft}{Matrix. The common factors of dimension \eqn{(T \times} \code{n.factors}) estimated by PCA.}
#' \item{LAMBDA}{Matrix. The loadings of dimension \eqn{(KN \times} \code{n.factors}) estimated by OLS.}
#' \item{L.idio}{List of \eqn{N} \code{data.frame} objects each collecting the \eqn{K_i} idiosyncratic series \eqn{\hat{e}_{it}} along the rows \eqn{t=1,\ldots,T}. 
#'       The series \eqn{\hat{e}_{it}} are given in levels and may contain a deterministic component with 
#'       (1) the initial \eqn{\hat{e}_{i1}} being non-zero and (2) re-accumulated means of the the first-differenced series.}
#' \item{args_speci}{List of characters and integers indicating the specifications that have been used.}
#' 
#' @details If \code{differenced} is \code{TRUE}, the approximate factor model is estimated as proposed by Bai, Ng (2004).
#'   If all data transformations are selected, the estimation results are identical 
#'   to the objects in \code{$CSD} for PANIC analyses in '\code{pcoint}' objects.
#' 
#' @references Ahn, S., and Horenstein, A. (2013): 
#'   "Eigenvalue Ratio Test for the Number of Factors", 
#'   \emph{Econometrica}, 81, pp. 1203-1227.
#' @references Bai, J. (2004): 
#'   "Estimating Cross-Section Common Stochastic Trends in Nonstationary Panel Data", 
#'   \emph{Journal of Econometrics}, 122, pp. 137-183.
#' @references Bai, J., and Ng, S. (2002): 
#'   "Determining the Number of Factors in Approximate Factor Models", 
#'   \emph{Econometrica}, 70, pp. 191-221.
#' @references Bai, J., and Ng, S. (2004): 
#'   "A PANIC Attack on Unit Roots and Cointegration", 
#'   \emph{Econometrica}, 72, pp. 1127-117.
#' @references Corona, F., Poncela, P., and Ruiz, E. (2017): 
#'   "Determining the Number of Factors after Stationary Univariate Transformations", 
#'   \emph{Empirical Economics}, 53, pp. 351-372.
#' @references Onatski, A. (2010): 
#'   "Determining the Number of Factors from Empirical Distribution of Eigenvalues", 
#'   \emph{Review of Econometrics and Statistics}, 92, pp. 1004-1016.
#' @examples
#' ### reproduce Arsova,Oersal 2017:67, Ch.5 ###
#' data("MERM")
#' names_k = colnames(MERM)[-(1:2)] # variable names
#' names_i = levels(MERM$id_i)      # country names
#' L.data  = sapply(names_i, FUN=function(i) 
#'    ts(MERM[MERM$id_i==i, names_k], start=c(1995, 1), frequency=12), 
#'    simplify=FALSE)
#' 
#' R.fac1 = speci.factors(L.data, k_max=20, n.iterations=4)
#' R.fac0 = speci.factors(L.data, k_max=20, n.iterations=4, 
#'    differenced=TRUE, centered=TRUE, scaled=TRUE, n.factors=8)
#'    
#' # scree plot #
#' library("ggplot2")
#' pal = c("#999999", RColorBrewer::brewer.pal(n=8, name="Spectral"))
#' lvl = levels(R.fac0$eigenvals$scree)
#' F.scree = ggplot(R.fac0$eigenvals[1:20, ]) +
#'   geom_col(aes(x=n, y=share, fill=scree), color="black", width=0.75) +
#'   scale_fill_manual(values=pal, breaks=lvl, guide=FALSE) +
#'   labs(x="Component number", y="Share on total variance", title=NULL) +
#'   theme_bw()
#' plot(F.scree)
#' 
#' @family specification functions
#' @export
#' 
speci.factors <- function(L.data, k_max=20, n.iterations=4, differenced=FALSE, centered=FALSE, scaled=FALSE, n.factors=NULL){
  # define
  L.dim_K = sapply(L.data, FUN=function(x) ncol(x))
  L.dim_T = sapply(L.data, FUN=function(x) nrow(x))
  dim_NK = sum(L.dim_K)
  dim_T = min(L.dim_T)
  dim_N = length(L.data)
  idx_d = if(differenced){ 1:2 }else{ 1:3 }
  
  # data matrix of dimension (T_min x sum(K_i))
  X = do.call("cbind", lapply(L.data, FUN=function(x) tail(x, n=dim_T))) # first dim in tail() is T
  
  # data transformation and PCA
  if(differenced){ xit = diff(X) }else{ xit = X }
  xit = scale(xit, center=centered, scale=FALSE)
  xsd = scale(xit, center=FALSE, scale=scaled)
  R.svd = svd(xsd)
  evals = R.svd$d^2 / (dim_T-differenced)  # eigenvalues of the covariance matrix (X'X)/T
  
  # number of principal components
  dim_C2 = length(evals)  # min(dim(X))
  if(k_max > dim_C2){
    warning("k_max supasses the minimum dimension of the data matrix. 'k_max = 0.1*min(dim(X)' has been used instead")
    k_max = round(0.1*dim_C2)
  }
  
  # Onatski (2010) and Ahn,Horenstein (2013)
  R.ahc = aux_AHC(eigenvals=evals, r_max=k_max)
  R.onc = aux_ONC(eigenvals=evals, r_max=k_max, n.iterations=n.iterations)
  
  # Bai,Ng (2002) and Bai (2004)
  V = (sum(evals) - cumsum(c(0, evals[1:k_max]))) / dim_NK  # variances for k=0,...,k_max, from Corona et al. 2017:356, Eq.7
  R.bai = sapply(0:k_max, function(k) aux_PIC(X, k=k, Vk0=V[k+1], Vkmax0=V[k_max+1])[ ,idx_d], simplify="array")
  R.min = apply(R.bai, MARGIN=1:2, FUN=function(k) which.min(k)) - 1  # account for k=0
  
  # approximate factor model, see Bai,Ng 2002:198
  if(length(n.factors) > 0){
    evecs = R.svd$u[ , 0:n.factors , drop=FALSE]  # eigenvectors
    
    # estimate
    ft = sqrt(dim_T-differenced) * evecs  # common factors as (T-1 x n.factors) matrix
    LAMBDA = t(xit)%*%ft / (dim_T-differenced)  # loadings as (K*N x n.factors) matrix
    if(differenced){
      Ft = apply(rbind(0, ft),  MARGIN=2, FUN=function(x) cumsum(x)) # cumulate first-differences into levels, see Bai,Ng (2004)
    }else{ Ft = ft }
    et = X - Ft%*%t(LAMBDA)  # idiosyncratic components as (T x K*N) matrix
    
    # panel of idiosyncratic components in list-format
    idx_K  = cumsum(c(0, L.dim_K))
    L.idio = lapply(1:dim_N, FUN=function(i) et[ , idx_K[i] + 1:L.dim_K[i]])
    scree  = as.factor(c(1:n.factors, rep(0, dim_C2-n.factors)))
  }else{
    Ft     = NULL
    LAMBDA = NULL
    L.idio = NULL
    scree  = NA
  }
  
  # return result
  R.eval = data.frame(n = 1:dim_C2, 
                      scree = scree, 
                      value = evals, 
                      share = evals / sum(evals))  # share of explained variation
  select = list(R.min, c(R.ahc$selection, ED=R.onc$selection))
  argues = list(specifies="number of common factors", n.factors=n.factors, k_max=k_max,
                differenced=differenced, centered=centered, scaled=scaled)
  result = list(eigenvals=R.eval, Ahn=R.ahc$criteria, Onatski=R.onc$converge, Bai=R.bai,
                selection=select, Ft=Ft, LAMBDA=LAMBDA, L.idio=L.idio, args_speci=argues)
  class(result) = "speci"
  return(result)
}


#### S3 methods for objects of class 'speci' ####
#' @export
print.speci <- function(x, ...){
  # create table
  header_args = c("### Optimal ", x$args_speci$specifies, " ###")
  
  # print
  cat(header_args, "\n", sep="")
  print(x$selection, quote=FALSE, row.names=FALSE)
}


