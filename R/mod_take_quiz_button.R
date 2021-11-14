#' take_quiz_button UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_take_quiz_button_ui <- function(id) {
  ns <- NS(id)
  shinyWidgets::actionBttn(
    ns("to_game"),
    label = "Take the quiz",
    style = "jelly",
    color = "success",
    size = "sm"
  )
}

#' take_quiz_button Server Functions
#'
#' @noRd
mod_take_quiz_button_server <- function(id, globals) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(input$to_game, {
      updateTabsetPanel(globals$session, "nav-page", "game")
    })
  })
}

## To be copied in the UI
# mod_take_quiz_button_ui("take_quiz_button_ui_1")

## To be copied in the server
# mod_take_quiz_button_server("take_quiz_button_ui_1")
