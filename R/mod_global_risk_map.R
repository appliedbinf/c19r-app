#' global_risk_map UI Function
#'
#' @description Global risk map page.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_global_risk_map_ui <- function(id) {
  ns <- NS(id)
  tabPanel(
    value = "global",
    title = "Global Risk Estimates",
    fluid = TRUE,
    sidebarLayout(
      sidebarPanel(
        width = 3,
        HTML(
          paste0(
            "<style>.icon-grid{display: grid; grid-gap: 10px; grid-template-columns: repeat(3, minmax(50px, 90px))} .icon-grid img{width: 100%;}</style>",
            "<div>This map shows the risk level of attending an event, given the event size and location.  ",
            "</br>",
            "The risk level is the estimated chance (0-100%) that at least 1 COVID-19 positive individual will be present at an event in a NUTS-3 level area (County, Local Authority, Council, District), given the size of the event.</div>",
            "</br>",
            "<div>You can reduce the risk that one case becomes many by: </div>",
            "<div><div class='icon-grid'>",
            "    <div ><img src='www/icons/mask.png' alt='Wear a mask'></div>",
            "    <div ><img src='www/icons/test.png' alt='Get tested'></div>",
            "    <div ><img src='www/icons/vaccinate.png' alt='Get vaccinated'></div>",
            "    <div ><img src='www/icons/distance.png' alt='Social distance'></div>",
            "    <div ><img src='www/icons/outside.png'' alt='Meet outside...'></div>",
            "    <div ><img src='www/icons/ventilate.png' alt='..or ventilate'></div>",
            "</div></div>",
            "</br>",
            "<div>Choose an event size and ascertainment bias below</div>"
          )
        ),
        mod_show_data_ui("to_data"),
        shinyWidgets::sliderTextInput(
          ns("global_event_size_map"),
          "Event Size: ",
          choices = event_size,
          selected = 50,
          grid = T
        ),
        shinyWidgets::awesomeRadio(
          inputId = ns("global_asc_bias"),
          label = "Select Ascertainment Bias",
          choices = c("2", "3", "5"),
          selected = "3",
          status = "warning",
          inline = T
        )
      ),
      mainPanel(
        fluidRow(column(
          10,
          htmlOutput(ns("eu_map_static"), width = "331px", height = "744px")
        )),
        HTML(
          "<p>(Note: This map uses a Web Mercator projection that inflates the area of states in northern latitudes. County boundaries are generalized for faster drawing.)</p>"
        ),
        fluidRow(
          align = "center",
          column(
            10,
            mod_switch_maps_ui("switcher_global", label = "Explore USA risk estimates")
          )
        )
      )
    )
  )
}

#' global_risk_map Server Functions
#'
#' @noRd
mod_global_risk_map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(input$global_event_size_map, {
      output$eu_map_static <- renderUI({
        tags$iframe(
          src = paste0("https://covid19risk.biosci.gatech.edu/", "eu_", input$global_asc_bias, "_", input$global_event_size_map, ".html"),
          style = "position: relative; height: 60vh; width: -moz-available; width: -webkit-fill-available;  width: fill-available; max-width: 992px; max-height: 500px; min-height: 350px; align: center", frameBorder = "0"
        )
      })
    })

    observeEvent(input$global_asc_bias, {
      output$eu_map_static <- renderUI({
        tags$iframe(
          src = paste0("https://covid19risk.biosci.gatech.edu/", "eu_", input$global_asc_bias, "_", input$global_event_size_map, ".html"),
          style = "position: relative; height: 60vh; width: 95vw; max-width: 992px; max-height: 500px; min-height: 350px; align: center", frameBorder = "0"
        )
      })
    })
  })
}

## To be copied in the UI
# mod_global_risk_map_ui("global_risk_map_ui_1")

## To be copied in the server
# mod_global_risk_map_server("global_risk_map_ui_1")
