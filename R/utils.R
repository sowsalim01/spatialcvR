# Internal utility functions for spatialcvR

#' Validate coordinate inputs
#'
#' @param data Input data (data.frame or sf object)
#' @param x Name of x coordinate column or NULL for sf objects
#' @param y Name of y coordinate column or NULL for sf objects
#' @return List with validated coordinates and CRS information
#' @keywords internal
.validate_coordinates <- function(data, x, y) {
  # Check if data is sf object
  is_sf <- inherits(data, "sf")
  
  if (is_sf) {
    # Extract coordinates from sf object
    coords <- sf::st_coordinates(data)
    x_coords <- coords[, "X"]
    y_coords <- coords[, "Y"]
    crs <- sf::st_crs(data)$input
    
    # Check for CRS
    if (is.na(crs) || is.null(crs)) {
      warning("sf object has no CRS defined. Distance calculations may be inaccurate.")
    }
    
  } else {
    # Validate that x and y are provided for data.frame
    if (is.null(x) || is.null(y)) {
      stop("For data.frame input, both 'x' and 'y' coordinate column names must be provided.")
    }
    
    # Check that columns exist
    if (!x %in% names(data)) {
      stop(paste("Column '", x, "' not found in data.", sep = ""))
    }
    if (!y %in% names(data)) {
      stop(paste("Column '", y, "' not found in data.", sep = ""))
    }
    
    # Extract coordinates
    x_coords <- data[[x]]
    y_coords <- data[[y]]
    crs <- NA
    
    # Check if coordinates are numeric
    if (!is.numeric(x_coords)) {
      stop(paste("Column '", x, "' must be numeric.", sep = ""))
    }
    if (!is.numeric(y_coords)) {
      stop(paste("Column '", y, "' must be numeric.", sep = ""))
    }
  }
  
  # Check for missing values
  if (any(is.na(x_coords))) {
    stop("Missing values found in x coordinates.")
  }
  if (any(is.na(y_coords))) {
    stop("Missing values found in y coordinates.")
  }
  
  # Check for infinite values
  if (any(is.infinite(x_coords))) {
    stop("Infinite values found in x coordinates.")
  }
  if (any(is.infinite(y_coords))) {
    stop("Infinite values found in y coordinates.")
  }
  
  # Check for sufficient data
  n <- length(x_coords)
  if (n < 2) {
    stop("At least 2 observations are required for spatial cross-validation.")
  }
  
  list(
    x = x_coords,
    y = y_coords,
    crs = crs,
    n = n,
    is_sf = is_sf
  )
}

#' Validate k parameter
#'
#' @param k Number of folds
#' @param n Number of observations
#' @return Validated k value
#' @keywords internal
.validate_k <- function(k, n) {
  if (!is.numeric(k) || length(k) != 1) {
    stop("'k' must be a single numeric value.")
  }
  
  if (k < 2) {
    stop("'k' must be at least 2.")
  }
  
  if (k > n) {
    stop(paste("'k' cannot be greater than the number of observations (", n, ").", sep = ""))
  }
  
  as.integer(k)
}

#' Check for duplicate coordinates
#'
#' @param x X coordinates
#' @param y Y coordinates
#' @return Logical indicating if duplicates exist
#' @keywords internal
.has_duplicate_coordinates <- function(x, y) {
  coords <- paste(x, y, sep = "_")
  any(duplicated(coords))
}

#' Create coordinate matrix
#'
#' @param x X coordinates
#' @param y Y coordinates
#' @return Matrix with coordinates
#' @keywords internal
.create_coord_matrix <- function(x, y) {
  cbind(x = x, y = y)
}