#' switch_maps UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_switch_maps_ui <- function(id, label) {
  ns <- NS(id)
  tagList(
    shinyWidgets::actionBttn(
      inputId = ns("switch_maps"),
      label = label,
      style = "jelly",
      color = "success",
      size = "sm"
    )
  )
}

#' switch_maps Server Functions
#'
#' @noRd
mod_switch_maps_server <- function(id, globals) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(input$switch_maps, {
      if (globals$nav() == "global") {
        updateTabsetPanel(globals$session, "nav-page", "usa")
      } else if (globals$nav() == "usa") {
        updateTabsetPanel(globals$session, "nav-page", "global")
      }
    })
  })
}

## To be copied in the UI
# mod_switch_maps_ui("switch_maps_ui_1")

## To be copied in the server
# mod_switch_maps_server("switch_maps_ui_1")
