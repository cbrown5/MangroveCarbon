# Prep data for analysis and create internal data files
# CJ Brown 2018-02-14

rm(list = ls())
library(devtools)
library(dplyr)
load_all('~/MangroveCarbon')

#
# Load data
#

emdat <- read.csv('~/MangroveCarbon/data-raw/emission_dat_12May2017.csv', header = T)
fdat <- read.csv('~/MangroveCarbon/data-raw/dat_forest_loss.csv', header = T)
defrates <- read.csv('~/MangroveCarbon/data-raw/defrates.csv', header = T)

datscnrs <- vcalc_lossrate(fdat, levels(fdat$region), nrep)
nrep <- 1000

#
# Create data for forest  and forest loss rates
#

fdat2 <- filter(fdat, year == 2010) %>%
    select(region, area_ha)

emdat <- left_join(emdat, fdat2)

defrates2 <- defrates %>% transmute(defrate = log(1 -defrate_2005_2010*0.01),
    degrate = log(1 -degrate_2005_2011 *0.01), region = region)
#Model doesn't do carbon sequestration, so make mangrove gain = 0 (ie emissions will also = 0)
defrates2$defrate[defrates2$defrate > 0 ] <- 0

emdat <- left_join(emdat, defrates2)

#
# Create data for emission rate
#

emdat$emrate <- c(0.1, 0.1, 0.3, 0.3, 0.1)

#
#Create data for carbon per ha
#

vsampleem <- Vectorize(sampleem, vectorize.args = 'ireg', SIMPLIFY = F)
emsamps <- vsampleem(1:nrow(emdat), emdat, nrep, seed = 42)
names(emsamps) <- emdat$region

#
# Create data for carbon per ha under prior assumption
#

#Prior is 15.5 * 3.67 (lower is 10 * 3.67, upper is 22 * 3.67)
emdat_prior <- emdat
emdat_prior$deforested_.tonCO2_ha <- 15.5 * 3.67
emdat_prior$degradation_.tonCO2_ha <- 0
#This just restructures the data (doesn't add any error) to match data structure required later on in sims.
vcreate_emsamps_prior <- Vectorize(create_emsamps_prior, vectorize.args = 'ireg', SIMPLIFY = F)
emsamp_prior <- vcreate_emsamps_prior(1:nrow(emdat_prior), emdat_prior)
names(emsamp_prior) <- emdat_prior$region


#
# Save data
#

devtools::use_data(emsamps, pkg = '~/MangroveCarbon', overwrite = T)
devtools::use_data(emdat, pkg = '~/MangroveCarbon', overwrite = T)
devtools::use_data(emsamp_prior, pkg = '~/MangroveCarbon', overwrite = T)
