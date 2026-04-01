library(surveydown)
library(shiny)
library(DBI)
library(RPostgres)

db <- sd_db_connect(ignore = TRUE)

server <- function(input, output, session) {
  sd_skip_if()
  sd_show_if()
  
  # INTERCEPT AND HANDLE LATENCY EVENTS BEFORE sd_server()
  observeEvent(input$latency_event, {
    latency_data <- input$latency_event
    
    # Store milliseconds as-is (don't let surveydown convert it)
    # Add to your data storage with the raw millisecond value
    cat("Question ID:", latency_data$questionId, 
        "Response:", latency_data$responseValue,
        "Latency (ms):", latency_data$latency, "\n")
    
    # If using custom database storage, save here with latency in milliseconds
    # Example: 
    # save_latency_to_db(
    #   question_id = latency_data$questionId,
    #   response_value = latency_data$responseValue,
    #   latency_ms = latency_data$latency  # Keep as milliseconds!
    # )
  })
  
  sd_server(db = db, use_cookies = FALSE)
}

shiny::shinyApp(ui = sd_ui(), server = server)