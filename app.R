library(surveydown)
library(shiny)
library(DBI)
library(RPostgres)

db <- sd_db_connect(ignore = TRUE)  # Ignore database for testing

server <- function(input, output, session) {
  sd_skip_if()
  sd_show_if()
  sd_server(db = db, use_cookies = FALSE)
}

shiny::shinyApp(ui = sd_ui(), server = server)