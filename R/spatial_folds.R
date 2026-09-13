# Main spatial cross-validation functions

#' Create Spatial Cross-Validation Folds
#'
#' Creates spatially separated folds for model evaluation to address spatial 
#' dependence in observations. This function serves as a wrapper for different 
#' spatial cross-validation methods.
#'
#' @param data Spatial observations (data.frame or sf object)
#' @param x Name of the x coordinate column (required for data.frame, ignored for sf)
#' @param y Name of the y coordinate column (required for data.frame, ignored for sf)
#' @param k Number of folds (default: 5)
#' @param method Spatial CV method: "block", "buffer", "cluster", or "random" (default: "block")
#' @param seed Random seed for reproducibility (default: NULL)
#' @param ... Additional parameters passed to specific methods
#'
#' @return An object of class "spatial_folds" containing:
#' \describe{
#'   \item{folds}{List of train/test indices for each fold}
#'   \item{method}{Method used for fold creation}
#'   \item{k}{Number of folds}
#'   \item{parameters}{List of parameters used}
#'   \item{coordinates}{Coordinate matrix of observations}
#'   \item{crs}{Coordinate reference system}
#'   \item{metadata}{Additional metadata}
#' }
#'
#' @details
#' The function validates inputs and dispatches to the appropriate spatial CV method:
#' \itemize{
#'   \item "block": Spatial block cross-validation (default)
#'   \item "buffer": Buffered cross-validation
#'   \item "cluster": Spatial clustering cross-validation
#'   \item "random": Random spatial split (baseline)
#' }
#'
#' @examples
#' \dontrun{
#' data(sample_spatial_data)
#' folds <- spatial_folds(
#'   data = sample_spatial_data,
#'   x = "longitude",
#'   y = "latitude",
#'   k = 5,
#'   method = "block"
#' )
#' }
#'
#' @export
#' @family spatial cross-validation functions
spatial_folds <- function(data, 
                          x = NULL, 
                          y = NULL, 
                          k = 5, 
                          method = "block",
                          seed = NULL,
                          ...) {
  
  # Set seed for reproducibility
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # Validate coordinates
  coord_info <- .validate_coordinates(data, x, y)
  
  # Validate k
  k <- .validate_k(k, coord_info$n)
  
  # Check for duplicate coordinates
  if (.has_duplicate_coordinates(coord_info$x, coord_info$y)) {
    warning("Duplicate coordinates detected. This may affect fold assignment.")
  }
  
  # Create coordinate matrix
  coord_matrix <- .create_coord_matrix(coord_info$x, coord_info$y)
  
  # Dispatch to appropriate method
  if (method == "block") {
    result <- spatial_block_folds(data, x, y, k, ...)
  } else if (method == "buffer") {
    result <- spatial_buffer_folds(data, x, y, k, ...)
  } else if (method == "cluster") {
    result <- spatial_cluster_folds(data, x, y, k, ...)
  } else if (method == "random") {
    result <- spatial_split(data, x, y, k, ...)
  } else {
    stop(paste("Unknown method:", method, 
                ". Valid methods are: 'block', 'buffer', 'cluster', 'random'"))
  }
  
  # Add common metadata
  result$coordinates <- coord_matrix
  result$crs <- coord_info$crs
  result$metadata <- list(
    n_observations = coord_info$n,
    has_duplicates = .has_duplicate_coordinates(coord_info$x, coord_info$y),
    seed = seed
  )
  
  class(result) <- "spatial_folds"
  
  return(result)
}

#' Print method for spatial_folds objects
#'
#' @param x A spatial_folds object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the object
#' @export
print.spatial_folds <- function(x, ...) {
  cat("Spatial Cross-Validation Folds\n")
  cat("==============================\n")
  cat("Method:", x$method, "\n")
  cat("Number of folds:", x$k, "\n")
  cat("Observations:", x$metadata$n_observations, "\n")
  cat("CRS:", ifelse(is.na(x$crs), "Not defined", x$crs), "\n")
  cat("Has duplicate coordinates:", x$metadata$has_duplicates, "\n")
  if (!is.null(x$metadata$seed)) {
    cat("Seed:", x$metadata$seed, "\n")
  }
  cat("\n")
  
  # Print fold sizes
  cat("Fold sizes:\n")
  for (i in seq_along(x$folds)) {
    n_train <- length(x$folds[[i]]$train)
    n_test <- length(x$folds[[i]]$test)
    cat(sprintf("  Fold %d: %d train, %d test\n", i, n_train, n_test))
  }
  
  invisible(x)
}