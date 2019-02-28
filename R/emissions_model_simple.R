#' Simulate cumulative emissions 
#'
#' @Usage emissions_model_simple(t, Ainit, d, g, CPerHadef, CperHAdeg)
#'
#' @param t \code{vector} vector of time steps for integration
#' @param Ainit \code{numeric} Initial area of forest
#' @param d \code{numeric} Instantaneous deforestation rate
#' @param g \code{numeric} Instantaneous degradation rate
#' @param CPerHadef \code{numeric} Carbon emission potential for deforestation
#' @param CperHAdeg \code{numeric} Carbon emission potential for degradation  
#'
#' @return A \code{vector} of cumulative carbon emissions.  
#'
#' @details Numerical integration of carbon emissions. Includes 
#' degradation and deforestation. Assumes all carbon is emitted as 
#' soon as deforestation or degradation occur. 
#' There is no deforestation of degraded forest. 
#' Primarily used to check against analytical equations. 
#' 
#'
#' @author Christopher J. Brown
#' @examples
#' years <- seq(0, 50, by = 0.1)
#' emissions <- emissions_model_simple(years, 100, 0.05, 0.1, 776, 200)
#' plot(years, emissions)
#' @rdname emissions_model_simple
#' @export
emissions_model_simple <- function(t, Ainit, d, g, CPerHadef, CperHAdeg){
	#
	# Preallocation
	#
	
	dt <- diff(t)[1]
	tmax <- length(t)
	A <- rep(NA, tmax)
	A[1] <- Ainit
	D <- rep(0, tmax)
	G <- rep(0, tmax)
	E <- rep(0, tmax)
	
	#apportioning loss between deforestation and degradation
	relrate <- min(c(d,g))/max(c(d,g))
	relrateg <- abs((d>g)-relrate)
	relrated <- abs((g>d)-relrate)
	for (t in 2:tmax){
	
		#Deforestation and Degradation of forests
		A[t] <- A[t-1] - (A[t-1] * dt*(d + g - d*g))
	
		#Model carbon emissions from deforested areas
		D[t] <- A[t-1]*dt*(d - d*g*relrated) * CPerHadef 
	
		#Model degradation
		G[t] <- A[t-1]*dt*(g - d*g*relrateg) * CperHAdeg 	
	
		# Emissions
		E[t] <- sum((D[t] + G[t]))
	
	}
	cumE <- pmax(cumsum(E), 0)
	
	return(cumE)
}