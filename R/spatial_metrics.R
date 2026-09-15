# Model evaluation metrics implementation

#' Spatial Model Evaluation Metrics
#'
#' Calculates standard model evaluation metrics for comparing observed and 
#' predicted values. These metrics are commonly used in machine learning 
#' and spatial modeling.
#'
#' @param observed Numeric vector of observed values
#' @param predicted Numeric vector of predicted values
#' @param na.rm Logical, whether to remove NA values (default: TRUE)
#'
#' @return An object of class "spatial_metrics" containing:
#' \describe{
#'   \item{n}{Number of observations}
#'   \item{RMSE}{Root Mean Square Error}
#'   \item{MAE}{Mean Absolute Error}
#'   \item{R2}{R-squared (coefficient of determination)}
#'   \item{MAPE}{Mean Absolute Percentage Error (when applicable)}
#' }
#'
#' @details
#' The function calculates the following metrics:
#' \itemize{
#'   \item RMSE: sqrt(mean((observed - predicted)^2))
#'   \item MAE: mean(abs(observed - predicted))
#'   \item R2: 1 - sum((observed - predicted)^2) / sum((observed - mean(observed))^2)
#'   \item MAPE: mean(abs((observed - predicted) / observed)) * 100 (only when no zeros in observed)
#' }
#'
#' @examples
#' observed <- c(1, 2, 3, 4, 5)
#' predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
#' metrics <- spatial_metrics(observed, predicted)
#' print(metrics)
#'
#' @export
#' @family model evaluation functions
spatial_metrics <- function(observed, predicted, na.rm = TRUE) {
  
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
  
  # Handle NA values
  if (na.rm) {
    valid_idx <- !is.na(observed) & !is.na(predicted)
    observed <- observed[valid_idx]
    predicted <- predicted[valid_idx]
  } else {
    if (any(is.na(observed)) || any(is.na(predicted))) {
      stop("NA values found. Set na.rm = TRUE to remove them.")
    }
  }
  
  # Check for sufficient data
  n <- length(observed)
  if (n < 2) {
    stop("At least 2 non-NA observations are required")
  }
  
  # Calculate residuals
  residuals <- observed - predicted
  
  # Calculate RMSE
  rmse <- sqrt(mean(residuals^2))
  
  # Calculate MAE
  mae <- mean(abs(residuals))
  
  # Calculate R2
  ss_res <- sum(residuals^2)
  ss_tot <- sum((observed - mean(observed))^2)
  
  if (ss_tot == 0) {
    # All observed values are the same
    r2 <- ifelse(ss_res == 0, 1, 0)
  } else {
    r2 <- 1 - (ss_res / ss_tot)
  }
  
  # Calculate MAPE only if no zeros in observed (to avoid division by zero)
  if (any(observed == 0)) {
    mape <- NA
  } else {
    mape <- mean(abs(residuals / observed)) * 100
  }
  
  # Create result object
  result <- list(
    n = n,
    RMSE = rmse,
    MAE = mae,
    R2 = r2,
    MAPE = mape
  )
  
  class(result) <- "spatial_metrics"
  
  return(result)
}

#' Print method for spatial_metrics objects
#'
#' @param x A spatial_metrics object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the object
#' @export
print.spatial_metrics <- function(x, ...) {
  cat("Model Evaluation Metrics\n")
  cat("=======================\n")
  cat("Number of observations:", x$n, "\n")
  cat("RMSE:", round(x$RMSE, 4), "\n")
  cat("MAE:", round(x$MAE, 4), "\n")
  cat("R2:", round(x$R2, 4), "\n")
  if (!is.na(x$MAPE)) {
    cat("MAPE:", round(x$MAPE, 2), "%\n")
  } else {
    cat("MAPE: NA (zeros in observed values)\n")
  }
  
  invisible(x)
}