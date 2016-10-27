# Farmers Market App - server.R

server <- function(input, output, session) {
  # Create the map
  output$FMMap <- renderLeaflet({
    leaflet() %>%
      addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
      setView(lng = -103.85,lat = 47.45,zoom = 3)
  })
  
  #Using Leaflet proxy - show all of the farmer's market locations
  leafletProxy("FMMap", data = FarmMarketDisp) %>%
    clearMarkers() %>%
    addCircles(lat =  ~ FarmMarketDisp$y, lng =  ~ FarmMarketDisp$x,
      weight = 3, radius = 15, stroke = FALSE    )

  # Waiting for state selection and display updated map
  observeEvent(input$SelectState, ({
    if (is.null(input$SelectState) | input$SelectState %in% "All states")
      { FarmMarketDisp <- FarmMarketDS }
    else {
      FarmMarketDisp <- filter(FarmMarketDS, FarmMarketDS$State %in% input$SelectState)
    }
    
    leafletProxy("FMMap", data = FarmMarketDisp) %>%
      addCircleMarkers(
        lat =  ~ FarmMarketDisp$y,
        lng =  ~ FarmMarketDisp$x,
        weight = 10,
        radius = 15,
        stroke = FALSE,
        color = "#984EA3"
      )  %>%
      setView(lng = FarmMarketDisp$x[1],
              lat = FarmMarketDisp$y[1],
              zoom = 7)
  }) )
  
  
  #Waiting for city select and display updated map
  observe ({
    CityList <- if (is.null(input$SelectState))
      character(0)
    else {
      filter(FarmMarketDS, FarmMarketDS$State %in% input$SelectState) %>%
        `$`('city') %>%
        unique() %>%
        sort()
    }
    
    # this displays the city choices
    stillSelected <- isolate(input$SelectCity[input$SelectCity %in% CityList])
    updateSelectInput(session,
                      "SelectCity",
                      choices = CityList,
                      selected = stillSelected)
    
    # look to see if a city was selected and then set display data frame
    if (is.null(input$SelectCity) |
        input$SelectCity %in% "All cities") {
    }
    else {
      FarmMarketDisp <- filter(FarmMarketDS, 
                               FarmMarketDS$State %in% input$SelectState & FarmMarketDS$city %in% input$SelectCity )
    }
    
    leafletProxy("FMMap", data = FarmMarketDisp) %>%
      addCircleMarkers(
        lat =  ~ FarmMarketDisp$y,
        lng =  ~ FarmMarketDisp$x,
        weight = 10,
        radius = 15,
        stroke = FALSE,
        color = "#FF7F00"
      )  %>%
      setView(lng = FarmMarketDisp$x[1],
              lat = FarmMarketDisp$y[1],
              zoom = 10)
    
  })
  
  ## Define function to get popup data and then display on map
  # Get popup data for Market location
  showMarketPopup <- function(lat, lng) {
    selectedMarket <- FarmMarketDS[FarmMarketDS$x == lng | FarmMarketDS$y == lat , ]
    content <- as.character(tagList(
      tags$h4(selectedMarket$MarketName),
      tags$strong(HTML(
        sprintf(
          "%s, %s %s",
          selectedMarket$street,
          selectedMarket$city,
          selectedMarket$State
        )
      )),
      tags$br(),
      sprintf("Times: %s", selectedMarket$Season1Time),
      tags$br(),
      sprintf("Dates: %s%%", selectedMarket$Season1Date)
    ))
    
    leafletProxy("FMMap") %>% addPopups(lng = lng, lat = lat, content)
  }
  
  # When map is clicked, show a popup with Market Info
  observe({
    leafletProxy("FMMap") %>% clearPopups()
    event <- input$FMMap_marker_click
    if (is.null(event)) return()
    isolate({ showMarketPopup(event$lat, event$lng) })
  })
  
} ## end shinyServer
