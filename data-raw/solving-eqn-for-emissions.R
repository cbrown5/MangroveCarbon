#Steps to solve the emission equation. 
# CJ Brown 24 09 2018 

#Need to add degradation. 

#
# Areal loss 
#

byx <- 0.1
d <- 0.5 #def rate (positive value for loss rate)
tsteps <- seq(0, 200, by = byx) #time steps
A1 <- 1000 #initial area 
At = A1 *exp(tsteps * -d) #Area of mangroves
Dt = A1*(1-exp(tsteps*-d)) #Area deforested 

plot(tsteps, At, type = 'l')
lines(tsteps, Dt, type = 'l', lty = 2)

#dD/dt = A1*d*exp(-d*t) #eqn 1
plot(tsteps, A1 * d * exp(-d*tsteps), type = 'l')

#
# Emissions 
#

#Emissions from mangroves deforested at year y at a point in time, t: 
# z[y] = dD/dt
# E[y, t] = z[y] * C * r*exp(-(t-y)*r) - eqn 2
#(t-y) because it is years since harvesting 
# So emission for all mangroves in year t: 
#E[t] = integral_{0-y} z[y] * C * r*exp(-(t-y)*r) - eqn 2
#E[t] = integral_{0-y} A1*d*exp(-d*y) * C * r*exp(-(t-y)*r)

nsteps <- length(tsteps)

C <- 2 #co2/ha
r <- 0.1 # rate of emissions 

#rows are years, columns are ages within a year
E <- matrix(0, nrow = nsteps, ncol = nsteps)
for (t in 1:nsteps){
  z <- A1 * d *byx* exp(-d*tsteps[t])
  for (y in 0:(nsteps-t)){
    E[t,y] <- z *C*r*byx*exp(-tsteps[y]*r)
  }
}

plot(tsteps, rowSums(E), type = 'l')
plot(tsteps, cumsum(rowSums(E)), type = 'l')
max(cumsum(rowSums(E)))
C*A1
#should = C*A1
#something is wrong here with my numerical integration above, need to account for step size? 

#
#integrates too: dE[t]= (A1 * C * d * r * (exp(Y*r) - exp(Y*d))*exp(-r*t - Y*d)) / (r - d)
Eana <- (A1 * C * d * r * (exp(tsteps*r) - exp(tsteps*d))*exp(-r*tsteps - tsteps*d)) / (r - d)
plot(tsteps, cumsum(Eana), type = 'l')
max(cumsum(Eana))*byx # should = approx C*A1

#
# Now set Y = t and integrate over t 
#sum(E[t])=integrate{0-T} (A1 * C * d * r * (exp(t*r) - exp(t*d))*exp(-r*t - t*d)) / (r - d)
#

# A1 * C - ((exp(-T*r) * (A1*C*r*exp(T*r) - A1 * c*d*exp(T*d)))/ (exp(T * d)*r - d*exp(T*d)))
CEana <- A1 * C - ((exp(-tsteps*r) * (A1*C*r*exp(tsteps*r) - A1 * C*d*exp(tsteps*d)))/ (exp(tsteps * d)*r - d*exp(tsteps*d)))

plot(tsteps, CEana, type = 'l') #correct 
lines(tsteps, cumsum(Eana)*byx, lty = 2, col = "red") #correct 
lines(tsteps,cumsum(rowSums(E)), lty = 3, col = 'blue') #overestimating emission rate
abline(h = A1*C)


#
# Compare to old version equation 
#
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

d <- 0.11
g <- 0
CEana1 <- A1 * C - ((exp(-tsteps*r) * (A1*C*r*exp(tsteps*r) - 
                                         A1 * C*d*exp(tsteps*d)))/
                      (exp(tsteps * d)*r - d*exp(tsteps*d)))
CEana2 <- runmod(tsteps, A1, -d, -g, -r, -r, C,C)

plot(tsteps, CEana2,type = 'l')
lines(tsteps, CEana1, col = "red")


#
# Deforestation and degradation TODO 
#


# Areal loss 

#dD/dt = A1*d*exp(-d*t) #eqn 1

# Emissions 

#Emissions from mangroves deforested at year y at a point in time, t: 
# z[y] = dD/dt
# E[y, t] = z[y] * C * r*exp(-(t-y)*r) - eqn 2
#(t-y) because it is years since harvesting 
# So emission for all mangroves in year t: 
#E[t] = integral_{0-y} z[y] * C * r*exp(-(t-y)*r) - eqn 2
#E[t] = integral_{0-y} A1*d*exp(-d*y) * C * r*exp(-(t-y)*r)

#integrates too: dE[t]= (A1 * C * d * r * (exp(Y*r) - exp(Y*d))*exp(-r*t - Y*d)) / (r - d)

# Now set Y = t and integrate over t 
#sum(E[t])=integrate{0-T} (A1 * C * d * r * (exp(t*r) - exp(t*d))*exp(-r*t - t*d)) / (r - d)

# A1 * C - ((exp(-T*r) * (A1*C*r*exp(T*r) - A1 * c*d*exp(T*d)))/ (exp(T * d)*r - d*exp(T*d)))

