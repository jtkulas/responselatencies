library(surveydown)
library(shiny)
library(DBI)
library(RPostgres)
library(pool)

# 1. Create pool at global scope
con <- dbPool(
  drv      = RPostgres::Postgres(),
  host     = "aws-1-us-west-1.pooler.supabase.com",
  port     = 6543,
  user     = "postgres.bifyyedjqatwyhorqgnf",
  password = "1kCMfEeR9n8GP82K",
  dbname   = "postgres",
  sslmode  = "require"
)

print("POOL AT CREATION:")
print(con)

ui <- tagList(
  sd_ui(),
  tags$script(HTML(
    '
window.addEventListener("load", function() {
  console.log("Latency tracker JS loaded");
});
'
  ))
)

server <- function(input, output, session) {
  print("POOL IN SERVER FUNCTION:")
  print(con)
  
  # Just a no-op observer for now
  observeEvent(input$latency_event, {
    print(input$latency_event)
  })
  
  # <<<<<<<<<<<<<<<<
  print("POOL JUST BEFORE sd_server CALL:")
  print(con)
  # <<<<<<<<<<<<<<<<
  
  sd_skip_forward()
  sd_show_if()
  sd_server(db = con, use_cookies = FALSE)
}

shiny::shinyApp(ui = ui, server = server)