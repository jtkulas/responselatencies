library(surveydown)
library(shiny)
library(DBI)

db <- sd_db_connect()  # Ignore database for testing

ui <- tagList(
  tags$head(
    tags$script(HTML(
      '
function attachLatencyListeners() {
  document.querySelectorAll("input[type=\\"radio\\"]").forEach(function(radio){
    var name = radio.getAttribute("name");
    if(!name)return;
    var questionId = name;
    if(!window.latencyTimers) window.latencyTimers = {};
    radio.addEventListener("mousedown",function(){
      window.latencyTimers[questionId] = Date.now();
    });
    radio.addEventListener("click",function(){
      var latency = Date.now() - (window.latencyTimers[questionId] || Date.now());
      if(window.Shiny){
        window.Shiny.setInputValue("latency_event",{
          questionId:questionId,
          responseValue:radio.value,
          latency:latency
        },{priority:"event"});
      }
      console.log("📊 Recording latency:",{questionId,responseValue:radio.value,latency});
    });
  });
}
document.addEventListener("DOMContentLoaded", function(){
  setTimeout(attachLatencyListeners, 250);
});
(new MutationObserver(function(){ setTimeout(attachLatencyListeners, 250); })).observe(document.body, { childList: true, subtree: true });
'
    ))
  ),
  sd_ui()
)

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

shiny::shinyApp(ui = ui, server = server)