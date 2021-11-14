#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  
  if (lubridate::force_tz(current_ts, TZ) + max_offset < lubridate::now(tzone = TZ))
    get_data()
  
  onStop(function() {
    cat("\n----- Closing DB connections -----\n")
    pool::poolClose(db)
    cat("\n----- DB connections closed -----\n")
  })

  sever::rupture(ms = 600000, html = timeout)
  
  observeEvent(input$ruptured, {
      session$close()
  })

  ref_content <- list("src" = "NULL",
                      "utm_source" =  "NULL",
                      "utm_medium" = "NULL",
                      "utm_content" = "NULL",
                      "utm_campaign" = "NULL")
  observe({
    query = getQueryString()
    params = names(query)
    if ("global" %in% params) {
      updateNavbarPage(session, "nav-page", "global")
    } else if (any(c("game", "quiz") %in% params)) {
      updateNavbarPage(session, "nav-page", "game")
    }
    ref_tags = c("src", "utm_source", "utm_medium", "utm_content", "utm_campaign")
    for (tag in ref_tags){
      ref_content[[tag]] <- ifelse(tag %in% params, query[[tag]], "NULL")
    }
  })
  
  
  r = reactive
  globals <- list(consent = r(input[["cookies"]][["consent"]]),
                  latitude = r(input[["lat"]]),
                  longitude = r(input[["long"]]),
                  ip = r(input[["ip_data"]]),
                  nav = r(input[["nav-page"]]),
                  setGeo = r(input[["setGeo"]]),
                  geolocation = r(input[["geolocation"]]),
                  ref_content = ref_content,
                  session = session,
                  db = db)
  
  mod_usa_risk_map_server("usa_risk_map", globals)
  mod_switch_maps_server("switcher_us", globals)
  mod_switch_maps_server("switcher_global", globals)
  mod_take_quiz_button_server("to_quiz", globals)
  mod_show_data_server("to_data", globals)
  mod_risk_quiz_server("quiz", globals)
  mod_usa_real_time_server("usa_real_time", globals)
  mod_global_risk_map_server("global_risk_map_ui_1")
  
}
