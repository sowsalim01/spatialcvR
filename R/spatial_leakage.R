# Spatial leakage detection functions

#' Detect Spatial Leakage in Cross-Validation Folds
#'
#' Analyzes the proximity between training and test observations to detect 
#' potential spatial leakage, where training and test sets are too close 
#' spatially, leading to over-optimistic performance estimates.
#'
#' @param data Spatial observations (data.frame or sf object)
#' @param folds A spatial_folds object
#' @param x Name of the x coordinate column (required for data.frame, ignored for sf)
#' @param y Name of the y coordinate column (required for data.frame, ignored for sf)
#' @param threshold Distance threshold for considering observations "too close" (default: NULL, auto-calculated)
#' @param risk_levels Custom risk level thresholds as list(min, moderate, high) (default: NULL)
#'
#' @return An object of class "spatial_leakage_result" containing:
#' \describe{
#'   \item{method}{CV method used}
#'   \item{fold_distances}{Distance analysis for each fold}
#'   \item{summary_statistics}{Overall summary across all folds}
#'   \item{risk_level}{Overall risk assessment: "low", "moderate", or "high"}
#'   \item{recommendations}{Text recommendations based on analysis}
#'   \item{threshold}{Threshold used for risk assessment}
#' }
#'
#' @details
#' The function analyzes spatial distances between training and test observations:
#' \itemize{
#'   \item Calculates minimum, mean, and median distances per fold
#'   \item Identifies observations within threshold distance
#'   \item Assesses overall risk level
#'   \item Provides recommendations for improvement
#' }
#'
#' Risk levels are based on the proportion of train/test pairs that are 
#' too close:
#' \itemize{
#'   \item "low": < 10% of pairs below threshold
#'   \item "moderate": 10-30% of pairs below threshold
#'   \item "high": > 30% of pairs below threshold
#' }
#'
#' @examples
#' \dontrun{
#' data(sample_spatial_data)
#' folds <- spatial_folds(sample_spatial_data, "longitude", "latitude", k = 5)
#' leakage <- detect_spatial_leakage(sample_spatial_data, folds, "longitude", "latitude")
#' print(leakage)
#' }
#'
#' @export
#' @family spatial analysis functions
detect_spatial_leakage <- function(data, folds, x = NULL, y = NULL, 
                                  threshold = NULL, risk_levels = NULL) {
  
  # Validate folds object
  if (!inherits(folds, "spatial_folds")) {
    stop("'folds' must be a spatial_folds object")
  }
  
  # Validate coordinates
  coord_info <- .validate_coordinates(data, x, y)
  
  # Calculate spatial distances
  distance_analysis <- spatial_distance(data, folds, x, y)
  
  # Set default threshold if not provided
  if (is.null(threshold)) {
    # Use 10% of the mean distance across all folds as default threshold
    all_distances <- unlist(lapply(distance_analysis$fold_distances, 
                                   function(f) f$all_distances))
    threshold <- mean(all_distances) * 0.1
  }
  
  # Set default risk levels if not provided
  if (is.null(risk_levels)) {
    risk_levels <- list(
      low = 0.10,      # < 10% below threshold
      moderate = 0.30  # < 30% below threshold
    )
  }
  
  # Analyze each fold for leakage
  fold_analysis <- vector("list", folds$k)
  
  for (i in seq_along(distance_analysis$fold_distances)) {
    fold_dist <- distance_analysis$fold_distances[[i]]
    distances <- fold_dist$all_distances
    
    # Calculate proportion of pairs below threshold
    n_below <- sum(distances < threshold)
    proportion_below <- n_below / length(distances)
    
    # Determine risk level for this fold
    if (proportion_below < risk_levels$low) {
      fold_risk <- "low"
    } else if (proportion_below < risk_levels$moderate) {
      fold_risk <- "moderate"
    } else {
      fold_risk <- "high"
    }
    
    fold_analysis[[i]] <- list(
      fold = i,
      min_distance = fold_dist$min_distance,
      mean_distance = fold_dist$mean_distance,
      median_distance = fold_dist$median_distance,
      proportion_below_threshold = proportion_below,
      n_below_threshold = n_below,
      total_pairs = length(distances),
      risk_level = fold_risk
    )
  }
  
  # Calculate overall summary statistics
  overall_min <- min(sapply(fold_analysis, function(f) f$min_distance))
  overall_mean <- mean(sapply(fold_analysis, function(f) f$mean_distance))
  overall_median <- median(sapply(fold_analysis, function(f) f$median_distance))
  overall_proportion <- mean(sapply(fold_analysis, function(f) f$proportion_below_threshold))
  
  # Determine overall risk level
  if (overall_proportion < risk_levels$low) {
    overall_risk <- "low"
  } else if (overall_proportion < risk_levels$moderate) {
    overall_risk <- "moderate"
  } else {
    overall_risk <- "high"
  }
  
  # Generate recommendations
  recommendations <- generate_recommendations(overall_risk, overall_min, threshold)
  
  # Create result object
  result <- list(
    method = folds$method,
    fold_analysis = fold_analysis,
    summary_statistics = list(
      min_distance = overall_min,
      mean_distance = overall_mean,
      median_distance = overall_median,
      proportion_below_threshold = overall_proportion
    ),
    risk_level = overall_risk,
    recommendations = recommendations,
    threshold = threshold,
    risk_levels = risk_levels
  )
  
  class(result) <- "spatial_leakage_result"
  
  return(result)
}

#' Generate recommendations based on risk assessment
#'
#' @param risk_level Overall risk level
#' @param min_distance Minimum distance observed
#' @param threshold Threshold used
#' @return Character vector of recommendations
#' @keywords internal
generate_recommendations <- function(risk_level, min_distance, threshold) {
  recommendations <- character()
  
  if (risk_level == "low") {
    recommendations <- c(
      "Spatial separation appears adequate.",
      "Current cross-validation setup should provide reliable performance estimates.",
      "Consider increasing spatial separation if you need more conservative estimates."
    )
  } else if (risk_level == "moderate") {
    recommendations <- c(
      "Moderate spatial leakage detected.",
      "Consider using larger buffer distances or block sizes.",
      "Spatial clustering CV might provide better separation.",
      "Compare results with random CV to assess the impact of spatial dependence."
    )
  } else {  # high risk
    recommendations <- c(
      "High spatial leakage detected - results may be over-optimistic.",
      "Strongly recommend using spatial block CV with larger blocks.",
      "Consider buffered CV with increased buffer radius.",
      "Results from random CV may not be reliable for this dataset.",
      "Review the spatial distribution of your data."
    )
  }
  
  return(recommendations)
}

#' Print method for spatial_leakage_result objects
#'
#' @param x A spatial_leakage_result object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the object
#' @export
print.spatial_leakage_result <- function(x, ...) {
  cat("Spatial Leakage Detection\n")
  cat("=========================\n")
  cat("Method:", x$method, "\n")
  cat("Overall Risk Level:", toupper(x$risk_level), "\n")
  cat("Distance Threshold:", round(x$threshold, 2), "\n\n")
  
  cat("Summary Statistics:\n")
  cat(sprintf("  Min distance: %.2f\n", x$summary_statistics$min_distance))
  cat(sprintf("  Mean distance: %.2f\n", x$summary_statistics$mean_distance))
  cat(sprintf("  Median distance: %.2f\n", x$summary_statistics$median_distance))
  cat(sprintf("  Proportion below threshold: %.1f%%\n", 
              x$summary_statistics$proportion_below_threshold * 100))
  cat("\n")
  
  cat("Fold Analysis:\n")
  for (fold in x$fold_analysis) {
    cat(sprintf("  Fold %d: %s risk (%.1f%% below threshold)\n",
                fold$fold, toupper(fold$risk_level),
                fold$proportion_below_threshold * 100))
  }
  cat("\n")
  
  cat("Recommendations:\n")
  for (rec in x$recommendations) {
    cat(paste("  -", rec, "\n"))
  }
  
  invisible(x)
}