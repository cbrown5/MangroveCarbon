# Run projections for Baja
# Uses an age structured carbon stock model.
# CJ Brown 2018-08-07
#

rm(list = ls())
library(devtools)

load_all('..')
#Changed carbon content to 407.1 tonC/ha on 7th Aug 2018 in response to reviews
nsamps <- 1000
emrate <- 0.1 
conv_fact <- 3.67 #conversion factor for C to CO2
#Ctotal <- 265 * 0.8 *conv_fact
Ctotal <- 338  * 0.8 *conv_fact
Ctotal_SE <- 34 *conv_fact
#Cdeg <- 265 * 0.2  *conv_fact
Cdeg <- 338  * 0.2  *conv_fact
Cdeg_SE <- 34 * 0.2 *conv_fact
CPerHadef <- rnorm(nsamps, mean = Ctotal, sd = Ctotal_SE)
CPerHadeg <- rnorm(nsamps, mean = Cdeg, sd = Cdeg_SE)
# Ainit <- 28884
Ainit <-  16057.5 #updated 8 8 2018
d <- c(-0.1/100, -0.2/100, -0.3/100)
g <- c(-0.1/100)

tsteps <- seq(0, 102, by = 0.1)
xout1 <- vrunmod(tsteps, A0 = Ainit, d = d[1], g = g, rd=-emrate,
        rg = -emrate, Cd = CPerHadef, Cg = CPerHadeg)
xout2 <- vrunmod(tsteps, A0 = Ainit, d = d[2], g = g, rd=-emrate,
                rg = -emrate, Cd = CPerHadef, Cg = CPerHadeg)
xout3 <- vrunmod(tsteps, A0 = Ainit, d = d[3], g = g, rd=-emrate,
                rg = -emrate, Cd = CPerHadef, Cg = CPerHadeg)

# plot(runmod(0:100, Ainit, d = -0.1, g = -0.00001, 
#        rd = -0.1, rg = -0.1, Cd = Ctotal, Cg = Ctotal)/(Ainit*Ctotal),
# runmod_simple(0:100, Ainit, d = 0.1, g = 0.00001, 
#         Ctotal, Ctotal)/(Ainit*Ctotal),
#   xlab = "ana", ylab = "numer")
# plot(runmod_simple(seq(0, 100, by = 0.1), Ainit, d = -d[3], g = -g, 
#                        Ctotal, Cdeg), ylab = "x")
# lines(runmod(seq(0, 100, by = 0.1), A0 = Ainit, d = d[3], g = g,
#              rd=-1,
#              rg = -1, Cd = Ctotal, Cg = Cdeg), col ="red")

denom <- 1000000
dat <- data.frame(mn1 = rowMeans(xout1)/denom, 
                  q751=apply(xout1, 1,quantile,0.75)/denom, 
                  q251=apply(xout1, 1,quantile,0.25)/denom,
                  mn2 = rowMeans(xout2)/denom, 
                  q752=apply(xout2, 1,quantile,0.75)/denom, 
                  q252=apply(xout2, 1,quantile,0.25)/denom,
                  mn3 = rowMeans(xout3)/denom, 
                  q753=apply(xout3, 1,quantile,0.75)/denom, 
                  q253=apply(xout3, 1,quantile,0.25)/denom)

yrsteps <- tsteps+2018
ppi <- 300
width <- 8
height <- 6
# 
# png("//staff.ad.griffith.edu.au/ud/fr/s2973410/Documents/documents/Collaborative projects/blue-c-baja/emission-plot-v2.png", 
    # width = width*ppi, height = height*ppi, pointsize = 50)
pdf("//staff.ad.griffith.edu.au/ud/fr/s2973410/Documents/documents/Collaborative projects/blue-c-baja/emission-plot-v2.pdf", 
     width = width, height = height)
par(mar = c(6, 5, 4, 2))

plot(yrsteps, dat$mn1, type = 'l', lwd = 2, col = "orange",
     ylim = c(0, max(dat$q753)), xlab = "Year", 
     ylab =  expression(paste('Cumulative emissions (millions Mg ', CO^2,' eq)')))
polygon(c(yrsteps, rev(yrsteps)), c(dat$q751, rev(dat$q251)), 
        col = hexalpha("orange", 0.5), border = NA)

lines(yrsteps, dat$mn2, col = "tomato", lwd = 2)
polygon(c(yrsteps, rev(yrsteps)), c(dat$q752, rev(dat$q252)), 
        col = hexalpha("tomato", 0.5), border = NA)

lines(yrsteps, dat$mn3, col = "darkred", lwd = 2)
polygon(c(yrsteps, rev(yrsteps)), c(dat$q753, rev(dat$q253)), 
        col = hexalpha("darkred", 0.5), border = NA)

legend("topleft", legend = c("0.1%", "0.2%", "0.3%"), 
       title = "Deforestation rate", bty = 'n', lty = 1,
        col = c("orange", "tomato", "darkred"), lwd = 2, cex = 0.9)


dev.off()


mean(runmod(50, A0 = Ainit, d = d[2], g = g, rd=-emrate,
       rg = -emrate, Cd = CPerHadef, Cg = CPerHadeg))

mean(runmod(100, A0 = Ainit, d = d[2], g = g, rd=-emrate,
            rg = -emrate, Cd = CPerHadef, Cg = CPerHadeg))

#runmod_simple(seq(0, 50, by = 0.01), Ainit, d = -d[2], g = -g, 
 #                                    Ctotal, Cdeg)
