#run all parameter scenarios for one region
runregion <- function(region,yrmax, emsamp, emdat2,em_name, tinit = 3, tplus = 3, tstep = 1, model = 'analytical'){

	iregion <- which(emdat2$region == region)
	if (is.numeric(em_name)){
		em_limit <- em_name
		} else {
		em_limit <- emdat2[iregion,em_name]
	}

	iruns <- data.frame(
		d = emdat2$defrate[iregion],
		g = emdat2$degrate[iregion],
		Ainit = emdat2$area_ha[iregion] * exp(tplus * emdat2$defrate[iregion]),
		CPerHadef = emsamp[[region]][[1]]$cperha_def * em_limit,
		CPerHadeg =  emsamp[[region]][[1]]$cperha_deg * em_limit
	)
	emrate <- emdat2$emrate[emdat2$region == region]

	#
	# Run model
	#
	tsteps <- seq(0, yrmax, by = tstep)
	if (model == 'analytical'){
		xout <- vrunmod(tsteps, A0 = iruns$Ainit, d = iruns$d, g = iruns$g, rd=-emrate,
			rg = -emrate, Cd = iruns$CPerHadef, Cg = iruns$CPerHadeg)
	} else if (model == 'simple') {
		print("Make sure your degradation and deforestation rates are annual rates!")
		xout <- vrunmod_simple(tsteps, Ainit = iruns$Ainit, d = -iruns$d, g = -iruns$g, ed=-emrate,
			eg = -emrate, CPerHadef = iruns$CPerHadef, CperHAdeg = iruns$CPerHadeg)

	}

	return(xout)

	}
