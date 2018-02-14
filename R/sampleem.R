#sample C per HA values from normal distribution
sampleem <- function(ireg, emdat, nsim, seed = 402){
	set.seed(seed)
	#Errors are CVs so use this equation:
	 cperha_def <- rnorm(nsim, emdat$deforested_.tonCO2_ha[ireg], sd = (emdat$error_deforested_percent[ireg]/100)*emdat$deforested_.tonCO2_ha[ireg])
	 cperha_deg <- rnorm(nsim, emdat$degradation_.tonCO2_ha[ireg], sd = (emdat$error_degradation_percent[ireg]/100)*emdat$degradation_.tonCO2_ha[ireg])

	x <- list(data.frame(cperha_def = cperha_def, cperha_deg  = cperha_deg))
	return(x)
	}
