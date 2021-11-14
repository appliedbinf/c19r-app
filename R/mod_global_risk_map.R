#' global_risk_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_global_risk_map_ui <- function(id){
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
            "<p>This map shows the risk level of attending events of different sizes at within-country resolution.",
            "<br/><br/>You can reduce the risk that one case becomes many by wearing a mask, distancing, and gathering outdoors in smaller groups. For vaccinated individuals, preventative steps can reduce the risk of breakthrough infections that spread to vulnerable individuals. For unvaccinated individuals, preventative steps before vaccination can reduce the risk of breakthrough disease, including potentially severe cases, hospitalizations, and fatalities.<br/><br/>",
            "The risk level is the estimated chance (0-100%) that at least 1 COVID-19 positive individual will be present at an event in a NUTS-3 level area (County, Local Authority, Council, District), given the size of the event.",
            "<br/><br/>", "Based on seroprevalence data and increases in testing, by default we assume there are five times more cases than are being reported (5:1 ascertainment bias). In places with less testing availability, that bias may be higher. We are evaluating the inclusion of lower ascertainment biases based on increased testing.",
            "<br/><br/>",
            "Choose an event size and ascertainment bias below.</p>"
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
          choices = c("3", "5"),
          selected = "5",
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
          align="center",
          column(10,
                 mod_switch_maps_ui("switcher_global", label = "Explore USA risk estimates")
          ))
      )
    )
  )
}
    
#' global_risk_map Server Functions
#'
#' @noRd 
mod_global_risk_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    observeEvent(input$global_event_size_map, {
      output$eu_map_static <- renderUI({
        tags$iframe(
          src = paste0("https://covid19risk.biosci.gatech.edu/", "eu_", input$global_asc_bias, "_", input$global_event_size_map, ".html"),
          style="position: relative; height: 60vh; width: -moz-available; width: -webkit-fill-available;  width: fill-available; max-width: 992px; max-height: 500px; min-height: 350px; align: center", frameBorder = "0"
        )
      })
    })
    
    observeEvent(input$global_asc_bias, {
      output$eu_map_static <- renderUI({
        tags$iframe(
          src = paste0("https://covid19risk.biosci.gatech.edu/", "eu_", input$global_asc_bias, "_", input$global_event_size_map, ".html"),
          style="position: relative; height: 60vh; width: 95vw; max-width: 992px; max-height: 500px; min-height: 350px; align: center", frameBorder = "0"
        )
      })
    })
  })
}
    
## To be copied in the UI
# mod_global_risk_map_ui("global_risk_map_ui_1")
    
## To be copied in the server
# mod_global_risk_map_server("global_risk_map_ui_1")
