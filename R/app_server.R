#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
    sever::rupture(ms = 600000, html = timeout)
    
    observeEvent(input$ruptured, {
        session$close()
    })
    get_data()
    source("R/server/navigation.R", local = T)
    source("R/server/usa-map-reactivity.R", local = T)
    source("R/server/global-map-reactivity.R", local = T)
    source("R/server/usa-real-time-plots.R", local = T)
    source("R/server/risk-game-reactivity.R", local = T)
}
