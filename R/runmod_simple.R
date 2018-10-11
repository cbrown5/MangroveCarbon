runmod_simple <- function(t, Ainit, d, g, CPerHadef, CperHAdeg){
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