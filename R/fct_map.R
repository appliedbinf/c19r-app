#' map 
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
pcrit <- function(x) {
    0.01 / x
}

#' Title
#'
#' @param I 
#' @param n 
#' @param USpop 
#' @param scaling_factor 
#'
#' @return
#' @export
#'
#' @examples
calc_risk <- function(I, n, USpop, scaling_factor=10/14) {
    p_I <- (I / USpop) * scaling_factor
    r <- 1 - (1 - p_I)**n
    round(100 * r, 1)
}

#' Title
#'
#' @param x 
#' @param nice 
#'
#' @return
#' @export
#'
#' @examples
roundUpNice <- function(x, nice = c(1, 2, 4, 5, 6, 8, 10)) {
    if (length(x) != 1) stop("'x' must be of length 1")
    10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
}

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
riskParams = function(val) {
    dplyr::case_when(val < 1 ~ "Not enough data",
                     val > 99 ~ "> 99%",
                     TRUE ~ as.character(glue::glue("{val}%")))
}
