runmod <- function(t, A0, d, g, rd, rg, Cd, Cg){
	
	deftot <- (A0 * Cd * (exp(d) - 1) * 
	(-rd * exp(g*t + d*t) + (g+d)*exp(rd*t) + rd - g - d))/
	((g+d) * (rd - g - d))
	
	degtot <- (A0 * Cg * (exp(g) - 1) * 
	(-rg * exp(g*t + d*t) + (g+d)*exp(rg*t) + rg - g - d))/
	((g+d) * (rg - g - d))
	
	outnum <- pmax(degtot + deftot, 0)
	outnum[is.nan(outnum)] <-0 
	return(outnum)
}