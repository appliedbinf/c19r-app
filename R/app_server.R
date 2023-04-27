#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Allow session reconnects.  Should help with sessions that abrustly end
  # because of brief network errors
  session$allowReconnect(TRUE)
  
  # Timezone to use for timestamp-based 
    TZ <- "America/New_York"


  # 10 min idle timeout
  sever::rupture(ms = 600000, html = timeout)

  # End session on id timeout
  observeEvent(input$ruptured, {
    session$close()
  })

  

  # Global variables to pass around modules
  r <- reactive
  globals <- list(
    consent = r(input[["cookies"]][["consent"]]),
    atitude = r(input[["lat"]]),
    longitude = r(input[["long"]]),
    ip = r(input[["ip_data"]]),
    nav = r(input[["nav-page"]]),
    setGeo = r(input[["setGeo"]]),
    geolocation = r(input[["geolocation"]]),
    session = session
  )

  mod_usa_risk_map_server("usa_risk_map", globals)
  mod_show_data_server("to_data", globals)
  mod_risk_quiz_server("quiz", globals)
  mod_take_quiz_button_server("to_quiz_map", globals)
}
