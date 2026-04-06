library(surveydown)
library(shiny)
library(DBI)

db <- sd_db_connect()  # Ignore database for testing

ui <- tagList(
  sd_ui(),
  tags$script(HTML(
    '
console.log("[DEBUG] Latency JS running");
function attachLatencyListeners() {
  document.querySelectorAll("input[type=\\"radio\\"]").forEach(function(radio){
    var name = radio.getAttribute("name");
    if(!name)return;
    var questionId = name;
    if(!window.latencyTimers) window.latencyTimers = {};
    radio.addEventListener("mousedown",function(){
      window.latencyTimers[questionId] = Date.now();
      console.log("[DEBUG] Mouse down for", questionId, window.latencyTimers);
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
)

server <- function(input, output, session) {
  observeEvent(input$latency_event, {
    event <- input$latency_event
    print(event)
    # Your db logic here
  })
  sd_server(db = db, use_cookies = FALSE)
}
shiny::shinyApp(ui = ui, server = server)