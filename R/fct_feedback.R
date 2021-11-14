
#' Title
#'
#' @param drv
#' @param username
#' @param password
#' @param host
#' @param port
#' @param dbname
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
connect_to_db <- function(drv = RMySQL::MySQL(),
                          username = Sys.getenv("MYSQL_USERNAME"),
                          password = Sys.getenv("MYSQL_PASSWORD"),
                          host = Sys.getenv("MYSQL_HOST"),
                          port = 3306,
                          dbname,
                          ...) {
  pool::dbPool(
    drv      = drv,
    username = username,
    password = password,
    host     = host,
    port     = port,
    dbname   = dbname,
    ...
  )
}

#' feedback
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
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
save_willingness <- function(db,
                             source,
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
    latitude = ifelse(is.null(latitude), "Unknown", latitude),
    longitude = ifelse(is.null(longitude), "Unknown", longitude),
    utm_source = utm_source,
    utm_medium = utm_medium,
    utm_content = utm_content,
    utm_campaign = utm_campaign
  )
  conn <- pool::poolCheckout(db)
  DBI::dbSendQuery(conn, query)
  pool::poolReturn(conn)
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
