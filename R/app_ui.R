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
    selected = "usa",
    collapsible = TRUE,
    id = "nav-page",
    windowTitle = "COVID-19 Event Risk Assessment Planning Tool",
    title = "COVID-19 Event Risk Tool",
    header = NAVPAGE_HEADER,
    footer = NAVPAGE_FOOTER,
    mod_usa_risk_map_ui("usa_risk_map"),
    tutorial_tab(),
    about_tabset(),
    bslib::nav_item(HTML(
    "<a href=\"https://twitter.com/covid19riskusa\" target=_blank style=\"font-size:24px; display: inline-block;\"><i class=\"fa fa-twitter-square\"></i></a>&nbsp;<a href=\"https://www.instagram.com/covid19riskusa/\" target=_blank style=\"font-size:24px; display: inline-block;\"><i class=\"fa fa-instagram\"></i></a>&nbsp;<a href=\"https://www.facebook.com/covid19riskusa\" target=_blank style=\"font-size:24px; display: inline-block;\"><i class=\"fa fa-facebook-square\"></i></a>'"
    ))
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
golem_add_external_resources <- function() {
  add_resource_path(
    "www", app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "covid19RiskPlanner"
    ),
    shinyjs::useShinyjs(),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
