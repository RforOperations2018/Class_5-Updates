# Class 5
# In Class Examples - Tabset

# Class 4
# In Class Examples - Inputs - Final

library(shiny)
library(reshape2)
library(dplyr)
library(plotly)
library(shinythemes)
library(stringr)

starwars.load <- starwars %>%
  mutate(films = as.character(films),
         vehicles = as.character(vehicles),
         starships = as.character(starships),
         name = as.factor(name))

diamonds.load <- diamonds

pdf(NULL)

# Define UI for application that draws a histogram
ui <- navbarPage("Star Wars NavBar", 
                 tabPanel("Plot",
                          sidebarLayout(
                            sidebarPanel(
                              # Homeworld select
                              selectInput("worldSelect",
                                          "Homeworld:",
                                          choices = sort(unique(starwars.load$homeworld)),
                                          multiple = TRUE,
                                          selectize = TRUE,
                                          selected = c("Naboo", "Tatooine")),
                              # Birth Selection
                              sliderInput("birthSelect",
                                          "Birth Year:",
                                          min = min(starwars.load$birth_year, na.rm = T),
                                          max = max(starwars.load$birth_year, na.rm = T),
                                          value = c(min(starwars.load$birth_year, na.rm = T), max(starwars.load$birth_year, na.rm = T)),
                                          step = 1),
                              actionButton("reset", "Reset Filters", icon = icon("refresh"))
                            ),
                            # Output plot
                            mainPanel(
                              plotlyOutput("plot")
                            )
                          )
                 ),
                 # Data Table
                 tabPanel("Table",
                          inputPanel(
                            downloadButton("downloadData","Download Star Wars Data")
                          ),
                          fluidPage(DT::dataTableOutput("table"))
                 )
)

# Define server logic
server <- function(input, output, session = session) {
  # Filtered Starwars data
  swInput <- reactive({
    starwars <- starwars.load %>%
      # Slider Filter
      filter(birth_year >= input$birthSelect[1] & birth_year <= input$birthSelect[2])
    # Homeworld Filter
    if (length(input$worldSelect) > 0 ) {
      starwars <- subset(starwars, homeworld %in% input$worldSelect)
    }
    
    return(starwars)
  })
  # Reactive melted data
  mwInput <- reactive({
    swInput() %>%
      melt(id = "name")
  })
  # Point plot showing Mass, Height and Species
  output$plot <- renderPlotly({
    dat <- swInput()
    ggplotly(
      ggplot(data = dat, aes(x = mass, y = height, color = species, text = paste0("<b>", name, ":</b> ",
                                                                                  "<br>Homeworld: ", homeworld,
                                                                                  "<br>Mass: ", mass,
                                                                                  "<br>Height: ", height))) + 
        geom_point() +
        guides(color = FALSE)
      , tooltip = "text")
  })
  # Data Table
  output$table <- DT::renderDataTable({
    starwars <- swInput()
    
    subset(starwars, select = c(name, height, mass, birth_year, homeworld, species, films))
  })
  # Updating the URL Bar
  # Download data in the datatable
  # Reset Filter Data
}

# Run the application 
shinyApp(ui = ui, server = server, enableBookmarking = "url")