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
#' @param obj 
#'
#' @return
#' @export
#'
#' @examples
str_or_unk <- function(obj){
    if(is.null(obj)){
        "Unknown"
    } else {
        obj
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
make_resp_slider = function(input, label) {
    sliderInput(
        inputId = input,
        label = label,
        min = 0,
        max = 100,
        step = 1,
        value = 50,
        post = "%",
        width = '100%'
    )
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


#' Title
#'
#' @param source 
#' @param asc_bias 
#' @param event_size 
#' @param answer 
#' @param ip 
#' @param vacc_imm 
#' @param latitude 
#' @param longitude 
#' @param utm_source 
#' @param utm_medium 
#' @param utm_content 
#' @param utm_campaign 
#'
#' @return
#' @export
#'
#' @examples
save_willingness <- function(source,
                             asc_bias,
                             event_size,
                             answer,
                             ip,
                             vacc_imm,
                             latitude,
                             longitude,
                             utm_source = "NULL", 
                             utm_medium = "NULL",
                             utm_content = "NULL", 
                             utm_campaign = "NULL") {
    
    
    sql <- "INSERT INTO willingness 
                (source, asc_bias, event_size, answer, 
                ip, vacc_imm, latitude, longitude, 
                utm_source, utm_medium, utm_content, 
                utm_campaign)
            VALUES 
                (?source, ?asc_bias, ?event_size, ?answer,
                ?ip, ?vacc_imm, ?latitude, ?longitude,
                NULLIF(?utm_source, 'NULL'), NULLIF(?utm_medium, 'NULL'), 
                NULLIF(?utm_content, 'NULL'), NULLIF(?utm_campaign, 'NULL'))
    "
    
    query <- DBI::sqlInterpolate(DBI::ANSI(), gsub("\\n\\w+", " ", sql),
                            source = source,
                            asc_bias = asc_bias,
                            event_size = event_size,
                            answer = answer,
                            ip = ip,
                            vacc_imm = vacc_imm,
                            latitude = str_or_unk(latitude),
                            longitude = str_or_unk(longitude),
                            utm_source = utm_source, 
                            utm_medium = utm_source,
                            utm_content = utm_source, 
                            utm_campaign = utm_source
    )
    DBI::dbSendQuery(db, query)
    
}
