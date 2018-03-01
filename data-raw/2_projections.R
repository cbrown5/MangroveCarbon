# Run projections used in the publication (Figure 3)
# Uses an age structured carbon stock model.
# CJ Brown 2018-02-14
#

rm(list = ls())
library(devtools)

load_all('~/Code/MangroveCarbon/MangroveCarbon')

data(emdat)
data(emsamps)
data(emsamp_prior)

instant_emissions <- FALSE #Set TRUE to get emissions in year of logging (no time lag in emissions)

#
# Parameters
#
cumredtarg <- 32*17 #cumulative reduction target as total emissions from land-use change. Mega-tonnes of C02
cscale <- 1E6 #mega-tonnes

em_names <-c("emission_product_low", "emission_product_high")
nmaxlim <- length(em_names)
ymax <- 50 #years
nyrs <- ymax
tstep <- 0.01
nsim <- nrow(emsamps[[1]][[1]])
inity <- 2010 #initial year

yrvec <- seq(0, ymax, by = tstep)
#Time points for targets
ipt1 <- which((yrvec + inity) == 2031) #end of 2030
ipt_line <- which((yrvec + inity) == 2030) #put line at 2030 start so as not to confuse people
ipt2 <- which((yrvec + inity) == 2051)
breaks <- cumredtarg * seq(0, 1, length.out = 20)

#
# Run model
#

#Analytical model
dsave <- NULL
cum_em_pred <- data.frame(mean = rep(NA, nmaxlim+1), lwr = rep(NA, nmaxlim + 1),
    upr = rep(NA, nmaxlim + 1))

for (imaxlim in 1:nmaxlim){
 if(instant_emissions){
     emdat$emrate <- 50
}
    datout <- lapply(names(emsamps), runregion, ymax, emsamps, emdat, em_names[imaxlim], tplus = 3, tstep = tstep)
    xdat <- sumemissions(datout)
    xout <- xdat/cscale #rescale to mega-tonnes
    # xcum <- 100*(xout/cumredtarg) #as % of target
    xcum <- xout #raw scale
    EC_mean <- apply(xcum, 1, mean)
    #EC_quants <- apply(xcum, 1, quantile, c(0.25, 0.75))
    EC_quants <- apply(xcum, 1, quantile, c(0.025, 0.975))
    datEC <- list(datout = datout, EC_mean = EC_mean, EC_quants = EC_quants)
    cum_em_pred$mean[imaxlim] <- EC_mean[ipt1]
    cum_em_pred$lwr[imaxlim] <- EC_quants[1, ipt1]
    cum_em_pred$upr[imaxlim] <- EC_quants[2, ipt1]

    dsave <- c(dsave, list(datEC))
    cat("Max emission limit = ", em_names[imaxlim], "\n")
    print(EC_mean[ipt1])
    print(EC_mean[ipt1]/cumredtarg)
    quantile(xcum[ipt1,], 0.1)

    #Histogram of uncertainty at first time target
    #xy <- hist(xcum[ipt1,], breaks = breaks)
    #plot(breaks[2:length(breaks)], cumsum(xy$count)/sum(xy$counts),
        #type = 'l', xlab = "Emissions", ylab = "Cumulative prob")

    rm(list = c("xcum", "datEC", "xdat", "xout", "EC_mean","EC_quants"))
}

#
# Model using a priori emissions assumption
#
datout <- lapply(names(emsamps), runregion, ymax, emsamp_prior, emdat, 1.0, tplus = 3, tstep = tstep)
xdat <- sumemissions(datout)
xout <- xdat/cscale #rescale to mega-tonnes
# xcum <- 100*(xout/cumredtarg) #as % of target
xcum_prior <- xout #raw scale
print(xout[ipt1]/cumredtarg)

cum_em_pred$mean[3] <- xout[ipt1]

cum_em_pred

#
# Plot
#
atx <- seq(0, ymax, by = 10)
xlab <- atx +inity
ylimscum <- c(0, cumredtarg/4)
emcols <- c("salmon", "steelblue")
emcol_reported <- "darkred"

#
# Plot
#

dev.new()
par(las = 1, mar = c(5,5,4,2))
plot(yrvec, rep(0, length(yrvec)), type = 'n',ylim = ylimscum,
 xlab = 'Years', ylab = expression(paste('Cumulative emissions (Tg ', CO^2,' eq)')), xaxt = 'n',
 bty = 'n')

abline(v = yrvec[ipt_line], lwd = 2, lty = 2, col = 'grey80')
axis(1, col = 'black', col.ticks = 'black',  at = atx, labels = xlab)

lines(yrvec, xcum_prior, col = emcol_reported, lwd = 2)

# for (imaxlim in 1:nmaxlim){
for (imaxlim in 2){
    #Line for every year
    # for (i in 1:nsim){
        # lines(yrvec, xcum[,i], col = grey(0.5, 0.3))
    # }
    lines(yrvec, dsave[[imaxlim]]$EC_mean, col = emcols[imaxlim], lwd = 2)
     # lines(yrvec+tstep, EC_mean_s, col = 'grey', lwd = 2)

    addpoly(yrvec, dsave[[imaxlim]]$EC_quants[1,],
        y = dsave[[imaxlim]]$EC_quants[2,], border = NA,
        col = hexalpha(emcols[imaxlim], 0.1))
}
text(20, 128.82, "First deadline of the Paris Agreement", srt = 270, pos= 4,
  col = "grey30")
 legend("topleft",
  legend = c("Projected \n emissions",
  "Reported \n emissions"),
    lty = 1, col = c(emcols[2], emcol_reported), lwd = 2, bty = 'n', y.intersp = 1.5)
     # legend = c("Upper bound \n emissions", "Lower bound \n emissions",
     # "Reported \n emissions"),
     lty = 1, col = c(rev(emcols), emcol_reported), lwd = 2, bty = 'n', y.intersp = 1.5)

dev.copy2pdf(file = 'Code/MangroveCarbon/MangroveCarbon/data-raw/figures/cumulative_emissions-Mar18.pdf')


#
# Regional emissions
#

names(emsamps)
namesvec <- c("Pacific North", "Pacific Central", "Pacific South", "Gulf of Mexico", "Yucatan")
nregion <- length(datout)
cols <- RColorBrewer::brewer.pal(5, 'Dark2')
cols[5] <- "blue4"
lineslwd <- c(2,5,2,2,2)
ylimscum <- c(0, 60)

dev.new()
par(las = 1, mar = c(5,5,4,2))
plot(yrvec, yrvec, type = 'n',ylim = ylimscum,
 xlab = 'Years', ylab = expression(paste('Cumulative emissions (Tg ', CO^2,' eq)')), xaxt = 'n',
 bty = 'n')

axis(1, col.ticks = 'black',  at = atx, labels = xlab)

imaxlim <- 2
for (i in 1:nregion){
    xdat <- dsave[[imaxlim]]$datout[[i]]
	xcum <- xdat/cscale

	EC_mean <- apply(xcum, 1, mean)
	EC_quants <- apply(xcum, 1, quantile, c(0.025, 0.975))

	print(names(datout)[i])
 	print(EC_mean[ipt1])
 	lines(yrvec, EC_mean, col = cols[i], lwd = lineslwd[i])

	# addpoly(yrvec, EC_quants[1,], y= EC_quants[2,], border = NA, col = hexalpha(cols[i],0.5))

	}
legend(x = 0, y = 60, legend = namesvec, lwd = 2, lty = 1, col = cols)

dev.copy2pdf(file =  'Code/MangroveCarbon/MangroveCarbon/data-raw/figures/regional_emissions-v2.pdf')
