# Estimate carbon emissions from mangrove deforestation

 CJ Brown 2018-02-14

 This is supplementary material prepared in support of the publication:

[Adame, Brown, Bejarano, Herrera-Silveira, Ezcurra, Kauffman, Birdsey. In Press. The undervalued contribution of mangrove protection in Mexico to carbon emission targets. Conservation Letters. DOI: 10.1111/conl.12445](http://onlinelibrary.wiley.com/doi/10.1111/conl.12445/full)

Please cite that publication if you use this code.

An interactive web app that runs these models is available on the [Shiny Server](https://seascapemodels.shinyapps.io/inst/).

Please contact chris.brown@griffith.edu.au or pull a request on this github project if you have any queries.

## Using this package

To use package, open R and type:
`install.packages("devtools")`
Then to access the package's functions and data:
`devtools::install_github("cbrown5/MangroveCarbon")`

## Important files

The raw data and scripts used to generate the projections in the paper are available under the /data-raw folder:
`1_prep_data.R` will recreate the internal dataframes.
`2_projections.R` runs projections and creates figure 3 of the paper.
`3_historic.R` estimates historic emissions from observed deforestation.

Code for the shiny application is under /inst.

A bibtex file for citing this work is in file CITATION.

License: [MIT](https://opensource.org/licenses/MIT) + file [LICENSE](/LICENSE)
