# Estimate carbon emissions from mangrove deforestation

2019-02-26
Data compiled by: Fernanda Adame
Code by: CJ Brown

This is supplementary material prepared in support of the publication:

[Adame, Brown, Bejarano, Herrera-Silveira, Ezcurra, Kauffman, Birdsey. In Press. The undervalued contribution of mangrove protection in Mexico to carbon emission targets. Conservation Letters. DOI: 10.1111/conl.12445](http://onlinelibrary.wiley.com/doi/10.1111/conl.12445/full)

Please cite that publication if you use this code.

An interactive web app that runs these models is available from the [Global Wetlands Program](https://wetlands.app/mangrove-carbon-simulator/).

Please contact chris.brown@griffith.edu.au or pull a request on this github project if you have any queries.

## Using this package

To use package, open R and type:
`install.packages("devtools")`
Then to access the package's functions and data:
`devtools::install_github("cbrown5/MangroveCarbon")`

## Important files

The main functions are `emissions_model()` and `emissions_model_simple()`. See the help files for those functions for examples.

Data for the above paper are under `data(emdat)`

Code for the shiny application is under /inst.

A bibtex file for citing this work is in file CITATION.

License: [MIT](https://opensource.org/licenses/MIT) + file [LICENSE](/LICENSE)
