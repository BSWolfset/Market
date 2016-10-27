# Farmers Market App ui.R

ui <- fluidPage(
  # Application title
  titlePanel("US Farmer's Markets"),
  helpText("Application works in Firefox.  May have limited functionality in Chrome, Edge, Internet Explorer."),
  # Show a plot of the generated distribution
  leafletOutput("FMMap"),
  
  # Sidebar with a slider input for number of bins
  absolutePanel(
    id = "userInput",
    class = "panel panel-default",
    fixed = TRUE,
    draggable = FALSE,
    top = "auto",
    left = 20,
    right = "auto",
    bottom = 300,
    width = 330,
    height = "auto",
    selectInput("SelectState","Select State",
      c("All states" = "", as.matrix(StateList)),
      multiple = FALSE
    ),
    conditionalPanel(
      "input.SelectState",
      selectInput("SelectCity",label = "Choose a City:",
        choices = c("All cities" = ""),
        multiple = FALSE
      )
    ),
    
    p("Click on a Farmers Market to show details.")
  )
  
)