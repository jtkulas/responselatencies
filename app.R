library(surveydown)
library(shiny)
library(DBI)

db <- sd_db_connect()  # Ignore database for testing

server <- function(input, output, session) {
  # Capture latency events
  observeEvent(input$latency_event, {
    event <- input$latency_event
    
    cat("📊 Latency event received:\n")
    cat("  Question:", event$questionId, "\n")
    cat("  Response:", event$responseValue, "\n")
    cat("  Latency (ms):", event$latency, "\n\n")
    
    # Prepare data for database
    latency_row <- data.frame(
      session_id = session$token,
      question_id = event$questionId,
      response_value = event$responseValue,
      latency_ms = as.numeric(event$latency),
      stringsAsFactors = FALSE
    )
    
    # Insert into Supabase
    tryCatch({
      dbAppendTable(db, "latency_events", latency_row)
      cat("✓ Saved to latency_events table\n\n")
    }, error = function(e) {
      cat("✗ Error saving to database:", e$message, "\n\n")
    })
  })
  
  sd_skip_forward()
  sd_show_if()
  sd_server(db = db, use_cookies = FALSE)
}

shiny::shinyApp(ui = sd_ui(), server = server)