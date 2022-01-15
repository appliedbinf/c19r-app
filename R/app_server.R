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
  # Every 2 hours (on first request) update data
  if (lubridate::force_tz(current_ts, TZ) + max_offset < lubridate::now(tzone = TZ)) {
    get_data()
  }

  # 10 min idle timeout
  sever::rupture(ms = 600000, html = timeout)

  # End session on id timeout
  observeEvent(input$ruptured, {
    session$close()
  })

  # On load, check the query string for:
  # game/quiz -> switch to Risk Quiz tab
  # global -> switch to global map tab
  observe({
    query <- getQueryString()
    params <- names(query)
    if ("global" %in% params) {
      updateNavbarPage(session, "nav-page", "global")
    } else if (any(c("game", "quiz") %in% params)) {
      updateNavbarPage(session, "nav-page", "game")
    }
  })

  # Reactive used to parse UTM vars from query string
  ref_content <- reactive({
    query <- getQueryString()
    params <- names(query)
    content <- list()
    ref_tags <- c("src", "utm_source", "utm_medium", "utm_content", "utm_campaign")
    for (tag in ref_tags) {
      content[[tag]] <- ifelse(tag %in% params, query[[tag]], "NULL")
    }
    content
  })

  # Global variables to pass around modules
  r <- reactive
  globals <- list(
    consent = r(input[["cookies"]][["consent"]]),
    latitude = r(input[["lat"]]),
    longitude = r(input[["long"]]),
    ip = r(input[["ip_data"]]),
    nav = r(input[["nav-page"]]),
    setGeo = r(input[["setGeo"]]),
    geolocation = r(input[["geolocation"]]),
    ref_content = ref_content,
    session = session,
    db = db
  )

  mod_usa_risk_map_server("usa_risk_map", globals)
  mod_switch_maps_server("switcher_us", globals)
  mod_switch_maps_server("switcher_global", globals)
  mod_take_quiz_button_server("to_quiz_map", globals)
  mod_take_quiz_button_server("to_quiz_sidebar", globals)
  mod_show_data_server("to_data", globals)
  mod_risk_quiz_server("quiz", globals)
  mod_usa_real_time_server("usa_real_time", globals)
  mod_global_risk_map_server("global_risk_map_ui_1")
}
