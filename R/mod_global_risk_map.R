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
        sidebar_text(geo_specific = "a region"),
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
        leaflet::leafletOutput(outputId = ns("global_map"), height = "70vh"),
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
    combined_labels <- function(riskData) {
      riskData <- riskData %>%
        dplyr::mutate(risk = dplyr::case_when(
          risk == 100 ~ "> 99",
          risk == 0 ~ "< 1",
          is.na(risk) ~ "No data",
          TRUE ~ as.character(risk)
        ))
      labels <- paste0(
        "<strong>", paste0(riskData$name, ", ", riskData$country), "</strong><br/>",
        "Current Risk Level: <b>", riskData$risk, ifelse(riskData$risk == "No data", "", "&#37;"), "</b><br/>",
        "Latest Update: ", substr(riskData$date, 1, 10)
      ) %>% lapply(htmltools::HTML)
      return(labels)
    }
    
    ns <- session$ns
    w <- waiter::Waiter$new(id = ns("global_map"), 
                            html = tagList(waiter::spin_wave(),
                                           h4("Loading risk map...")),
                            color = "#D6DBDF")
    output$global_map <- leaflet::renderLeaflet({
      w$show()
    risk_data <- eu_regions %>%
        dplyr::select(
          code,
          name,
          country,
          updated,
          risk = "3_50",
          geometry
        ) %>%
        dplyr::mutate(
          polyid = paste0("gid", dplyr::row_number())
        )
      
      basemap <- leaflet::leaflet(options = leaflet::leafletOptions(worldCopyJump = F, preferCanvas = TRUE)) %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron) %>%
        # Center on US
        leaflet::setView(
          lat = 48.6, lng = 7.17, zoom = 3
        ) %>%
        # Add county geoms
        leaflet::addPolygons(
          layerId = ~polyid, # id of geom that will be used by js functions
          data = risk_data,
          color = "#444444",
          weight = 0.2,
          smoothFactor = 0.1
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
    
    map_obs <- reactive(list(input$global_event_size_map, input$global_asc_bias))
    
    observeEvent(map_obs(), {
      risk_data <- eu_regions %>%
        dplyr::select(
          code,
          name,
          country,
          updated,
          risk := glue::glue("{input$global_asc_bias}_{input$global_event_size_map}"),
          geometry
        ) %>%
        dplyr::mutate(
          polyid = paste0("gid", dplyr::row_number())
        )
       
      leaflet::leafletProxy("global_map", data = risk_data) %>%
        setShapeStyle(layerId = ~polyid, fillColor = pal(risk_data$risk), color = "#444444", fillOpacity = 0.7, ) %>%
        setShapeLabel(layerId = ~polyid, label = combined_labels(risk_data))
    })
  })
}

## To be copied in the UI
# mod_global_risk_map_ui("global_risk_map_ui_1")

## To be copied in the server
# mod_global_risk_map_server("global_risk_map_ui_1")
