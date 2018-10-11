# Example for using the model
#Just runs a simple example (no bootstrapping like in manuscript)
# CJ Brown 2018-03-30

rm(list = ls())
library(devtools)
library(dplyr)
load_all('..')
data(emdat)

dtemp <- seq(emdat$defrate[2]/10, emdat$defrate[2]*100, length.out = 100)
diffsave <- rep(NA, length(dtemp))
i <- 10
 for (i in 1:length(dtemp)){
   Ctotal <- 1 #tons C02 / ha
  
  
   d1 <- dtemp[i]
   # d1 <- emdat$defrate[1]
  d2 <- emdat$defrate[2]
  Ainit <- 1
  emrate <- -10000
  tsteps <- seq(0, 100, by = 0.1)
  
em1 <- runmod(tsteps, A0 = Ainit, d = d1, g = 0, rd=emrate,
                       rg = 0, Cd = Ctotal, Cg = 0)
em1_num <- runmod_simple(tsteps, Ainit, d = -d1, g = 0, 
                          CPerHadef = Ctotal, CperHAdeg = 0)

em2 <- runmod(tsteps, A0 = Ainit, d = d2, g = 0, rd=emrate,
              rg = 0, Cd = Ctotal, Cg = 0)

modtest <- function(t, A0, d, rd, Cd, Cg){
  (A0 * Cd * (exp(d) - 1) * 
               (-rd * exp(d*t) + (d)*exp(rd*t) + rd - d))/
    ((d) * (rd - d))
 
 }

em3 <- modtest(tsteps, A0 = Ainit, d = d1, rd=emrate,
              Cd = Ctotal, Cg = 0)

plot(tsteps, em1, type = 'l', ylim = c(0, Ctotal * Ainit))
# lines(tsteps, em2, col = "red")
lines(tsteps, em1_num, lty = 2, col = "green")
abline(h = Ctotal * Ainit)
lines(tsteps, em3, col = "blue", lty = 3)
lines(tsteps, em3, col = "yellow", lty = 2)

diffsave[i] <- em1_num[length(tsteps)] - em1[length(tsteps)]


 }

plot(dtemp, diffsave)
m1 <- lm(diffsave ~ dtemp)
abline(m1)


#
# Model 
#
#seems to be an error in that analytical model underestimates maximum emissions, 
# and the error increases with the deforestation rate. Need to redo model to
# find if there is a problem? 
#Also model gives NA if emrate = deforestation rate
#The error at equilibrium depends only on the deforestation rate
#So need to add a constant? 

 #Emissions from deforested mangroves, Dt: 
  # E,t = integral over a { Da,t * C * r * exp(-a*r)} da
#integrates to : C * Dt * r * ((1/r) - (exp(-a*r)/r)) if over bounds (0 - A)
 d <- 0.1
 t <- seq(0, 100, by = 0.1)
 A1 <- 1
At = A1 * exp(t * -d)
Dt = A1*(1-exp(t*-d))

plot(t, At, type = 'l')
lines(t, Dt, type = 'l', lty = 2)
  
Dt/dt = A1*d*exp(d*t)

  