library(shiny)
library(reactable)
library(shinyfilter)
library(tidyverse)


newdrinks<- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-26/cocktails.csv')


ui <- fluidPage(
  titlePanel("Cocktail Ingredients"),
  sidebarLayout(
    sidebarPanel(
      width = 2,
      
      selectizeInput(inputId = "sel_manufacturer", label = "Type in your Ingredient",
                     multiple = TRUE, options = list(onChange = event("ev_click")),
                     choices = sort(unique(newdrinks$ingredient))),
      selectizeInput(inputId = "sel_name", label = "Drink Name",
                     multiple = TRUE, options = list(onChange = event("ev_click")),
                     choices = sort(unique(newdrinks$drink))),
      selectizeInput(inputId = "sel_measure", label = "Measure",
                     multiple = TRUE, options = list(onChange = event("ev_click")),
                     choices = sort(unique(newdrinks$measure))),
    ),
    mainPanel(
      reactableOutput(outputId = "tbl_food")
    )
  )
)



server <- function(input, output, session) {
  
  r <- reactiveValues(mycars = newdrinks)
  
  define_filters(input,
                 "tbl_food",
                 c(sel_manufacturer = "Ingredient", 
                   sel_name = "Name of Drink",
                   sel_fuel = "Measure"), 
                 newdrinks)
  
  
  observeEvent(input$ev_click, {
    r$mycars <- update_filters(input, session, "tbl_food")
    update_tooltips("tbl_food", 
                    session, 
                    tooltip = TRUE, 
                    title_avail = "Available is:", 
                    title_nonavail = "Currently not available is:",
                    popover_title = "My filters",
                    max_avail = 10,
                    max_nonavail = 10)
  })
  
  
  output$tbl_food <- renderReactable({
    reactable(data = r$mycars,
              filterable = TRUE,
              rownames = FALSE,
              selection = "multiple",
              showPageSizeOptions = TRUE,
              paginationType = "jump",
              showSortable = TRUE,
              highlight = TRUE,
              resizable = TRUE,
              rowStyle = list(cursor = "pointer"),
              onClick = "select"
    )
  })
  
}

shinyApp(ui = ui, server = server)
