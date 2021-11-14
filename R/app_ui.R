#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' 
#' @noRd
app_ui <- function(request) {
  navbarPage(
    golem_add_external_resources(),
    theme = shinythemes::shinytheme("sandstone"),
    shinyjs::useShinyjs(),
    sever::use_sever(),
    selected = "usa",
    collapsible = TRUE,
    id = "nav-page",
    windowTitle = "COVID-19 Event Risk Assessment Planning Tool",
    title = "COVID-19 Event Risk Assessment Planning Tool",
    header = NAVPAGE_HEADER,
    footer = NAVPAGE_FOOTER,
    mod_usa_risk_map_ui("usa_risk_map"),
    mod_risk_quiz_ui("quiz"),
    mod_global_risk_map_ui("global_risk_map_ui_1"),
    mod_usa_real_time_ui("usa_real_time"),
    tutorial_tab(),
    about_tabset()
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'covid19RiskPlanner'
    ),
    shinyjs::useShinyjs(),
    sever::use_sever()
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

