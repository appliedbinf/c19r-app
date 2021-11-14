#' shiny 
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
disconnected <- sever::sever_default(title = "Session disconnected",
                              subtitle = "Your session disconnected for some reason :(",
                              button = "Reconnect",
                              button_class = "warning"
)
timeout <- sever::sever_default(title = "Session timeout reached",
                         subtitle = "Your session ended due to inactivity",
                         button = "Reconnect",
                         button_class = "warning"
)

#' Title
#'
#' @return
#' @export
#'
#' @examples
get_data <- function() {
    current_fh <- tail(list.files(app_sys("states_current/"), full.names = TRUE), 1)
    state_data <<- read.csv(current_fh, stringsAsFactors = F)
    states <<- unique(state_data$state)
    current_time <<- daily_time <<- Sys.Date()
    cur_date <- lubridate::ymd(Sys.Date()) - 1
    past_date <- lubridate::ymd(cur_date) - 14
    states_current <<- subset(state_data, lubridate::ymd(date) == cur_date) %>% dplyr::arrange(state)
    states_historic <<- subset(state_data, lubridate::ymd(date) == past_date) %>% dplyr::arrange(state)
    state_pops <<- vroom::vroom(app_sys("map_data/state_pops.tsv"))
    state_data <<- states_current %>%
        dplyr::select(state, cases) %>%
        dplyr::arrange(state)
    state_data$C_i <<- round((states_current$cases - states_historic$cases) * 10 / 14)
    state_data$state <<- name2abbr[state_data$state]
    state_data <<- state_data %>% tidyr::drop_na()
    usa_counties <<- vroom::vroom(app_sys("app/www/usa_risk_counties.csv")) %>%
        dplyr::select(-NAME, -stname) %>%
        dplyr::mutate_at(dplyr::vars(-GEOID, -state, -updated), as.numeric)
    usa_counties <<- county_geom %>% dplyr::left_join(usa_counties, by = c("GEOID" = "GEOID"))
}