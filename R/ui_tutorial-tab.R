#' tutorial_tab
#'
#' @return
#' @export
#'
#' @examples
tutorial_tab <- function() {
  tabPanel(
    id = "tuts",
    "Tutorial",
    fluid = TRUE,
    mainPanel(includeMarkdown(app_sys("Tutorial.md")))
  )
}
