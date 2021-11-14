### R functions
# add in methods from https://github.com/rstudio/leaflet/pull/598
#' Title
#'
#' @param map
#' @param layerId
#' @param radius
#' @param data
#'
#' @return
#' @export
#'
#' @examples
setCircleMarkerRadius <- function(map, layerId, radius, data = leaflet::getMapData(map)) {
  options <- list(layerId = layerId, radius = radius)
  # evaluate all options
  options <- leaflet::evalFormula(options, data = data)
  # make them the same length (by building a data.frame)
  options <- do.call(data.frame, c(options, list(stringsAsFactors = FALSE)))
  leaflet::invokeMethod(map, data, "setRadius", options$layerId, options$radius)
}

#' Title
#'
#' @param map
#' @param layerId
#' @param radius
#' @param stroke
#' @param color
#' @param weight
#' @param opacity
#' @param fill
#' @param fillColor
#' @param fillOpacity
#' @param dashArray
#' @param options
#' @param data
#'
#' @return
#' @export
#'
#' @examples
setCircleMarkerStyle <- function(map, layerId,
                                 radius = NULL,
                                 stroke = NULL,
                                 color = NULL,
                                 weight = NULL,
                                 opacity = NULL,
                                 fill = NULL,
                                 fillColor = NULL,
                                 fillOpacity = NULL,
                                 dashArray = NULL,
                                 options = NULL,
                                 data = leaflet::getMapData(map)) {
  if (!is.null(radius)) {
    setCircleMarkerRadius(map, layerId = layerId, radius = radius, data = data)
  }

  options <- c(
    list(layerId = layerId),
    options,
    leaflet::filterNULL(list(
      stroke = stroke, color = color,
      weight = weight, opacity = opacity,
      fill = fill, fillColor = fillColor,
      fillOpacity = fillOpacity, dashArray = dashArray
    ))
  )

  if (length(options) < 2) { # no style options set
    return()
  }
  # evaluate all options
  options <- leaflet::evalFormula(options, data = data)

  # make them the same length (by building a data.frame)
  options <- do.call(data.frame, c(options, list(stringsAsFactors = FALSE)))
  layerId <- options[[1]]
  style <- options[-1] # drop layer column
  leaflet::invokeMethod(map, data, "setStyle", "marker", layerId, style)
}

#' Title
#'
#' @param map
#' @param data
#' @param layerId
#' @param stroke
#' @param color
#' @param weight
#' @param opacity
#' @param fill
#' @param fillColor
#' @param fillOpacity
#' @param dashArray
#' @param smoothFactor
#' @param noClip
#' @param options
#'
#' @return
#' @export
#'
#' @examples
setShapeStyle <- function(map, data = leaflet::getMapData(map), layerId,
                          stroke = NULL, color = NULL,
                          weight = NULL, opacity = NULL,
                          fill = NULL, fillColor = NULL,
                          fillOpacity = NULL, dashArray = NULL,
                          smoothFactor = NULL, noClip = NULL,
                          options = NULL) {
  options <- c(
    list(layerId = layerId),
    options,
    leaflet::filterNULL(list(
      stroke = stroke, color = color,
      weight = weight, opacity = opacity,
      fill = fill, fillColor = fillColor,
      fillOpacity = fillOpacity, dashArray = dashArray,
      smoothFactor = smoothFactor, noClip = noClip
    ))
  )
  # evaluate all options
  options <- leaflet::evalFormula(options, data = data)
  # make them the same length (by building a data.frame)
  options <- do.call(data.frame, c(options, list(stringsAsFactors = FALSE)))

  layerId <- options[[1]]
  style <- options[-1] # drop layer column

  leaflet::invokeMethod(map, data, "setStyle", "shape", layerId, style)
}


#' Title
#'
#' @param map
#' @param data
#' @param layerId
#' @param label
#' @param options
#'
#' @return
#' @export
#'
#' @examples
setShapeLabel <- function(map, data = leaflet::getMapData(map), layerId,
                          label = NULL,
                          options = NULL) {
  options <- c(
    list(layerId = layerId),
    options,
    leaflet::filterNULL(list(label = label))
  )
  # evaluate all options
  options <- leaflet::evalFormula(options, data = data)
  # make them the same length (by building a data.frame)
  # options <- do.call(data.frame, c(options, list(stringsAsFactors=FALSE)))
  # layerId <- options[[1]]
  # label <- options[-1] # drop layer column
  # message("invoke")
  # typo fixed in this line
  leaflet::invokeMethod(map, data, "setLabel", "shape", layerId, label)
}
