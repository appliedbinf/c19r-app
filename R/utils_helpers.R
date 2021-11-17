#' pcrit
#'
#' @param x Population size (int)
#'
#' @description Compute the scaled critical p-value
#'
#' @return Scaled p-value
#'
#' @noRd
pcrit <- function(x) {
  0.01 / x
}


#' calc_risk
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
calc_risk <- function(I, n, USpop, scaling_factor = 10 / 14) {
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
#' @param obj
#'
#' @return
#' @export
#'
#' @examples
str_or_unk <- function(obj) {
  if (is.null(obj)) {
    return("Unknown")
  } else {
    return(obj)
  }
}

#' Title
#'
#' @param input
#' @param label
#'
#' @return
#' @export
#'
#' @examples
make_resp_slider <- function(input, label) {
  sliderInput(
    inputId = input,
    label = label,
    min = 0,
    max = 100,
    step = 1,
    value = 50,
    post = "%",
    width = "100%"
  )
}


close_connections <- function() {
  current_conns <- DBI::dbListConnections(RMySQL::MySQL())
  for (conn in current_conns) {
    DBI::dbDisconnect(conn)
  }
}
