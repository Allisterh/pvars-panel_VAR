

#### Generic functions and their S3 methods ####
# CRAN manual: https://cran.r-project.org/doc/manuals/R-exts.html#Generic-functions-and-methods
# Roxygen: https://r-pkgs.org/man.html#man-s3

#' @title Coerce into a '\code{pplot}' object 
#' @description Coerce into a '\code{pplot}' object. This function allows (1) to
#'   overlay and colorize multiple plots of IRF and confidence bands in a single 
#'   '\code{ggplot}' object and (2) to overwrite shock and variable names in
#'   verbatim LaTeX math mode suitable for the export via \strong{tikzDevice}. 
#' @details '\code{as.pplot()}' is used as an intermediary in the '\code{pplot}' 
#'   functions to achieve compatibility with different classes. Equivalently to 
#'   '\code{as.pvarx}' for panels of \eqn{N} VAR objects, '\code{as.pplot()}' 
#'   summarizes panels of \eqn{G} plot objects that have been returned 
#'   from the '\code{plot}' method for class '\code{svarirf}' or '\code{sboot}'. 
#'   If the user wishes to extend the compatibility of the '\code{pplot}' 
#'   functions with further classes, she may simply specify accordant 
#'   '\code{as.pplot()}' methods instead of altering the original 
#'   '\code{pplot}' functions.
#'   
#' @param ... A single ggplot or list(s) of ggplots to be transformed.  
#' @param names_k Vector. Names of the variables \eqn{k=1,\ldots,K}. 
#'   If \code{NULL} (the default), the names of the first plot are reused. 
#'   For LaTeX exports, use e.g. \code{paste0("y_{ ", 1:dim_K, " }")}.
#' @param names_s Vector. Names of the shocks \eqn{s=1,\ldots,S}. If \code{NULL} 
#'   (the default), the names of the first plot are reused. 
#'   For LaTeX exports, use e.g. \code{paste0("\\\epsilon_{ ", 1:dim_S, " }")}.
#' @param names_g Vector. Names of the layered plots \eqn{g=1,\ldots,G}. If \code{NULL} 
#'   (the default), the names of the plots given in \code{...} are reused. 
#' @param color_g Vector. Colors of the layered plots \eqn{g=1,\ldots,G}. 
#' @param shape_g Vector. Shapes of the layered plots \eqn{g=1,\ldots,G}, 
#'   see \link[ggplot2]{geom_point} for shapes. 
#'   If \code{NULL} (the default), no points will be set on the IRF-lines.  
#' @param n.rows Integer. Number of rows in \link[ggplot2]{facet_wrap}. If \code{NULL} 
#'   (the default), the dimensions of the facet plots given in \code{...} are reused.
#' @param scales Character. Should scales be fixed (\code{"fixed"}), 
#'  free (\code{"free"}), or free in one dimension (\code{"free_x"}, 
#'  \code{"free_y"}, the default)? See \link[ggplot2]{facet_wrap}.
#' @param Latex Logical. If \code{TRUE}, the arrows of the facet labels are 
#'   written in LaTeX math mode.
#' 
#' @return A list of class '\code{pplot}'. Objects of this class contain the elements:
#'   \item{F.plot}{'\code{ggplot}' object for the merged plot.}
#'   \item{L.plot}{List of '\code{ggplot}' objects containing all \eqn{G} plots.}
#'   \item{args_pplot}{List of characters and integers indicating the
#'                     specifications used for creating \code{F.plot}.}
#' @seealso \link{PP}, \link{irf.pvarx}, \link{pid.dc}, and \link{id.iv}
#'   for further examples of edited plots, in particular for subset and reordered 
#'   facet plots with reshaped facet dimensions.
#' @example inst/examples/pplot.R
#' @export
#' 
as.pplot <- function(..., names_k=NULL, names_s=NULL, names_g=NULL, 
  color_g=NULL, shape_g=NULL, n.rows=NULL, scales="free_y", Latex=FALSE) UseMethod("as.pplot")


#' @method as.pplot default
#' @importFrom scales hue_pal
#' @export
as.pplot.default <- function(..., names_k=NULL, names_s=NULL, names_g=NULL, 
  color_g=NULL, shape_g=NULL, n.rows=NULL, scales="free_y", Latex=FALSE){
  # defaults if overwritten as NULL
  if( is.null(scales) ){ scales = "free_y" }
  if( is.null(Latex)  ){ Latex  = FALSE }
  
  # try to homogenize all listed elements to ggplot object
  aux_ggunlist <- function(x){
    L.out = list()
    for(j in 1:length(x)){
      if(inherits(x[[j]], "ggplot")){
        L.out = c(L.out, x[j])
      }else if(inherits(x[[j]], "pplot")){
        L.out = c(L.out, x[[j]]$L.plot)
      }else if(is.list(x[[j]])){
        L.out = c(L.out, aux_ggunlist(x[[j]]))
      }else{
        stop("Arguments are not objects of suitable class!")
      }
    }
    return(L.out)
  }
  
  x      = list(...)
  L.plot = aux_ggunlist(x)
  dim_G  = length(L.plot)  # number of plotted groups
  
  if( !all(sapply(L.plot, FUN=function(x) inherits(x, "ggplot"))) ){
     stop("Arguments are not objects of suitable class!") }
  
  # names for variables, for shocks, and for the header of each IRF
  if( is.null(names_k) | is.null(names_s) ){
    # get names from first ggplot object
    R.grob = ggplot2::ggplotGrob(L.plot[[1]])
    idx_ks = which(grepl("strip-t", R.grob$layout$name))
    R.labs = sapply(1:length(idx_ks), FUN=function(x) as.character(R.grob$grobs
       [idx_ks][[x]]$grobs[[1]]$children[[2]]$children[[1]]$label))
    if( is.list(R.labs) ){ R.labs  = do.call("cbind", R.labs) }  # in case of 'selection' of IRF sub-plots
    
    ### default dimensions: https://stackoverflow.com/questions/60104268/default-panel-layout-of-ggplot2facet-wrap
    n.labs = ncol(R.labs)  # number of facet labels
    n.cols = if(n.labs > 3){ ceiling(sqrt(n.labs)) }else{ n.labs } # number of columns in facet plot
    n.void = n.cols^2 - n.labs  # number of void facet sub-plots
    idx_ks = c(sapply((n.cols-1):0, FUN=function(x) x*n.cols + 1:n.cols)) - n.void
    idx_ks = idx_ks[idx_ks > 0]  # index to reorder in left-right top-down
    if( is.null(names_k) ){ names_k = unique(R.labs[3, idx_ks]) }
    if( is.null(names_s) ){ names_s = unique(R.labs[2, idx_ks]) }
  }
  
  if(Latex){ 
    names_IRF = c(sapply(names_k, FUN=function(k) paste0("$ ", names_s, " \\rightarrow ", k, " $")))
    names(names_IRF) = 1:length(names_IRF)
    label_IRF = as_labeller(names_IRF, default=label_value)
  }else{ 
    names_IRF = c(sapply(names_k, FUN=function(k) paste0(names_s, " %->% ", k)))
    names(names_IRF) = 1:length(names_IRF)
    label_IRF = as_labeller(names_IRF, default=label_parsed)
  }
  
  # names for groups, their colors, and shapes
  if( is.null(names_g) ){ names_g = names(L.plot) }else{ names(L.plot) = names_g }
  if( dim_G != length(unique(names_g)) ){
    stop("The layered plots do not have unique names. Please provide ", dim_G, 
          " unique names via the attribute 'names_g' or label all input plots.") 
  }
  n.shps = dim_G-length(shape_g)
  n.clrs = dim_G-length(color_g)
  R.shps = c(shape_g, if(n.shps > 0) rep(0:6, length.out=n.shps))
  R.clrs = c(color_g, if(n.clrs > 0) scales::hue_pal()(n=n.clrs))  # ggplot default colors
  R.rgb  = grDevices::col2rgb(R.clrs)/3 + 170  # 'darkgray' = 'black'/3 + 169 
  R.fill = grDevices::rgb(R.rgb[1, ], R.rgb[2, ], R.rgb[3, ], maxColorValue=255)
  names(names_g) = names_g
  names(R.shps)  = names_g
  names(R.clrs)  = names_g
  names(R.fill)  = names_g
  names_g = factor(names_g, levels=names_g)  # ordering of names_g and of layers must be identical 
  
  # gather data from plots in data.frame
  L.data = lapply(L.plot, FUN=function(x_g) ggplot2::ggplot_build(x_g)$data)
  L.irf  = L.cbs = list()
  for(g in 1:dim_G){
    n.layers = length(L.data[[g]])
    if(n.layers==2){
      # from plot.svarirf() for IRF or PP
      L.irf[[g]] = L.data[[g]][[1]]
      L.cbs[[g]] = NULL
      L.irf[[g]]$colour = names_g[g]  # slot name in British English!
    }else{
      # from plot.sboot() for IRF with confidence bands
      L.irf[[g]] = L.data[[g]][[2]]
      L.cbs[[g]] = L.data[[g]][[1]]
      L.irf[[g]]$colour = names_g[g]  # slot name in British English!
      L.cbs[[g]]$fill   = names_g[g]
    }
  }
  df_irf = do.call("rbind", L.irf)
  df_cbs = do.call("rbind", L.cbs)
  
  # "PANEL" is not an allowed name for faceting variables
  names(df_irf)[names(df_irf) == "PANEL"] = "variable"
  if(!is.null(df_cbs)){ 
    names(df_cbs)[names(df_cbs) == "PANEL"] = "variable"
  }
  
  # stfu R CMD check vs. ggplot2 (common practice, aes_ is deprecated)
  y = ymin = ymax = fill = alpha = group = colour = NULL
  
  # plot IRF with optional confidence bands
  F.plot = ggplot() +
    ## geoms ##
    {if(!is.null(df_cbs)) 
      geom_ribbon(data = df_cbs, aes(x=x, ymin=ymin, ymax=ymax, fill=fill, 
                  alpha=alpha, group=interaction(group, fill)))} +
    geom_line(data = df_irf, aes(x=x, y=y, color=colour)) +
    {if(!is.null(shape_g)) 
      geom_point(data = df_irf, aes(x=x, y=y, color=colour, shape=colour))} +
    geom_hline(yintercept=0, color="red") + 
    facet_wrap(~variable, nrow=n.rows, scales=scales, labeller=label_IRF) + 
    #### TODO: facet_wrap(~factor(variable, levels=unique(variable)), nrow=n.rows, scales=scales, labeller=label_IRF) + 
    ## scales ##
    {if(!is.null(df_cbs)) 
      scale_fill_manual( labels=names(names_g), values=R.fill)} + 
    scale_color_manual(  labels=names(names_g), values=R.clrs)  +
    {if(!is.null(shape_g)) 
      scale_shape_manual(labels=names(names_g), values=R.shps)} +
    ## layout ##
    guides(alpha="none") +
    labs(x="Horizon", y="Response", color="Group", shape="Group", fill="Group") +
    theme_bw()
  
  # return result
  if( is.null(shape_g) ){ R.shps = NULL }
  args_pplot = list(names_k=names_k, names_s=names_s, names_g=names_g, 
    color_g=R.clrs, shape_g=R.shps, n.rows=n.rows, scales=scales, Latex=Latex)
  result = list(F.plot=F.plot, L.plot=L.plot, args_pplot=args_pplot)
  class(result) = "pplot"
  return(result)
}


#' @method as.pplot pplot
#' @export
as.pplot.pplot <- function(..., names_k=NULL, names_s=NULL, names_g=NULL, 
  color_g=NULL, shape_g=NULL, n.rows=NULL, scales=NULL, Latex=NULL){
  # gather arguments
  x = list(...)[[1]]
  args_pplot = list(names_k=names_k, names_s=names_s, names_g=names_g, 
       color_g=color_g, shape_g=shape_g, n.rows=n.rows, scales=scales, Latex=Latex)
  is_NULL = c(is.null(names_k), is.null(names_s), is.null(names_g), 
       is.null(color_g), is.null(shape_g), is.null(n.rows), is.null(scales), is.null(Latex))
  is_same = sapply(1:length(args_pplot), FUN=function(j) identical(args_pplot[j], x$args_pplot[j]))
  
  # compare arguments and return
  if( all(is_NULL | is_same) ){
    return(x)
    
  }else{
    # overwrite with given arguments
    if( is.null(names_k) ){ names_k = x$args_pplot$names_k }
    if( is.null(names_s) ){ names_s = x$args_pplot$names_s }
    if( is.null(names_g) ){ names_g = x$args_pplot$names_g }
    if( is.null(color_g) ){ color_g = x$args_pplot$color_g }
    if( is.null(shape_g) ){ shape_g = x$args_pplot$shape_g }
    if( is.null(n.rows)  ){ n.rows  = x$args_pplot$n.rows  }
    if( is.null(scales)  ){ scales  = x$args_pplot$scales  }
    if( is.null(Latex)   ){ Latex   = x$args_pplot$Latex   }
    
    return(as.pplot.default(..., names_k=names_k, names_s=names_s, names_g=names_g, 
      color_g=color_g, shape_g=shape_g, n.rows=n.rows, scales=scales, Latex=Latex))
  }
}



#### S3 methods for objects of class 'pplot' ####

#' @method plot pplot
#' @export
#' 
plot.pplot <- function(x, ...){ plot(x$F.plot) }


#' @method print pplot
#' @export
#' 
print.pplot <- function(x, ...){ print(x$F.plot) }


