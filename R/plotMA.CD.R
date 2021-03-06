# modification on git from copied files
plotMA.CD <- function(cD, samplesA, samplesB, normaliseData = TRUE, scale = NULL, xlab = "A", ylab = "M", ...)
{
  if(length(dim(cD)) > 2) stop("This function is currently only applicable to 2-dimensional countData objects.")
  if(is.character(samplesA)) {
    Asamps <-  which(as.character(cD@replicates) %in% samplesA)
    if(!all(samplesA %in% cD@replicates))
      Asamps <- c(Asamps, which(colnames(cD@data) %in% samplesA[!(samplesA %in% as.character(cD@replicates))]))
    if(!all(samplesA %in% c(colnames(cD@data), as.character(cD@replicates)))) warning("Some members of 'samplesA' were not found!")
    samplesA <- Asamps
  }
  if(length(samplesA) == 0)
    stop("Can't find any data for sample set A!")
  
  if(is.character(samplesB)) {
    Bsamps <-  which(as.character(cD@replicates) %in% samplesB)
    if(!all(samplesB %in% cD@replicates))
      Bsamps <- c(Bsamps, which(colnames(cD@data) %in% samplesB[!(samplesB %in% as.character(cD@replicates))]))
    if(!all(samplesB %in% c(colnames(cD@data), as.character(cD@replicates)))) warning("Some members of 'samplesB' were not found!")
    samplesB <- Bsamps
  }

  if(length(samplesB) == 0)
    stop("Can't find any data for sample set B!")  
  
  if(!inherits(cD, what = "countData"))
      stop("variable 'cD' must be of or descend from class 'countData'")

  Adata <- cD@data[,samplesA]
  Bdata <- cD@data[,samplesB]
  
  if(normaliseData) {
    if("libsizes" %in% names(cD@sampleObservables)) libsizes <- cD@sampleObservables$libsizes else libsizes <- rep(1, ncol(cD))
    
    Adata <- t(t(Adata) / as.vector(libsizes[samplesA]))* mean(libsizes[c(samplesA, samplesB)])
    Bdata <- t(t(Bdata) / as.vector(libsizes[samplesB])) * mean(libsizes[c(samplesA, samplesB)])
  }  


  if("seglens" %in% names(cD@rowObservables)) {
    Adata <- Adata / cD@rowObservables$seglens
    Bdata <- Bdata / cD@rowObservables$seglens
  } else if("seglens" %in% names(cD@cellObservables)) {
    Adata <- Adata / cD@cellObservables$seglens
    Bdata <- Bdata / cD@cellObservables$seglens
  }

  
  Adata <- colSums(t(Adata)) / length(samplesA)
  Bdata <- colSums(t(Bdata)) / length(samplesB)

  Azeros <- which(Adata == 0)
  Bzeros <- which(Bdata == 0)
  nonzeros <- which(Adata != 0 & Bdata != 0)
  infRatio <- ceiling(max(abs((log2(Adata) - log2(Bdata))[nonzeros]), na.rm = TRUE))
  if(!is.null(scale) && scale > infRatio)
    infRatio <- scale

  M <- log2(Adata) - log2(Bdata)
  M[Azeros] <- -infRatio - 2
  M[Bzeros] <- infRatio + 2

  A <- (log2(Adata) + log2(Bdata)) / 2
  A[Azeros] <- log2(Bdata[Azeros])
  A[Bzeros] <- log2(Adata[Bzeros])
  
  plot(y = M, x = A, ylim = c(-infRatio - 3, infRatio + 3), axes = FALSE, xlab = xlab, ylab = ylab, ... )
  axis(side = 1)

  #maxis <- axTicks(side = 2)
  #maxis <- maxis[maxis < infRatio - max(diff(maxis)) & maxis > -infRatio + max(diff(maxis))]
  maxis <- pretty((-infRatio + 1):(infRatio - 1), min.n = 3, n = length(axTicks(side = 2)))
  maxis <- maxis[maxis < infRatio & maxis > -infRatio]
  
  axis(side = 2, at = c(-infRatio - 1, maxis, infRatio + 1), labels = c(-Inf, maxis, Inf))
       
  abline(h = c(-1,1) * (1 + infRatio), col = "orange", lty = 3)

}
