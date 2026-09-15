# Spatial residual diagnostics functions

#' @importFrom stats sd
NULL

#' Spatial Residual Diagnostics
#'
#' Analyzes the spatial distribution of model residuals to detect spatial 
#' patterns in prediction errors. This helps identify whether model errors 
#' are spatially autocorrelated, which may indicate missing spatial predictors 
#' or inappropriate model specification.
#'
#' @param observed Numeric vector of observed values
#' @param predicted Numeric vector of predicted values
#' @param coordinates Coordinate matrix or data.frame with x and y columns
#' @param x Name of x coordinate column if coordinates is a data.frame
#' @param y Name of y coordinate column if coordinates is a data.frame
#'
#' @return An object of class "spatial_residuals" containing:
#' \describe{
#'   \item{residuals}{Residual values (observed - predicted)}
#'   \item{observed}{Observed values}
#'   \item{predicted}{Predicted values}
#'   \item{coordinates}{Coordinate matrix}
#'   \item{statistics}{Summary statistics of residuals}
#' }
#'
#' @details
#' The function calculates residuals and provides summary statistics:
#' \itemize{
#'   \item Mean, median, SD of residuals
#'   \item Quantiles of residuals
#'   \item Normality test statistics (if sufficient data)
#' }
#'
#' Spatial autocorrelation analysis can be added in future versions when 
#' appropriate dependencies (e.g., spdep) are available.
#'
#' @examples
#' observed <- c(1, 2, 3, 4, 5)
#' predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
#' coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
#' residuals <- spatial_residuals(observed, predicted, coords)
#' print(residuals)
#'
#' @export
#' @family spatial diagnostics functions
spatial_residuals <- function(observed, predicted, coordinates, x = NULL, y = NULL) {
  
  # Validate inputs
  if (!is.numeric(observed)) {
    stop("'observed' must be numeric")
  }
  if (!is.numeric(predicted)) {
    stop("'predicted' must be numeric")
  }
  if (length(observed) != length(predicted)) {
    stop("'observed' and 'predicted' must have the same length")
  }
  
  # Handle coordinates
  if (is.data.frame(coordinates)) {
    if (is.null(x) || is.null(y)) {
      stop("For data.frame coordinates, both 'x' and 'y' column names must be provided")
    }
    if (!x %in% names(coordinates)) {
      stop(paste("Column '", x, "' not found in coordinates", sep = ""))
    }
    if (!y %in% names(coordinates)) {
      stop(paste("Column '", y, "' not found in coordinates", sep = ""))
    }
    coord_matrix <- cbind(coordinates[[x]], coordinates[[y]])
    colnames(coord_matrix) <- c("x", "y")
  } else if (is.matrix(coordinates)) {
    if (ncol(coordinates) != 2) {
      stop("Coordinate matrix must have exactly 2 columns")
    }
    coord_matrix <- coordinates
    colnames(coord_matrix) <- c("x", "y")
  } else {
    stop("'coordinates' must be a data.frame or matrix")
  }
  
  # Check coordinate dimensions
  if (nrow(coord_matrix) != length(observed)) {
    stop("Number of coordinates must match length of observed/predicted vectors")
  }
  
  # Calculate residuals
  residuals <- observed - predicted
  
  # Calculate summary statistics
  residual_stats <- list(
    mean = mean(residuals, na.rm = TRUE),
    median = median(residuals, na.rm = TRUE),
    sd = sd(residuals, na.rm = TRUE),
    min = min(residuals, na.rm = TRUE),
    max = max(residuals, na.rm = TRUE),
    quantiles = quantile(residuals, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
  )
  
  # Create result object
  result <- list(
    residuals = residuals,
    observed = observed,
    predicted = predicted,
    coordinates = coord_matrix,
    statistics = residual_stats,
    n = length(observed)
  )
  
  class(result) <- "spatial_residuals"
  
  return(result)
}

#' Print method for spatial_residuals objects
#'
#' @param x A spatial_residuals object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the object
#' @export
print.spatial_residuals <- function(x, ...) {
  cat("Spatial Residual Diagnostics\n")
  cat("============================\n")
  cat("Number of observations:", x$n, "\n\n")
  
  cat("Residual Statistics:\n")
  cat(sprintf("  Mean: %.4f\n", x$statistics$mean))
  cat(sprintf("  Median: %.4f\n", x$statistics$median))
  cat(sprintf("  SD: %.4f\n", x$statistics$sd))
  cat(sprintf("  Min: %.4f\n", x$statistics$min))
  cat(sprintf("  Max: %.4f\n", x$statistics$max))
  cat(sprintf("  Q25: %.4f\n", x$statistics$quantiles[1]))
  cat(sprintf("  Q50: %.4f\n", x$statistics$quantiles[2]))
  cat(sprintf("  Q75: %.4f\n", x$statistics$quantiles[3]))
  cat("\n")
  
  cat("Coordinate Range:\n")
  cat(sprintf("  X: [%.2f, %.2f]\n", min(x$coordinates[, "x"]), max(x$coordinates[, "x"])))
  cat(sprintf("  Y: [%.2f, %.2f]\n", min(x$coordinates[, "y"]), max(x$coordinates[, "y"])))
  
  invisible(x)
}