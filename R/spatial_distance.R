# Spatial distance calculation functions

#' @importFrom stats sd
NULL

#' Calculate Spatial Distances Between Train and Test Observations
#'
#' Computes distances between training and test observations for each fold 
#' in a spatial cross-validation setup. This helps assess the spatial 
#' separation between training and test sets.
#'
#' @param data Spatial observations (data.frame or sf object)
#' @param folds A spatial_folds object
#' @param x Name of the x coordinate column (required for data.frame, ignored for sf)
#' @param y Name of the y coordinate column (required for data.frame, ignored for sf)
#'
#' @return A list containing distance information for each fold:
#' \describe{
#'   \item{fold}{Fold number}
#'   \item{min_distance}{Minimum distance between train and test observations}
#'   \item{mean_distance}{Mean distance between train and test observations}
#'   \item{median_distance}{Median distance between train and test observations}
#'   \item{max_distance}{Maximum distance between train and test observations}
#'   \item{sd_distance}{Standard deviation of distances}
#'   \item{quantiles}{Distance quantiles (25%, 50%, 75%)}
#' }
#'
#' @details
#' For each fold, the function calculates Euclidean distances between all 
#' pairs of training and test observations. This provides a comprehensive 
#' view of spatial separation.
#'
#' Note: Distance calculations use Euclidean distance on the provided 
#' coordinates. For accurate metric distances, ensure data is in a 
#' projected CRS. Geographic coordinates (longitude/latitude) will produce 
#' approximate distances.
#'
#' @examples
#' \dontrun{
#' data(sample_spatial_data)
#' folds <- spatial_folds(sample_spatial_data, "longitude", "latitude", k = 5)
#' distances <- spatial_distance(sample_spatial_data, folds, "longitude", "latitude")
#' print(distances)
#' }
#'
#' @export
#' @family spatial analysis functions
spatial_distance <- function(data, folds, x = NULL, y = NULL) {
  
  # Validate folds object
  if (!inherits(folds, "spatial_folds")) {
    stop("'folds' must be a spatial_folds object")
  }
  
  # Validate coordinates
  coord_info <- .validate_coordinates(data, x, y)
  
  # Extract coordinates
  x_coords <- coord_info$x
  y_coords <- coord_info$y
  
  # Check CRS warning
  if (!is.na(coord_info$crs) && grepl("EPSG:4326|WGS 84|latlong", coord_info$crs, ignore.case = TRUE)) {
    warning("Geographic CRS detected. Distance calculations are approximate. Consider using a projected CRS for accurate metric distances.")
  }
  
  # Calculate distances for each fold
  distance_results <- vector("list", folds$k)
  
  for (i in seq_along(folds$folds)) {
    train_idx <- folds$folds[[i]]$train
    test_idx <- folds$folds[[i]]$test
    
    # Get coordinates
    train_coords <- cbind(x_coords[train_idx], y_coords[train_idx])
    test_coords <- cbind(x_coords[test_idx], y_coords[test_idx])
    
    # Calculate pairwise distances
    distances <- calculate_pairwise_distances(train_coords, test_coords)
    
    # Calculate statistics
    distance_results[[i]] <- list(
      fold = i,
      min_distance = min(distances),
      mean_distance = mean(distances),
      median_distance = median(distances),
      max_distance = max(distances),
      sd_distance = sd(distances),
      quantiles = quantile(distances, probs = c(0.25, 0.5, 0.75)),
      all_distances = distances
    )
  }
  
  # Add summary information
  result <- list(
    fold_distances = distance_results,
    method = folds$method,
    k = folds$k,
    n_observations = coord_info$n,
    crs = coord_info$crs
  )
  
  class(result) <- "spatial_distance"
  
  return(result)
}

#' Calculate pairwise Euclidean distances
#'
#' @param train_coords Matrix of training coordinates (n_train x 2)
#' @param test_coords Matrix of test coordinates (n_test x 2)
#' @return Vector of all pairwise distances
#' @keywords internal
calculate_pairwise_distances <- function(train_coords, test_coords) {
  n_train <- nrow(train_coords)
  n_test <- nrow(test_coords)
  
  # Calculate all pairwise distances
  distances <- numeric(n_train * n_test)
  
  idx <- 1
  for (i in 1:n_test) {
    for (j in 1:n_train) {
      dx <- test_coords[i, 1] - train_coords[j, 1]
      dy <- test_coords[i, 2] - train_coords[j, 2]
      distances[idx] <- sqrt(dx^2 + dy^2)
      idx <- idx + 1
    }
  }
  
  return(distances)
}

#' Print method for spatial_distance objects
#'
#' @param x A spatial_distance object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the object
#' @export
print.spatial_distance <- function(x, ...) {
  cat("Spatial Distance Analysis\n")
  cat("=========================\n")
  cat("Method:", x$method, "\n")
  cat("Number of folds:", x$k, "\n")
  cat("Observations:", x$n_observations, "\n")
  cat("CRS:", ifelse(is.na(x$crs), "Not defined", x$crs), "\n\n")
  
  # Print summary for each fold
  cat("Fold Distance Summaries:\n")
  for (fold_dist in x$fold_distances) {
    cat(sprintf("  Fold %d:\n", fold_dist$fold))
    cat(sprintf("    Min: %.2f\n", fold_dist$min_distance))
    cat(sprintf("    Mean: %.2f\n", fold_dist$mean_distance))
    cat(sprintf("    Median: %.2f\n", fold_dist$median_distance))
    cat(sprintf("    Max: %.2f\n", fold_dist$max_distance))
    cat(sprintf("    SD: %.2f\n", fold_dist$sd_distance))
  }
  
  invisible(x)
}