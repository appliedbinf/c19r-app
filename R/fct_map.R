#' pcrit
#'
#' @param x Adjustment factor
#'
#' @return Adjusted p-value
#'
#' @examples
#' \dontrun{
#' pcrit(c(10,100,1000))
#' pcrit("ten")
#' }
pcrit <- function(x) {
  0.01 / x
}

#' calc_risk
#'
#' @param I Infection rate
#' @param n Event size
#' @param population Size of population to predict in
#' @param scaling_factor Scaling factor, for averaging noisy case data
#'
#' @return Vector of risk values
#'
calc_risk <- function(I, n, population, scaling_factor = 10 / 14) {
  p_I <- (I / population) * scaling_factor
  r <- 1 - (1 - p_I)**n
  round(100 * r, 1)
}

#' roundUpNice
#'
#' @param x Number to round
#' @param nice log10 ingrements to try to round to nearest
#'
#' @return Rounded number
#' @examples 
#' \dontrun{
#' roundUpNice(124207)
#' }
roundUpNice <- function(x, nice = c(1, 2, 4, 5, 6, 8, 10)) {
  if (length(x) != 1) stop("'x' must be of length 1")
  10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
}

#' maplabs
#'
#' @param riskData Risk data df given to [leaflet::addPolygons()]
#'
#' @return [htmltools::HTML] vector of map labels to user
#'
maplabs <- function(riskData) {
  riskData <- riskData %>%
    dplyr::mutate(risk = dplyr::case_when(
      risk == 100 ~ "> 99",
      risk == 0 ~ "No data",
      risk < 1 ~ "< 1",
      is.na(risk) ~ "No data",
      TRUE ~ as.character(risk)
    ))
  labels <- paste0(
    "<strong>", paste0(riskData$NAME, ", ", riskData$stname), "</strong><br/>",
    "Current Risk Level: <b>", riskData$risk, ifelse(riskData$risk == "No data", "", "&#37;"), "</b><br/>",
    "Immunity via vaccination: <strong>", round(riskData$pct_fully_vacc, 1), "%</strong></b><br/>",
    "Updated: ", riskData$updated,
    ""
  ) %>% lapply(htmltools::HTML)
  return(labels)
}

#' riskParams
#'
#' @param val Risk parameter to format
#'
#' @return Formated risk paramter
#'
riskParams <- function(val) {
  dplyr::case_when(
    val < 1 ~ "Not enough data",
    val > 99 ~ "> 99%",
    TRUE ~ as.character(glue::glue("{val}%"))
  )
}

#' Generate sidebar text
#'
#' @param geo_specific String for geospecific region description
#'
#' @return HTML for sidebar
#' @export
#'
sidebar_text <- function(geo_specific = "a county") {
  
  return(
    HTML(
      paste0(
        "<style>.icon-grid{display: grid; grid-gap: 10px; grid-template-columns: repeat(3, minmax(50px, 90px)); align-items: center; justify-content: space-evenly;} .icon-grid img{width: 100%;}</style>",
        "<div>This map shows the risk level of attending an event, given the event size and location.  ",
        "</br>",
        "The risk level is the estimated chance (0-100%) that at least 1 COVID-19 positive individual will be present at an event in ",
        geo_specific, 
        ", given the size of the event.</div>",
        "</br>",
        "<div>Reduce the risk that one case becomes many and: </div>",
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
    )
  )
  
}
