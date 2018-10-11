# Run projections for Baja
# Uses an age structured carbon stock model.
# CJ Brown 2018-09-21
#

rm(list = ls())
library(devtools)
library(dplyr)
library(tidyr)
library(ggplot2)

load_all('..')
dat <- read.csv("data-forests-sep2019.csv")
n <- nrow(dat)

denom <- 1000000
tsteps <- seq(0, 102, by = 0.1)

datsave <- NULL
for (i in 1:n){
  datout <- data.frame(tsteps = tsteps, max = NA, min = NA, forest = dat$X[i])
  #Changed carbon content to 407.1 tonC/ha on 7th Aug 2018 in response to reviews
  emrate <- 0.1 
  Ctotal <- dat$c02ha[i]

  Ainit <-  dat$Area[i]
  d1 <- dat$max[i]/100
  d2 <- dat$min[i]/100
  
  datout$max <- runmod(tsteps, A0 = Ainit, d = -d1, g = 0, rd=-emrate,
                   rg = 0, Cd = Ctotal, Cg = 0)/denom
                 #runmod_simple(tsteps, Ainit, d1, 0, Ctotal, 0) /denom
  datout$min <- runmod(tsteps, A0 = Ainit, d = -d2, g = 0, rd=-emrate,
                  rg = 0, Cd = Ctotal, Cg = 0)/denom
  datsave <- c(datsave, list(datout))
}

dat2 <- do.call("rbind", datsave) %>% 
  gather(bounds, CO2_em, - tsteps, - forest)
  

(dat$Area * dat$c02ha)/denom

gp1 <- ggplot(dat2, aes(x = tsteps+2018, y = CO2_em, color = bounds)) + 
  geom_line() + 
  facet_grid(.~forest) + 
  xlab("Year") + 
  ylab("C02 emissions (millions tons)") +
  theme_bw()
gp1

ggsave("forest-emission.pdf",
       gp1,
       width = 9, height = 5, dpi = 600)



