# Cross-validation comparison functions

#' Compare Cross-Validation Methods
#'
#' Compares performance metrics across different cross-validation methods 
#' to assess the impact of spatial dependence on model evaluation.
#'
#' @param results_list Named list of spatial_metrics objects from different CV methods
#' @param methods Character vector of method names (optional, uses names of results_list)
#'
#' @return An object of class "cv_comparison" containing:
#' \describe{
#'   \item{summary}{Data frame with summary statistics for each method}
#'   \item{by_fold}{Data frame with fold-level results}
#'   \item{best_method}{Method with best performance according to RMSE}
#'   \item{comparison}{Performance comparison between methods}
#' }
#'
#' @details
#' The function compares metrics across different CV methods:
#' \itemize{
#'   \item Creates summary table with mean and SD of metrics per method
#'   \item Identifies best performing method
#'   \item Provides fold-level comparison
#'   \item Calculates performance differences between methods
#' }
#'
#' This is useful for comparing spatial CV methods against random CV to 
#' demonstrate the impact of spatial dependence.
#'
#' @examples
#' \dontrun{
#' # Train model with different CV methods
#' results_random <- list(RMSE = 0.5, MAE = 0.4, R2 = 0.8)
#' results_block <- list(RMSE = 0.7, MAE = 0.6, R2 = 0.6)
#' results_cluster <- list(RMSE = 0.6, MAE = 0.5, R2 = 0.7)
#' 
#' comparison <- compare_cv(
#'   list(random = results_random, block = results_block, cluster = results_cluster)
#' )
#' print(comparison)
#' }
#'
#' @export
#' @family model evaluation functions
compare_cv <- function(results_list, methods = NULL) {
  
  # Validate input
  if (!is.list(results_list)) {
    stop("'results_list' must be a list")
  }
  
  if (length(results_list) < 2) {
    stop("At least 2 methods are required for comparison")
  }
  
  # Set method names
  if (is.null(methods)) {
    methods <- names(results_list)
    if (is.null(methods)) {
      methods <- paste("Method", 1:length(results_list))
    }
  }
  
  if (length(methods) != length(results_list)) {
    stop("'methods' must have the same length as 'results_list'")
  }
  
  # Extract metrics from each result
  summary_data <- data.frame(
    method = character(),
    RMSE = numeric(),
    MAE = numeric(),
    R2 = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (i in seq_along(results_list)) {
    result <- results_list[[i]]
    
    # Handle different input formats
    if (inherits(result, "spatial_metrics")) {
      rmse <- result$RMSE
      mae <- result$MAE
      r2 <- result$R2
    } else if (is.list(result)) {
      rmse <- ifelse("RMSE" %in% names(result), result$RMSE, NA)
      mae <- ifelse("MAE" %in% names(result), result$MAE, NA)
      r2 <- ifelse("R2" %in% names(result), result$R2, NA)
    } else {
      warning(paste("Result", i, "is not a recognized format, skipping"))
      next
    }
    
    summary_data <- rbind(summary_data, data.frame(
      method = methods[i],
      RMSE = rmse,
      MAE = mae,
      R2 = r2,
      stringsAsFactors = FALSE
    ))
  }
  
  # Remove rows with NA metrics
  summary_data <- summary_data[complete.cases(summary_data), ]
  
  if (nrow(summary_data) < 2) {
    stop("Insufficient valid results for comparison")
  }
  
  # Identify best method (lowest RMSE)
  best_idx <- which.min(summary_data$RMSE)
  best_method <- summary_data$method[best_idx]
  
  # Calculate performance differences
  baseline_rmse <- summary_data$RMSE[1]
  summary_data$RMSE_diff <- summary_data$RMSE - baseline_rmse
  summary_data$RMSE_diff_pct <- (summary_data$RMSE_diff / baseline_rmse) * 100
  
  # Create result object
  result <- list(
    summary = summary_data,
    best_method = best_method,
    n_methods = nrow(summary_data),
    comparison = list(
      baseline_method = summary_data$method[1],
      baseline_rmse = baseline_rmse,
      best_rmse = min(summary_data$RMSE),
      rmse_range = range(summary_data$RMSE),
      mae_range = range(summary_data$MAE),
      r2_range = range(summary_data$R2)
    )
  )
  
  class(result) <- "cv_comparison"
  
  return(result)
}

#' Print method for cv_comparison objects
#'
#' @param x A cv_comparison object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns the object
#' @export
print.cv_comparison <- function(x, ...) {
  cat("Cross-Validation Method Comparison\n")
  cat("===================================\n")
  cat("Number of methods compared:", x$n_methods, "\n")
  cat("Best method (lowest RMSE):", x$best_method, "\n\n")
  
  cat("Summary Table:\n")
  print(x$summary, row.names = FALSE)
  cat("\n")
  
  cat("Performance Comparison:\n")
  cat(sprintf("  Baseline method: %s (RMSE = %.4f)\n", 
              x$comparison$baseline_method, x$comparison$baseline_rmse))
  cat(sprintf("  Best RMSE: %.4f\n", x$comparison$best_rmse))
  cat(sprintf("  RMSE range: [%.4f, %.4f]\n", 
              x$comparison$rmse_range[1], x$comparison$rmse_range[2]))
  cat(sprintf("  MAE range: [%.4f, %.4f]\n", 
              x$comparison$mae_range[1], x$comparison$mae_range[2]))
  cat(sprintf("  R² range: [%.4f, %.4f]\n", 
              x$comparison$r2_range[1], x$comparison$r2_range[2]))
  
  invisible(x)
}