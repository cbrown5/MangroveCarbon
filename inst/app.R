# Shiny attempt
library(shiny)
library(plotly)

#TODO: 
# Add loading bar

ui <- fluidPage(

  titlePanel("Estimate carbon dioxide emissions from mangrove deforestation"),

  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Input: Slider for the number of bins ----
      sliderInput(inputId = "d",
                  label = "Deforestation rate (per year)",
                  min = 0,
                  max = 0.5,
                  value = 0.005)
    ,
    numericInput(inputId = "A0",
                    label = "Area of mangroves (hectares)",
                    value = 1000)
    ,
    selectInput(inputId = "Region",
                label = "Region",
                selected = c("Arid", "Reported"),
                choices = c("Arid", "Warm humid",
                            "Warm sub-humid", "Reported"),
                multiple = TRUE)
      ,
    selectInput(inputId = "units",
                label = "Units",
                choices = c("Megatonnes", "Tonnes", "Cars per annum"),
                multiple = FALSE)
    ,
    sliderInput(inputId = "yrmax",
                label = "Years",
                min = 1,
                max = 200,
                value = 50)
    ,
    sliderInput(inputId = "rd",
                label = "Emission rate (per year)",
                min = 0.01,
                max = 1,
                value = 0.1)
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Plot",
                 fluidRow(
                   p(""),
                   p("Use the sliders and inputs on the left to explore how carbon emissions 
                     change under different deforestation rates.") ,
                   p("The lines show our model's projections for cumulative carbon emissions in Mexico's different climate regions.
                     Our projections include carbon stored in soil, which is lost to the atmosphere when mangroves are removed. 
                      The orange line labelled 'Reported' shows the emissions projected assuming carbon is only
                      stored in trees. When Mexico (and other mangrove nations) calculated their targets for 
                     emissions for the Paris Climate Agreement they only accounted for carbon stored in trees."), 
                    p("The graph may take a moment to load.")),
                 fluidRow(
                   plotlyOutput("plot1")),
                 fluidRow(
                   p("A few details. All rates are instantaneous values. You can plot the emissions in different
                     units, including in terms of annual car emissions. 'Cars per annum' is an average annual emission rate from cars in the USA. "))
        ),
        tabPanel("About",
                 fluidRow(
                   h3("Welcome to the carbon emissions from mangrove deforestation web app "),
                   p("Mangrove forests store carbon and help to mitigate global warming. Some of this carbon in
                     stored in trees and dead wood, but much more is trapped in the soils on which mangroves grow."),
                   p("Many assessments, such as that used by Mexico to set their targets for the Paris Climate
                     Agreement, ignore much of the carbon stored in the soils underneath mangrove forests.
                     Thus they drastically underestimate the value of protecting mangrove forests for mitigating greenhouse
                     gas emissions."),
                   p("This web app is designed to help you explore the contribution of mangrove protection to
                     mitigating emissions. It supports the publication:"),
                   a("Adame et al. The undervalued contribution of mangrove protection in Mexico to carbon emission targets. Conservation Letters. In Press", href="http://onlinelibrary.wiley.com/doi/10.1111/conl.12445/full"),
                   p(),
                   p("All the numbers and calculations used by this web app are supported by that peer-reviewed publication
                     See that publication for further details of the data and models underlying this app."),
                   a("Click here if you want to see the code underneath the hood of this model.", 
                      href = "http://www.seascapemodels.org/MangroveCarbon/"), 
                   p("The web app was designed by Drs Chris Brown and Fernanda Adame using the R program, RShiny and plotly. ") 
                   ),
                 fluidRow(p("Contact Chris Brown (chris.brown@griffith.edu.au) if you have any queries about the web app"))
                   ),
        tabPanel("Model Description",
                 fluidRow(
                   p("The data used here come from surveys of carbon in soils, trees and dead-wood in Mexicos mangrove forests."),
                   p("The surveys covered Mexico's three major climate regions."),
                   p("The model estimates annual emissions based on the carbon estimates for each region and a rate of forest loss. 
                     Forest loss occurs at a constant rate. Carbon dioxide may take some time to be released once a mangrove forest
                      is cleared. The 'Emission rate' slider controls this rate of emissions once an area of forest is lost. 
                      Evidence suggests that emissions are lost at a rate of about 10% per year (the default value used here). "),
                   p("Full details of the data and model are available in this open-access publication: "), 
                   a("Adame et al. The undervalued contribution of mangrove protection in Mexico to carbon emission targets. Conservation Letters. In Press", 
                        href="http://onlinelibrary.wiley.com/doi/10.1111/conl.12445/full")
                   )
                   )
      )
    )
  )
)

server <- function(input, output) {
  calcdef <- function(tsteps, A1, C, d, r){
    A1 * C - ((exp(-tsteps*r) * (A1*C*r*exp(tsteps*r) - A1 * C*d*exp(tsteps*d)))/ 
                (exp(tsteps * d)*r - d*exp(tsteps*d)))
  }
    output$plot1 <- renderPlotly({
      if(input$units == "Megatonnes") denom <- 1E6
      if(input$units == "Cars per annum") denom <- 4.7
      if(input$units == "Tonnes") denom <- 1

      cdat <- data.frame(Region = c("Arid", "Warm sub-humid",
                                    "Warm humid",
                                     "Reported"),
        Cd = c(c(264.6, 540.5, 520.7)*3.67*0.8,56.885), stringsAsFactors = FALSE)
      irow <- which(cdat$Region %in% input$Region)
      nchoices <- length(irow)
      Cd <- cdat[irow,"Cd"]
      years <- 0:input$yrmax
      carbon <- NULL

      for (i in 1:nchoices){
        carbon <- c(carbon,
                    list(
                      calcdef(years, input$A0, Cd[i], input$d, input$rd)/denom
                      ))
      }
      emcols <- c("#7570b3","#e7298a", "#66a61e",'#d95f02')
      p <- plot_ly(x = years, y = carbon[[1]], mode = "lines", name = cdat$Region[irow[1]],
                   line = list(color=emcols[irow[1]], width = 4)) %>%
        layout(title = "Emissions from mangrove deforestation",
               xaxis = list(title = "Years"),
               yaxis = list(title =paste0('Cumulative emissions (',input$units,')')))
      for (i in 1:nchoices){
        if (nchoices >1){
        p <- add_trace(p, y = carbon[[i]], name = cdat$Region[irow[i]],mode = 'lines',
                    line = list(color=emcols[irow[i]], width = 4))}
      }
      p

    })
}

shinyApp(ui = ui, server = server)
