#Create dataframe of emissions with prior emission per ha assumptions.
create_emsamps_prior <- function(ireg, emdat){
	 cperha_def <- emdat$deforested_.tonCO2_ha[ireg]
	 cperha_deg <- emdat$degradation_.tonCO2_ha[ireg]
	x <- list(data.frame(cperha_def = cperha_def, cperha_deg  = cperha_deg))
	return(x)
	}
