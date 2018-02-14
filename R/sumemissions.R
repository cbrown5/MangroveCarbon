#sum emmissions across scenarios
sumemissions <- function(dat){
	sumem <- dat[[1]]
	for (i in 2:length(dat)){
		sumem <- sumem + dat[[i]]}
	return(sumem)
	}