# ---- roxygen documentation ----
#
#' @title Get Gaussian Filter for raster object
#'
#' @description
#'  This function is a helper function for SSIM functions.
#'
#' @details
#'  The \code{ssim} function can be used to generate the global multiscale ssim.
#'
#' @param sigma is the standard deviation for the filter
#' @param w is the width of the neighbourhood in number of pixels out from centre cell
#'
#'
#' @return
#'   \code{ssim} returns a filter object for use in \code{focal} function in the \code{raster} package
#'
#' @seealso spatialcompare
#' @export
#
# ---- End of roxygen documentation ----

getGauss <- function(sigma, w) {
  w2 = (w*2) + 1
  gf1 <- matrix(nrow=w2, ncol=w2)
  gf2 <- matrix(nrow=w2, ncol=w2)
  for(i in 1:w2) {
    gf1[i,] <-  c(w:0, 1:w)
    gf2[,i] <-  c(w:0, 1:w)
  }
  gf <- (1 / (2 * pi * (sigma^2))) * exp(-(gf1^2 + gf2^2) / (2 * (sigma^2)))
  return(gf/sum(gf))
}



# ---- roxygen documentation ----
#
#' @title Structural similarity index
#'
#' @description
#'  This function implements the structural similarity index of Wang et al. (2003) formulated
#'  for comparison of \code{raster} spatial objects.
#'
#' @details
#'  The \code{ssim} function can be used to generate the three component indices of the SSIM index
#'  as well as the composite index. Two raster objects are the key arguments which will be used to compare.
#'  These two raster objects must have the same \code{CRS}, extent, and cell size.
#'
#' @param img1 is a \code{raster} object to compare
#' @param img2 is a \code{raster} object to compare
#' @param w is the width of the neighbourhood in number of pixels out from centre cell
#' @param gFIL is a binary flag for whether a Gaussian filter should be applied as a smoothing function
#' @param edge is a binary flag for whether a torroidal edge correction should be applied
#' @param ks is a vector of length 2 which contains values for constants in the SSIM formula. If ignored default values will be used.
#'
#'
#' @return
#'   \code{ssim} returns a list with 5 objects. The first is the value of the global ssim statistic. Objects 2-5 are all \code{raster} objects
#'   that contain the composite index, luminance, contrast, and structure components respectively.
#'
#' @keywords hello spatialcompare
#' @seealso spatialcompare
#' @export
#
# ---- End of roxygen documentation ----

ssim <- function(img1, img2, w, gFIL=TRUE, edge=FALSE, ks=c(0.01, 0.03)) {
  if(class(img1) != "RasterLayer") img1 <- raster::raster(img1)
  if(class(img2) != "RasterLayer") img2 <- raster::raster(img2)
  #set constants
  N <- FALSE
  #library(raster)

  L <- max(raster::cellStats(img1, max), raster::cellStats(img2, max))
  globalMin <- abs(min(raster::cellStats(img1, min), raster::cellStats(img2, min)))
  L <- L - globalMin
  K <- ks
  C1 <- (K[1]*L)^2
  C2 <- (K[2]*L)^2
  C3 <- C2/2

  sigma = 1.5
  #create null filter, optionally replace with weighted version
  filterx = matrix(1, nrow=(w*2)+1, ncol=(w*2)+1) / sum(matrix(1, nrow=(w*2)+1, ncol=(w*2)+1))
  #get the Gaussian Kernel
  if(gFIL == TRUE) {
    filterx = getGauss(sigma, w)
  }
  #get mu
  mu1 <- raster::focal(img1, filterx, fun=sum, na.rm=N)
  mu2 <- raster::focal(img2, filterx, fun=sum, na.rm=N)
  img12 <- img1 * img2
  #square
  mu1mu2 <- mu1 * mu2
  mu1sq <- mu1 * mu1
  mu2sq <- mu2 * mu2
  #normalized sigma sq
  sigsq1<- raster::focal(img1*img1,filterx,fun=sum, na.rm=N) - mu1sq
  sigsq2<- raster::focal(img2*img2,filterx,fun=sum, na.rm=N) - mu2sq
  sig12 <- raster::focal(img1*img2,filterx,fun=sum, na.rm=N) - mu1mu2
  #std dev
  sig1 <- sigsq1 ^ 0.5
  sig2 <- sigsq2 ^ 0.5
  #compute components
  L <- ((2*mu1mu2)+C1) / (mu1sq + mu2sq + C1)
  C <- (2*sig1*sig2+C2) / (sigsq1 + sigsq2 + C2)
  S <- (sig12 + C3) / (sig1 * sig2 + C3)
  #compute SSIMap
  SSIM2 <- L * C * S
  #compute SSIM
  num <- (2*mu1mu2+C1)*(2*sig12+C2)
  denom <- (mu1sq+mu2sq+C1) * (sigsq1+sigsq2+C2)
  #global mean
  mSSIM <- raster::cellStats((num / denom), mean)
  return(list(mSSIM, SSIM2, L, C, S))
}




# ---- roxygen documentation ----
#
#' @title Multiscale structural similarity index
#'
#' @description
#'  This function implements the multiscale structural similarity index of Wang et al. (2003) formulated
#'  for comparison of \code{raster} spatial objects at multiple scales.
#'
#' @details
#'  The \code{msssim} function can be used to generate the global multiscale ssim. Local values are not supported. The weights used in the default are those given in Wang et al. (2003) and were determined empirically for a five-level application. The weights determine how cross-scale values of the SSIM are weighted.
#'
#' @param img1 is a \code{raster} object to compare
#' @param img2 is a \code{raster} object to compare
#' @param w is the width of the neighbourhood in number of pixels out from centre cell
#' @param gFIL is a binary flag for whether a Gaussian filter should be applied as a smoothing function
#' @param edge is a binary flag for whether a torroidal edge correction should be applied
#' @param ks is a vector of length 2 which contains values for constants in the SSIM formula. If ignored default values will be used.
#' @param level is the number of scales to evaulate statistic at, default is 5
#' @param weight is the weights for scales in \code{level}, and should be a vector of length \code{level}. Defaults are optimal values determined empirically in Wang et al. (2003)
#' @param method is the method for combining SSIM components, currently the only option
#'
#'
#' @return
#'   \code{msssim} returns a vector with the value of the multiscale structural similarity index
#'
#' @keywords multi-scale spatialcompare
#' @seealso ssim
#' @export
#
# ---- End of roxygen documentation ----

msssim <- function(img1, img2, w, gFIL=TRUE, edge=FALSE, ks=c(0.01, 0.03), level=5, weight=c(0.0448, 0.2856, 0.3001, 0.2363, 0.1333), method='product') {
  if(class(img1) != "RasterLayer") img1 <- raster::raster(img1)
  if(class(img2) != "RasterLayer") img2 <- raster::raster(img2)
  im1 <- img1
  im2 <- img2
  N <- FALSE
  sssimArray <- list()
  sssimArray[[1]] <- ssim(im1, im2, w, gFIL, edge, ks)
  for(i in 2:level) {
    sigma <- 3.37
    filterx=getGauss(sigma, i)
    im1f <- raster::focal(im1, filterx, fun=sum, na.rm=N) #low pass filter
    im2f <- raster::focal(im2, filterx, fun=sum, na.rm=N)
    im1f <- raster::aggregate(im1f, fact=2) #downsample
    im2f <- raster::aggregate(im2f, fact=2)
    #compute c and s
    sssimArray[[i]] <- ssim(im1f, im2f, w, gFIL, edge, ks)
  }
  if(method =='product') {
    x <- unlist(sssimArray)
    l <- 3 #index of luminance of 1st level
    cs <- seq(4,level*5, by=5) #indices of contrast at all levels
    ss <- seq(5,level*5, by=5) #indices of structure at all levels
    contrasts <- unlist(lapply(unlist(x)[cs], raster::cellStats, mean)) #mean values of contrast component at all levels
    structures <- unlist(lapply(unlist(x)[ss], raster::cellStats, mean)) #mean values of structure component at all levels
  }
  msssimO <- raster::cellStats(x[[3]], mean)^1 *  prod(contrasts^weight, structures^weight)
  return(msssimO)
}