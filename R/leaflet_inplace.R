# add in methods from https://github.com/rstudio/leaflet/pull/598
#' setCircleMarkerRadius
#' from https://github.com/rstudio/leaflet/pull/598
#'
#' @param map ID of map to edit
#' @param layerId l=ID of layer to change
#' @param radius Radius value
#' @param data dataframe to apply
#'
#'
setCircleMarkerRadius <- function(map, layerId, radius, data = leaflet::getMapData(map)) {
  options <- list(layerId = layerId, radius = radius)
  # evaluate all options
  options <- leaflet::evalFormula(options, data = data)
  # make them the same length (by building a data.frame)
  options <- do.call(data.frame, c(options, list(stringsAsFactors = FALSE)))
  leaflet::invokeMethod(map, data, "setRadius", options$layerId, options$radius)
}

#' setCircleMarkerStyle
#' from https://github.com/rstudio/leaflet/pull/598
#'
#' @param map Leaflet map object
#' @param layerId Layer id
#' @param radius Cicle radius
#' @param stroke Stoke 
#' @param color Stroke color 
#' @param weight Stroke weight (width)
#' @param opacity Stroke opacity
#' @param fill Circle fill 
#' @param fillColor Circle fill color
#' @param fillOpacity Circle fill opacity
#' @param dashArray NULL
#' @param options Leaflet options
#' @param data Leaflet map data
#'
#'
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

#' setShapeStyle
#' from https://github.com/rstudio/leaflet/pull/598
#' @param map Leaflet map object
#' @param data Leaflet map data
#' @param layerId Layer to manipulate
#' @param stroke Stroke (bool)
#' @param color Shape color
#' @param weight Stroke weight (line width)
#' @param opacity Stroke opacity
#' @param fill Shape fill (bool)
#' @param fillColor Fill color
#' @param fillOpacity Fill opacity
#' @param dashArray NULL
#' @param smoothFactor Should shapes and colors be smooth
#' @param noClip Allow clipping
#' @param options Leaflet options
#'
#'
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


#' setShapeLabel
#' from https://github.com/rstudio/leaflet/pull/598
#'
#' @param map Leaflet map object
#' @param data Leaflet map data
#' @param layerId Layer to manipulate
#' @param label Labels to add
#' @param options Options to add
#'
#'
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
  # typo fixed in this line
  leaflet::invokeMethod(map, data, "setLabel", "shape", layerId, label)
}
