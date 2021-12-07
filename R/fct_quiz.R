#' build_results_table
#'
#' @param state State selection from dropdown
#' @param county County selection from dropdown
#' @param ans_20 User answer for the event size = 20 slider
#' @param ans_50 User answer for the event size = 50 slider 
#' @param ans_100 User answer for the event size = 100 slider
#' @param ans_1000 User answer for the event size = 1000 slider
#'
#'
build_results_table <- function(state, county, ans_20, 
                                ans_50, ans_100, ans_1000) {
  if (state == "USA") {
    USpop <- 331 * 10^6
    C_i <- sum(as.numeric(state_data$C_i))
    quiz_nvec <- c(20, 50, 100, 1000)
    pred_risk <- as.data.frame(
      as.list(calc_risk(C_i, quiz_nvec, USpop)),
      col.names = c("pred_20", "pred_50", "pred_100", "pred_1000"),
      row.names = NULL
    ) %>%
      dplyr::mutate(
        GEOID = "0",
        data_ts = usa_counties %>% dplyr::pull(updated) %>% dplyr::first()
      )
  } else {
    pred_risk <- usa_counties %>%
      dplyr::filter(stname == state, NAME == county) %>%
      sf::st_drop_geometry() %>%
      dplyr::select(
        GEOID,
        data_ts = updated,
        pred_20 = "4_20",
        pred_50 = "4_50",
        pred_100 = "4_100",
        pred_1000 = "4_1000"
      )
  }

  pred_risk %>%
    dplyr::mutate(
      g_20 = ans_20,
      g_50 = ans_50,
      g_100 = ans_100,
      g_1000 = ans_1000
    ) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      diff_20 = pred_20 - g_20,
      diff_50 = pred_50 - g_50,
      diff_100 = pred_100 - g_100,
      diff_1000 = pred_1000 - g_1000
    )
}

#' save_quiz_results
#'
#' @param db Database, from global env (see [loadDataOnStart()])
#' @param geoid Geoid of location selected
#' @param data_ts Timestamp of quiz submission
#' @param p20 Predicted event size = 20
#' @param p50 Predicted event size = 50
#' @param p100 Predicted event size = 100
#' @param p1000 Predicted event size = 1000
#' @param g20 Guess event size = 20
#' @param g50 Guess event size = 50
#' @param g100 Guess event size = 100
#' @param g1000 Guess event size = 1000
#' @param ip User ip if known, from `globals$ip()`
#' @param lat User latitude, 0 if unknown.  Typically from `globals$latitude()`
#' @param long User longitude, 0 if unknown.  Typically from `globals$longitude()`
#' @param utm_source `utm_source=` value from query string or 'NULL'
#' @param utm_medium `utm_medium=` value from query string or 'NULL'
#' @param utm_content `utm_content=` value from query string or 'NULL'
#' @param utm_campaign `utm_campaign=` value from query string or 'NULL'
#'
#'
save_quiz_results <- function(db,
                              geoid,
                              data_ts,
                              p20,
                              p50,
                              p100,
                              p1000,
                              g20,
                              g50,
                              g100,
                              g1000,
                              ip,
                              lat,
                              long,
                              utm_source,
                              utm_medium,
                              utm_content,
                              utm_campaign) {
  sql <-
    "INSERT INTO risk_game_results
        (
          GEOID, data_ts, pred_20, pred_50,
          pred_100, pred_1000, g_20, g_50,
          g_100, g_1000, ip, latitude,
          longitude, utm_source, utm_medium,
          utm_content, utm_campaign
        )
        VALUES (?geoid, ?data_ts, ?p20,
                ?p50, ?p100, ?p1000, ?g20,
                ?g50, ?g100, ?g1000, ?ip,
                ?lat, ?long, NULLIF(?utm_source, 'NULL'),
                NULLIF(?utm_medium, 'NULL'),
                NULLIF(?utm_content, 'NULL'),
                NULLIF(?utm_campaign, 'NULL')
        )"

  query <-
    DBI::sqlInterpolate(
      DBI::ANSI(),
      gsub("\\n\\w+", " ", sql),
      geoid = geoid,
      data_ts = data_ts,
      p20 = p20,
      p50 = p50,
      p100 = p100,
      p1000 = p1000,
      g20 = g20,
      g50 = g50,
      g100 = g100,
      g1000 = g1000,
      ip = ip,
      lat = lat,
      long = long,
      utm_source = utm_source,
      utm_medium = utm_medium,
      utm_content = utm_content,
      utm_campaign = utm_campaign
    )
  conn <- pool::poolCheckout(db)
  DBI::dbSendQuery(conn, query)
  pool::poolReturn(conn)
}
