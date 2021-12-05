#' pcrit
#'
#' @param x Adjustment factor
#'
#' @return Adjusted p-value
#'
#' @examples
#' pcrit(c(10,100,1000))
#' \dontrun{
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
#' roundUpNice(124207)
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
