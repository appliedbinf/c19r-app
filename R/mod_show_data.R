#' show_data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_show_data_ui <- function(id) {
  ns <- NS(id)
  actionLink(ns("to_data"), "See our data sources")
}

#' show_data Server Functions
#'
#' @noRd
mod_show_data_server <- function(id, globals) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(input$to_data, {
      updateTabsetPanel(globals$session, "nav-page", "about")
      updateTabsetPanel(globals$session, "abouttabs", "data")
    })
  })
}

## To be copied in the UI
# mod_show_data_ui("show_data_ui_1")

## To be copied in the server
# mod_show_data_server("show_data_ui_1")
