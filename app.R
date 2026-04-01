library(surveydown)
library(shiny)
library(DBI)

db <- sd_db_connect(ignore = TRUE)  # Ignore database for testing

server <- function(input, output, session) {
  sd_skip_forward()
  sd_show_if()
  
  # Create a reactive data frame to store latency events
  latency_data <- reactiveVal(data.frame(
    questionId = character(),
    responseValue = character(),
    latency_ms = character(),  # Store as string/text to preserve milliseconds
    timestamp = character(),
    stringsAsFactors = FALSE
  ))
  
  # Capture latency events BEFORE surveydown processes them
  observeEvent(input$latency_event, {
    event <- input$latency_event
    
    # Append to latency data
    current_data <- latency_data()
    new_row <- data.frame(
      questionId = event$questionId,
      responseValue = event$responseValue,
      latency_ms = as.character(event$latency),  # Convert to string to preserve milliseconds
      timestamp = as.character(Sys.time()),
      stringsAsFactors = FALSE
    )
    latency_data(rbind(current_data, new_row))
    
    # Optional: Print to console for debugging
    cat("Latency captured (ms):", event$latency, "\n")
  })
  
  # Call surveydown server
  sd_server(db = db, use_cookies = FALSE)
}

shiny::shinyApp(ui = sd_ui(), server = server)