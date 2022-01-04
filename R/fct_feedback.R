
#' connect_to_db
#'
#' @param drv DBI-compatible database driver
#' @param username login username
#' @param password login password
#' @param host database hostname or IP
#' @param port database port
#' @param dbname name of database/table to use
#' @param ... Additional `{poo::dbPool}` options
#'
#' @description Connect to database and return pool object
#'
#' @return `pool::dbPool` obj`
#'
#' @examples
#' \dontrun{
#' connect_to_db(drv = RMySQL::MySQL(), username = "root", password = "root")
#' }
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

#' save_willingness
#'
#' @param db Database or pool object
#' @param source Where is willingness being be asked, e.g. "game" or "map"
#' @param asc_bias Ascertainment bias when asked on map, set to -1 for other uses
#' @param event_size Event size when asked on map, set to -1 for other uses
#' @param answer Willingness answer, should come from the willingness scale
#' @param ip User ip if known, typically from `globals$ip()``
#' @param vacc_imm Vaccine immunity overlay setting if from map
#' @param latitude User latitude, 0 if unknown.  Typically from `globals$latitude()`
#' @param longitude User longitude, 0 if unknown.  Typically from `globals$longitude()`
#' @param utm_source `utm_source=` value from query string or 'NULL'
#' @param utm_medium `utm_medium=` value from query string or 'NULL'
#' @param utm_content `utm_content=` value from query string or 'NULL'
#' @param utm_campaign `utm_campaign=` value from query string or 'NULL'
#'
#' @description Save user willingness input from prompts on maps and quiz tab
#'
#'
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

#' str_or_unk
#'
#' @param obj object to voncert
#'
#' @description Convert null objects to "Unknown"
#'
#' @return converted object
#' 
#' @examples
#'\dontrun{
#'  str_or_unk(NULL)
#'  str_or_unk("example")
#'}
str_or_unk <- function(obj) {
  if (is.null(obj)) {
    "Unknown"
  } else {
    obj
  }
}

#' make_resp_slider
#'
#' @param input `{shiny}` input id
#' @param label label for input
#'
#' @description Create slider inputs for Risk Quik, range from 0-100%
#'
#' @return Slider input
#'
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
