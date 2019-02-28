#' Simulate cumulative emissions 
#'
#' @Usage emissions_model(tsteps, A1, d, r, C)
#'
#' @param tsteps \code{vector} vector of time steps for integration
#' @param A1 \code{numeric} Initial area of forest
#' @param d \code{numeric} Instantaneous deforestation rate
#' @param r \code{numeric} Instantaneous emission rate
#' @param C \code{numeric} Carbon stock 
#'
#' @return A \code{vector} of cumulative carbon emissions.  
#'
#' @details Uses the function for deforestation in Adame et al. 2018. 
#' See that paper for more details
#' 
#'
#' @author Christopher J. Brown
#' @examples
#' years <- seq(0, 50, by = 0.1)
#' emissions <- emissions_model(years, 100, 0.05, 0.1, 776)
#' plot(years, emissions)
#' @rdname emissions_model
#' @export
emissions_model <- function(tsteps, A1, d, r, C){
  if (d == r) d <- d+(d/10000)
  outnum <- A1 * C - ((exp(-tsteps*r) * (A1*C*r*exp(tsteps*r) - 
                                 A1 * C*d*exp(tsteps*d)))/
              (exp(tsteps * d)*r - d*exp(tsteps*d)))
	outnum[is.nan(outnum)] <-0 
	return(outnum)
}