#' feedback 
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
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
    
    query <- sqlInterpolate(ANSI(), gsub("\\n\\w+", " ", sql),
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
    dbSendQuery(db, query)
    
}

str_or_unk <- function(obj){
    if(is.null(obj)){
        "Unknown"
    } else {
        obj
    }
}

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