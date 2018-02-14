# Shiny attempt
library(shiny)
library(plotly)

#TODO: Need to check values out of model are signs correct? 
# Add CITATION file
# Add loading bar

ui <- fluidPage(

  titlePanel("Estimation of carbon dioxide emissions from Mangrove deforestation"),

  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Input: Slider for the number of bins ----
      sliderInput(inputId = "d",
                  label = "Deforestation rate (per year)",
                  min = -0.5,
                  max = 0,
                  value = -0.005)
    ,
    numericInput(inputId = "A0",
                    label = "Area of mangroves (hectares)",
                    value = 1000)
    ,
    selectInput(inputId = "Region",
                label = "Region",
                selected = c("Arid, high tidal amplitude", "Reported"),
                choices = c("Arid, high tidal amplitude", "Warm sub-humid, high tidal amplitude", "Warm humid, low tidal amplitude",
                            "Warm sub-humid, low tidal amplitude", "Reported"),
                multiple = TRUE)
      ,
    selectInput(inputId = "units",
                label = "Units",
                choices = c("Megatonnes", "Tonnes", "Cars"),
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
        tabPanel("Description",
          fluidRow(
            p("Welcome to the carbon emissions from mangrove deforestation web app. "),
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
            See that publication for further details of the data and models underling this app."),
            p("If you want to know the techincal nitty-gritty, I will post a link to the R program package 
              underlying these models soon."), 
            p("Click the plot tab above to get started. ")
          ),
          fluidRow(p("Contact Chris Brown (chris.brown@griffith.edu.au) if you have any queries about the web app"))
        ), 
        tabPanel("Plot",
                 fluidRow(
                   p(""),
                   p("Use the sliders and inputs on the left to explore how carbon emissions change under different deforestation rates.
              All rates are instantaneous.") ,
                   p("The lines show our model's projections for carbon emissions in Mexico's different climate regions. 
                     The orange line labelled 'Reported' shows the emissions projected assuming carbon is only
                      stored in trees. This reflects the numbers Mexico used in the Paris Climate Agreement. 
                     .")),
                 fluidRow(
                   plotlyOutput("plot1")),
                 fluidRow(
                   p("A few details. All rates are instantaneous values. You can plot the emissions in different
                     units, including in terms of cars. 'Cars' is an average annual emission rate from cars in the USA. ")) 
        )
      )
    )
  )
)

server <- function(input, output) {
  calcdef <- function(t, A0, Cd, d, rd){
    (A0 * Cd * (exp(d) - 1) *
       (-rd * exp(d*t) + d*exp(rd*t) + rd - d))/
      (d * (rd - d))
  }
    output$plot1 <- renderPlotly({
      if(input$units == "Megatonnes") denom <- 1E6
      if(input$units == "Cars") denom <- 4.7
      if(input$units == "Tonnes") denom <- 1
      
      cdat <- data.frame(Region = c("Arid, high tidal amplitude", "Warm sub-humid, high tidal amplitude", 
                                    "Warm humid, low tidal amplitude",
                                    "Warm sub-humid, low tidal amplitude", "Reported"),
        Cd = c(1156.4, 1978.5, 1911.0, 1924.2, 56.885), stringsAsFactors = FALSE)
      irow <- which(cdat$Region %in% input$Region)
      nchoices <- length(irow)
      Cd <- cdat[irow,"Cd"]
      years <- 0:input$yrmax
      carbon <- NULL
      
      for (i in 1:nchoices){
        carbon <- c(carbon, 
                    list(
                      calcdef(years, input$A0, Cd[i], input$d, -input$rd)/denom
                      ))
      }
      emcols <- c("#1b9e77", "#7570b3","#e7298a", "#66a61e",'#d95f02')
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
