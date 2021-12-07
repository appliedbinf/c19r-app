
#' close_connections
#' Close any hung DBI connections
#' @export
#'
close_connections <- function() {
  current_conns <- DBI::dbListConnections(RMySQL::MySQL())
  for (conn in current_conns) {
    DBI::dbDisconnect(conn)
  }
}
