# Historical estimation of emissions from all regions
# Uses an age structured carbon stock model.
# CJ Brown 2018-02-14
#

rm(list = ls())
library(devtools)

load_all('~/MangroveCarbon')

data(datscnrs)
data(emsamps)
data(emdat)

#
# Parameters
#

ymax <- 38 #years
tpery <- 10 #integration step per year
dt <- 1/tpery
tmax <- ymax * tpery
t <- 2:tmax
y <- t/tpery
nsim <- ncol(datscnrs[[1]][[1]])

n <- 30 #number of annual age classes
N <- n * tpery #total number of age classes
inity <- 1978 #initial year


#
# Run model for all regions
#
emdat$emrate <- 1
vrunregion <- Vectorize(runregion, vectorize.args = 'region', SIMPLIFY = FALSE)
datout <- vrunregion(as.character(emdat$region), datscnrs, emsamps, emdat, tperiod = 1, tinit = 1)


#
# Plot
#

xdat <- sumemissions(datout)

scale <- 1000000
xout <- xdat/scale

years <- rep(1:ymax, each = tpery)[1:(tmax-1)]
yrs <- 1:ymax
xsum <- apply(xout,2, function(x) tapply(x, years, sum))


#
# Annual emissions
#

E_mean <- apply(xsum, 1, mean)
E_quants <- apply(xsum, 1, quantile, c(0.25, 0.75))

ylims <- c(min(xsum), max(xsum))
atx <- seq(0, ymax, by = 10)
xlab <- atx +inity

dev.new(width = 10, height = 5)

par(las = 1, mfrow = c(1,2))
plot(yrs, xsum[,1], type = 'n', ylim = ylims,
 xlab = 'Years', ylab = 'Emissions (millions tons C per yr)', xaxt = 'n',
 bty = 'n')

axis(1, col = 'white', col.ticks = 'black',  at = atx, labels = xlab)


for (i in 1:nsim){
	lines(yrs, xsum[,i], col = grey(0.5, 0.3))
	}

lines(yrs, E_mean, col = 'purple2', lwd = 2)

addpoly(yrs, E_quants[1,], y= E_quants[2,], border = NA, col = hexalpha('purple2',0.1))

#
# Cumulative emissions
#
xcum <- apply(xout, 2, cumsum)
EC_mean <- apply(xcum, 1, mean)
EC_quants <- apply(xcum, 1, quantile, c(0.25, 0.75))
ylimscum <- c(min(xcum), max(xcum))

par(las = 1)
plot(y, xcum[,1], type = 'n',ylim = ylimscum,
 xlab = 'Years', ylab = ' Cumulative emissions (millions tons C)', xaxt = 'n',
 bty = 'n')

axis(1, col = 'white', col.ticks = 'black',  at = atx, labels = xlab)

for (i in 1:nsim){
	lines(y, xcum[,i], col = grey(0.5, 0.3))
	}

lines(y, EC_mean, col = 'salmon', lwd = 2)

addpoly(y, EC_quants[1,], y= EC_quants[2,], border = NA, col = hexalpha('salmon',0.1))
