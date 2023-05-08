#' @importFrom rlang :=
NULL

#' usa_risk_map UI Function
#'
#' @description US risk map tab.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_usa_risk_map_ui <- function(id) {
  ns <- NS(id)
  tabPanel(
    value = "usa",
    title = "USA Risk estimates by county",
    fluid = TRUE, 
    shinypanels::panelsPage(fluidRow(
      shinypanels::panel(
        title = "USA Risk estimates by county",
        can_collapse = F,
        class = "col-sm-12 col-xs-12 col-md-3 well fake-sidebar",
        body = div(
          # style="font-size: larger;",
          sidebar_text(geo_specific = "a county"),
          shinyWidgets::sliderTextInput(
            ns("event_size_map"),
            "Event Size: ",
            choices = event_size,
            selected = 50,
            grid = T
          ),
          shinyWidgets::awesomeRadio(
            inputId = ns("asc_bias"),
            label = "Select Ascertainment Bias",
            choices = c("3", "4", "5"),
            selected = "4",
            status = "warning",
            inline = T
          ),
          shinyWidgets::awesomeRadio(
            inputId = ns("imm_lvl"),
            label = "Focus on counties with immunity via full vaccination less than:",
            choices = c(
              "Off" = 0,
              "45%" = 45,
              "50%" = 50,
              "60%" = 60,
              "65%" = 65
            ),
            selected = 0,
            status = "warning",
            inline = T,
          ),
          mod_show_data_ui("to_data"),
          HTML(
            paste0(
              "</br><a data-toggle='collapse' href='#learnmore' role='button' aria-expanded='false' aria-controls='learnmore'>",
              "Learn about ascertainment bias and vaccination levels",
              "</a>",
              "<div class='collapse' id='learnmore'>",
              "Based on seroprevalence data and increases in testing, by default we assume there are four times more cases than are being reported (4:1 ascertainment bias). In places with less testing availability, that bias may be higher. We are evaluating the inclusion of lower ascertainment biases based on increased testing.",
              "<br/><br/>",
              "Higher vaccination levels reduce the risk that exposure to COVID-19 will lead to severe disease and  onward transmission. We show an optional layer representing county-level population immunity via vaccination (allowing for two weeks for individuals completing a vaccination series).",
              "</div>"
            )
          )
        )
      ),
      shinypanels::panel(
        class = "col-md-6",
        title = "",
        can_collapse = FALSE,
        body = div(
          div(
            role="alert",
            p("We have stopped updating the data for this application due to reporting changes and declining test volumes. Soon you'll be able to explore Covid's ebb and flow over time, but for now the data is frozen at December, 27, 2022",
              class="alert alert-warning font-weight-bold",
              style = "font-size:1.5em"
            )
          ),
          leaflet::leafletOutput(outputId = ns("usa_map"), height = "70vh"),
          HTML(
            "<p>(Note: This map uses a Web Mercator projection that inflates the area of states in northern latitudes. County boundaries are generalized for faster drawing.)</p>"
          )
        )
      ),
      shinypanels::panel(
         class = "col-sm-12 col-md-2 hidden-sm hidden-xs",
         body = div(
           class = "",
           htmlOutput(ns("risk_context_us")),
           fluidRow(
             align = "center",
             column(
               12,
               HTML(
                 "<h3>Can you guess the risk levels in YOUR community?  Try the Risk Quiz and share your score!</h3>"
               ),
             )
           ),
           fluidRow(
             align = "center",
             column(
               12,
               mod_take_quiz_button_ui("to_quiz_map")
             )
           ),
           fluidRow(
             align = "center",
             column(
               12,
               div(
                 div(style = "height: 10px;"),
                 div(
                   class = "well fake-sidebar",
                   HTML(
                     "<p class='intro-text'><a href='https://duke.qualtrics.com/jfe/form/SV_0SZR4fPxyUAg9Ke', rel='noopener' target='_blank'>Fill out this 5-minute survey</a> for a chance to win a $50 Amazon gift card!</p>"
                   )
                 )
               )
             )
           )
         ),
         title = "Risk context",
         collapsed = F
       )
    ))
  )
}

#' usa_risk_map Server Functions
#'
#' @noRd
mod_usa_risk_map_server <- function(id, globals) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    output$risk_context_us <- renderUI({
      div(p(
        glue::glue(
          "You're viewing risk levels for an event with {input$event_size_map} people, which is like:"
        ),
        HTML("<br/>", risk_text[as.character(input$event_size_map)]),
        class = "context-header"
      ))
    })


    w <- waiter::Waiter$new(id = ns("usa_map"), 
                            html = tagList(waiter::spin_wave(),
                                          h4("Loading risk map...")),
                            color = "#D6DBDF")
    output$usa_map <- leaflet::renderLeaflet({
      w$show()
      risk_data <- usa_counties %>%
        dplyr::select(
          GEOID,
          NAME,
          stname,
          pct_fully_vacc,
          updated,
          risk = "4_50",
          imOp,
          geometry
        ) %>%
        dplyr::mutate(
          imOp = 0.0,
          polyid = paste0("id", GEOID),
          imid = paste0("im", GEOID)
        )

      basemap <- leaflet::leaflet(options = leaflet::leafletOptions(worldCopyJump = F, preferCanvas = TRUE)) %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron) %>%
        # Center on US
        leaflet::setView(
          lat = 37.1,
          lng = -95.7,
          zoom = 4
        ) %>%
        # Add state boundaries
        leaflet::addPolygons(
          layerId = ~stateline,
          data = stateline,
          fill = FALSE, color = "#943b29", weight = 1, smoothFactor = 0.5,
          opacity = 1.0
        ) %>%
        # Add county geoms
        leaflet::addPolygons(
          layerId = ~polyid, # id of geom that will be used by js functions
          data = risk_data,
          color = "#444444",
          weight = 0.2,
          smoothFactor = 0.1,
          highlight = leaflet::highlightOptions(weight = 1),
        ) %>%
        # Add vaccine immunity geoms
        leaflet::addPolygons(
          layerId = ~imid, # id of geom that will be used by js functions
          data = risk_data,
          weight = 0,
          smoothFactor = 0.1,
        ) %>%
        # Add custom legend
        leaflet::addLegend(
          data = risk_data,
          position = "topright",
          pal = pal,
          values = ~risk,
          title = "Risk Level (%)",
          opacity = .7,
          labFormat = function(type, cuts, p) {
            paste0(legendlabs)
          }
        ) %>%
        # Add geolocate easy button
        leaflet::addEasyButton(leaflet::easyButton(
          icon = "fa-crosshairs fa-lg",
          title = "Locate Me",
          onClick = leaflet::JS(
            "function(btn, map){ map.locate({setView: true, maxZoom: 7});}"
          )
        ))
    })

    map_obs <- reactive(list(input$event_size_map, input$asc_bias, input$imm_lvl))

    observeEvent(map_obs(), {
      risk_data <- usa_counties %>%
        dplyr::select(
          GEOID,
          NAME,
          stname,
          pct_fully_vacc,
          updated,
          risk := glue::glue("{input$asc_bias}_{input$event_size_map}"),
          imOp,
          geometry
        ) %>%
        dplyr::mutate(
          imOp = dplyr::case_when(
            input$imm_lvl == 0 ~ 0.0,
            pct_fully_vacc < input$imm_lvl ~ 0.0,
            pct_fully_vacc > input$imm_lvl ~ 0.7,
            TRUE ~ 0.0
          ),
          polyid = paste0("id", GEOID),
          imid = paste0("im", GEOID)
        )

      leaflet::leafletProxy("usa_map", data = risk_data) %>%
        setShapeStyle(layerId = ~polyid, fillColor = pal(risk_data$risk), color = "#444444", fillOpacity = 0.7, ) %>%
        setShapeStyle(layerId = ~imid, fillColor = "white", fillOpacity = ~imOp, ) %>%
        setShapeLabel(layerId = ~imid, label = maplabs(risk_data))
    })
  })
}

## To be copied in the UI
# mod_usa_risk_map_ui("usa_risk_map_ui_1")

## To be copied in the server
# mod_usa_risk_map_server("usa_risk_map_ui_1")
