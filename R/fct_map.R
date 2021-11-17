#' Title
#'
#' @param riskData
#'
#' @return
#' @export
#'
#' @examples
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
    "State-level immunity via vaccination: <strong>", round(riskData$pct_fully_vacc, 1), "%</strong></b><br/>",
    "Updated: ", riskData$updated,
    ""
  ) %>% lapply(htmltools::HTML)
  return(labels)
}

#' Title
#'
#' @param val
#'
#' @return
#' @export
#'
#' @examples
riskParams <- function(val) {
  dplyr::case_when(
    val < 1 ~ "Not enough data",
    val > 99 ~ "> 99%",
    TRUE ~ as.character(glue::glue("{val}%"))
  )
}
