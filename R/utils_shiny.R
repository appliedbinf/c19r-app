
#' Function to run on app start
#'
#' @return
#' @export
#'
loadDataOnStart <- function() {
  db <<- connect_to_db(db = "c19r")
  county_geom <<- sf::st_read(app_sys("map_data/geomUnitedStates.geojson"))
  stateline <<- sf::st_read(app_sys("map_data/US_stateLines.geojson"))[, c("STUSPS", "NAME", "geometry")]
  names(stateline) <<- c("stname", "name", "geometry")
  get_data()
}


#' shiny
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
disconnected <- sever::sever_default(
  title = "Session disconnected",
  subtitle = "Your session disconnected for some reason :(",
  button = "Reconnect",
  button_class = "warning"
)
timeout <- sever::sever_default(
  title = "Session timeout reached",
  subtitle = "Your session ended due to inactivity",
  button = "Reconnect",
  button_class = "warning"
)

#' Get data needed for app to function
#'
#' While this function has no arguments, there are
#' environment variables that are import to its functioning
#'
#' C19R_CASES_DIR Alternative path to NYT COVID19 case data
#' C19R_RISK_DATA Alternative path to pre-computed risk data
#' C19R_EXTERNAL_UPDATES Prevent app from update NYT case data
#'
#' @return
#' @export
#'
get_data <- function() {
  TZ <<- "America/New_York"

  DEFAULT_RISK_DATA <- app_sys("app/www/usa_risk_counties.csv")
  RISK_DATA <- Sys.getenv("C19R_RISK_DATA", DEFAULT_RISK_DATA)

  if (!file.exists(RISK_DATA)) {
    stop(
      glue::glue(
        "The pre-computed risk data does not exist at the given path",
        "\n{RISK_DATA}"
      )
    )
  }
  
  DEFAULT_CASES_DIR <- app_sys("states_current/")
  CASES_DIR <- Sys.getenv("C19R_CASES_DIR", DEFAULT_CASES_DIR)
  
  if (!dir.exists(CASES_DIR)) {
    stop(
      glue::glue(
        "The current cases directory does not exist",
        "\n{CASES_DIR}"
      )
    )
  }
  
  # If EXTERNAL_UPDATES is TRUE, do not download new data file using Shiny
  EXTERNAL_UPDATES <- Sys.getenv("C19R_EXTERNAL_UPDATES", FALSE)

  if (EXTERNAL_UPDATES != FALSE &
      EXTERNAL_UPDATES %in% c("true", "TRUE", "1")
      )
    EXTERNAL_UPDATES <- TRUE


  current_fh <- tail(list.files(CASES_DIR, full.names = TRUE, pattern = "*.csv"), 1)
  
  if (is.na(current_fh)){
    current_ts <<- lubridate::now(tzone = TZ) - lubridate::hours(2.5)
  } else {
    ts_str <- gsub(".csv", "", basename(current_fh), fixed = T)
    current_ts <<- lubridate::ymd_hms(ts_str)
  }
  
  
  max_offset <<- lubridate::hours(2)
  if (isTRUE(EXTERNAL_UPDATES) &
      lubridate::force_tz(current_ts, TZ) + max_offset < lubridate::now(tzone = TZ)
      ) {
    url <- "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv"
    new_fh_base <- lubridate::now(tzone = TZ) %>% format("%Y%m%d_%H%M%S")
    new_fh <- glue::glue("{dirname(current_fh)}/{new_fh_base}.csv")
    utils::download.file(url = url, destfile = new_fh)
    unlink(current_fh)
    current_fh <- new_fh
  }
  state_data <<- vroom::vroom(current_fh)
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
  usa_counties <<- vroom::vroom(RISK_DATA) %>%
    dplyr::select(-NAME, -stname) %>%
    dplyr::mutate_at(dplyr::vars(-GEOID, -state, -updated), as.numeric)
  usa_counties <<- county_geom %>% dplyr::left_join(usa_counties, by = c("GEOID" = "GEOID"))

}
