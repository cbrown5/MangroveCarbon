# Shiny attempt
library(shiny)
library(plotly)

#TODO: 
# Add loading bar
# A few issues with event_data - I can't get it to print country names as names (turns into characters)
#At the moment I just read in a random GDP csv (called df)
#Update this with country carbon values eventually
#This page is handy https://stackoverflow.com/questions/44334968/click-on-points-in-a-leaflet-map-as-input-for-a-plot-in-shiny
#esp if I want to doa  leaflet map
#add deforestatino rates too. 

ui <- fluidPage(
  tags$head(
    tags$style(
      HTML("
        h2{
              color:white;
              background-color: #00b300;
              margin:0px;
              padding:5px;
              font-size:2em;
        }

        a{
  color:#009933;
           }
           
           a:hover, a:focus{
           color:#006600;
           }
           
           .navbar {
           background-color:#00b300;
           border-color:white;
           }
           .navbar-brand {
           }
           .nav-tabs-custom > .nav-tabs > li.active {
           border-top-color:#00b300;
           }
      ")
    )
  ),

  titlePanel("Emissions from mangrove deforestation"),

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
    textInput(inputId = "mGC02_ha",
              label = "Carbon Stock (MgC02 per hectare)",
              value = "776" #Values from Adame et al. 2018
    ),
    textInput(inputId = "emname",
              label = "Scenario label",
              value = "Reported"
    )
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
    ,
    
    downloadButton("downloadData", "Download simulations"),
    
    selectInput(inputId = "palettechoice",
                label = "Color Palette",
                choices = list("Greens" = "Greens", 
                               "Reds" = "Reds", 
                               "Blues" = "Blues", 
                               "Purples" = "Purples", 
                               "Brown-Green" = "BrBG", 
                               "Spectral" = "Spectral", 
                               "Multi" = "Dark2", 
                               "Set1" = "Set1"), 
                selected = "Greens")
    ),

    mainPanel(
      fluidRow(
        column(12,div(style = "height:250px; overflow-y: scroll;padding:20px;",
      tabsetPanel(
        tabPanel("About",
                 fluidRow(
                   p("Forests store carbon, which helps fight climate change."), 
                     p("Countries measure the amount of carbon stored in their forests and wetlands when calculating their total carbon emissions."),  
                     
                     p("It's a critical part of determining if they're meeting their obligations under 
                     international frameworks, like the Paris Climate Agreement."),  
                     
                     p("However, assessments often overlook the carbon stored in the soils 
                     beneath forests. "), 
                     
                     p("That's a problem because in some forests, like mangroves, that's where most of the carbon is actually stored. "), 
                     
                     p("This leads to countries underestimating both their total carbon emissions and 
                     the true value of protecting their coastal wetlands."),   
                     
                     a(href = "https://globalwetlandsproject.org", "Our research in Mexico shows
                       that mangrove forests store much more carbon than rainforests, per unit area."),  
                     
                     p("When the mangrove trees are removed, the soil carbon is released too - it's not just the trees. "),
                     
                     p("This web app is designed to help you explore the contribution of mangrove protection to mitigating emissions. 
                        It supports the publication:",
                       a(href = "http://onlinelibrary.wiley.com/doi/10.1111/conl.12445/full", 
                         "Adame et al. The undervalued contribution of mangrove protection in Mexico to carbon emission targets. Conservation Letters")),
                      
                     p("Please cite that publication if you use output from this app or the",
a(href = "https://github.com/cbrown5/MangroveCarbon", "associated R package."))
)),

        tabPanel("Instructions",
                 fluidRow(
                   p("Use panel on the left to explore how carbon emissions change under different deforestation rates."),
                   
                   p("You can enter the potential carbon dioxide emissions in the 'Carbon Stock' box. 
                     Separate multiple values by commas (up to 9 allowed).  "),
                   
                   p("A few details. All rates are instantaneous annual values. You can plot the emissions in different units, 
                     including in terms of annual car emissions. 'Cars per annum' is an average annual emission rate from cars in the USA. "),
                   
                   p("Hover over the plot for more options. For example the camera icon lets you save the plot as an image. ")
                   ),
                 fluidRow(p("Contact Chris Brown (chris.brown@griffith.edu.au) if you have any queries about the web app"))
                   ),
        tabPanel(" Model description and contact",
                 fluidRow(
                   p("The default data used here come from actual field surveys of carbon in soils, 
                          trees and dead-wood in Mexico's mangrove forests across the country's three major climate regions.
                   The model estimates annual emissions based on the carbon estimates for each region and a rate of forest loss.
                      Forest loss occurs at a constant rate."),   
                   
                   p("Carbon dioxide may take some time to be released once a mangrove forest is cleared. 
                     The 'Emission rate' slider controls this rate of emissions once an area of forest is lost.
                     Evidence suggests that emissions are lost at a rate of about 10% per year (the default value used here).
                   See the publication for further details of the data and models underlying this app."),
                   
                   a(href = "http://www.seascapemodels.org/MangroveCarbon/", 
                     "Click here if you want to see the code underneath the hood of this model"),  
                   
                   p("The web app was designed by Drs Chris Brown and Fernanda Adame using the R program, RShiny and plotly."),
                   
                   a(href = "https://globalwetlandsproject.org", "Design and deployment has been supported by the 
                    Global Wetlands Program at Griffith University"),  
                   
                   p("Contact Chris Brown (chris.brown@griffith.edu.au) if you have any queries about the web app.")
                   )
    )
))
)
  ),
tabsetPanel(
tabPanel("Emissions", 
    plotlyOutput("plot1")),
tabPanel("Map", fluidRow(
  p("Click on the map to estimate carbon storage based on global data"),
  plotlyOutput("plot2")))
)
)
)
)

server <- function(input, output, session) {
  
  calcdef <- function(tsteps, A1, C, d, r){
    if (d == r) d <- d+(d/10000)
    A1 * C - ((exp(-tsteps*r) * (A1*C*r*exp(tsteps*r) - A1 * C*d*exp(tsteps*d)))/ 
                (exp(tsteps * d)*r - d*exp(tsteps*d)))
  }
  
  runsims <- reactive({
    
    Cd <- as.numeric(unlist(strsplit(input$mGC02_ha, split = ",")))
    emname <- unlist(strsplit(input$emname, split = ","))
    if (length(emname) < length(Cd)) emname <- c(emname, rep("", length(Cd)-length(emname)))
    nchoices <- length(Cd)
    years <- 0:input$yrmax
    carbon <- NULL
    for (i in 1:nchoices){
      carbon <- c(carbon,
                  list(
                    calcdef(years, input$A0, Cd[i], input$d, input$rd)
                  ))
    }
    carbondf <- data.frame(year = rep(years, nchoices), 
                           scenario = rep(emname, each = length(years)),
                            emissions = unlist(carbon), 
                           units = "Tonnes C02")
    return(list(carbon = carbon, nchoices = nchoices, 
                emname = emname, years = years, carbondf = carbondf))
  })

  
  output$plot1 <- renderPlotly({
    if(input$units == "Megatonnes") denom <- 1E6
    if(input$units == "Cars per annum") denom <- 4.6
    if(input$units == "Tonnes") denom <- 1

    # 
    # Cd <- as.numeric(unlist(strsplit(input$mGC02_ha, split = ",")))
    # emname <- unlist(strsplit(input$emname, split = ","))
    # if (length(emname) < length(Cd)) emname <- c(emname, rep("", length(Cd)-length(emname)))
    # nchoices <- length(Cd)
    # years <- 0:input$yrmax
    # carbon <- NULL
    # dashdot <- rep(c(NA, "dash", "dot"), 3)[1:nchoices]
    # 
    # for (i in 1:nchoices){
    #   carbon <- c(carbon,
    #               list(
    #                 calcdef(years, input$A0, Cd[i], input$d, input$rd)/denom
    #               ))
    # }
    simout <- runsims()
    emcols <- RColorBrewer::brewer.pal(9, input$palettechoice)[(9-simout$nchoices):9]
    dashdot <- rep(c(NA, "dash", "dot"), 3)[1:simout$nchoices]
    pfont <- list(
      size = 14,
      color = 'black')
    p <- plot_ly(x = simout$years, y = simout$carbon[[1]]/denom, name = simout$emname[1], 
                 mode = "lines",
                 line = list(color=emcols[1], width = 4)) %>%
      layout(title = "",
             xaxis = list(title = "Year"),
             yaxis = list(title =paste0('Cumulative emissions (',input$units,')')), 
             font = pfont)
    for (i in 1:simout$nchoices){
      if (simout$nchoices >1){
        p <- add_trace(p, y = simout$carbon[[i]]/denom, name = simout$emname[i], 
                       mode = 'lines',
                       line = list(color=emcols[i], width = 4, dash = dashdot[i]))}
    }
    p
    
  })
  
  output$plot2 <- renderPlotly({
    
    #add carbon data here
    df <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2014_world_gdp_with_codes.csv', 
                   stringsAsFactors = FALSE)
    
    g <- list(
      projection = list(type = 'Robinson'),
      lakecolor = toRGB('white')
    )
    
    plot_geo(df) %>%
      add_trace(
        z = ~GDP..BILLIONS., color = ~GDP..BILLIONS., colors = 'Greens',
        text = ~COUNTRY, locations = ~CODE
      ) %>%
      colorbar(title = 'GDP Billions US$', tickprefix = '$') %>%
      layout(
        title = '',
        geo = g
      )
    
   
  })
  
  observe({ #watches for changes
    d <- event_data("plotly_click") #get data from plotly click
    xout <- d[3]
    cname <- as.character(d[2])
    isolate({ #isolate to prevent and infinte loop 
      if (is.null(xout)){
        updateval <-input$mGC02_ha
        scnrlabel <- input$emname
      } else{
        updateval <- paste(input$mGC02_ha, xout, sep = ", ")
        scnrlabel <- paste(input$emname, cname, sep = ", ")
      }
    })
    
    #Update the inputss
    updateTextInput(session, "mGC02_ha",
                    label= "Carbon Stock (MgC02 per hectare)",
                      value = updateval)
    updateTextInput(session, "emname",
                    label= "Scenario label",
                    value = scnrlabel)
  
  })

  output$downloadData <- downloadHandler(
    filename = function(){paste("Mangrove-emission-data.csv")},
    content = function(file) {
      write.csv(runsims()$carbondf, file, row.names = FALSE)
    }
  )
  
}

shinyApp(ui = ui, server = server)
