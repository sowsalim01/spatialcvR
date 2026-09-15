# Visualization functions for spatialcvR

#' @importFrom grDevices colorRampPalette rainbow
#' @importFrom graphics abline legend
#' @importFrom stats qqnorm qqline
NULL

#' Plot Spatial Cross-Validation Folds
#'
#' Creates a visual representation of spatial cross-validation folds, 
#' showing the spatial distribution of training and test observations.
#'
#' @param folds A spatial_folds object
#' @param data Spatial observations (data.frame or sf object)
#' @param x Name of the x coordinate column (required for data.frame, ignored for sf)
#' @param y Name of the y coordinate column (required for data.frame, ignored for sf)
#' @param fold Fold number to plot (default: 1, or "all" for all folds)
#' @param main Plot title (default: NULL, auto-generated)
#' @param ... Additional graphical parameters passed to plot()
#'
#' @return Invisibly returns the fold object
#'
#' @details
#' Creates a scatter plot showing training and test observations with different 
#' colors. For spatial block CV, also shows block boundaries when available.
#'
#' @examples
#' \dontrun{
#' data(sample_spatial_data)
#' folds <- spatial_folds(sample_spatial_data, "longitude", "latitude", k = 5)
#' plot_spatial_folds(folds, sample_spatial_data, "longitude", "latitude", fold = 1)
#' }
#'
#' @export
#' @family visualization functions
plot_spatial_folds <- function(folds, data, x = NULL, y = NULL, fold = 1, 
                               main = NULL, ...) {
  
  # Validate folds object
  if (!inherits(folds, "spatial_folds")) {
    stop("'folds' must be a spatial_folds object")
  }
  
  # Validate coordinates
  coord_info <- .validate_coordinates(data, x, y)
  
  # Extract coordinates
  x_coords <- coord_info$x
  y_coords <- coord_info$y
  
  # Set plot title
  if (is.null(main)) {
    if (fold == "all") {
      main <- paste("Spatial Cross-Validation Folds -", folds$method, 
                    "- All Folds")
    } else {
      main <- paste("Spatial Cross-Validation Folds -", folds$method, 
                    "- Fold", fold)
    }
  }
  
  if (fold == "all") {
    # Plot all folds with different colors
    colors <- rainbow(folds$k)
    
    # Set up plot
    plot(x_coords, y_coords, type = "n", 
         xlab = "X Coordinate", ylab = "Y Coordinate",
         main = main, ...)
    
    # Plot each fold
    for (i in seq_along(folds$folds)) {
      test_idx <- folds$folds[[i]]$test
      points(x_coords[test_idx], y_coords[test_idx], 
             col = colors[i], pch = 19, cex = 0.8)
    }
    
    # Add legend
    legend("topright", legend = paste("Fold", 1:folds$k), 
           col = colors, pch = 19, cex = 0.8)
    
  } else {
    # Plot single fold
    if (fold < 1 || fold > folds$k) {
      stop(paste("'fold' must be between 1 and", folds$k))
    }
    
    train_idx <- folds$folds[[fold]]$train
    test_idx <- folds$folds[[fold]]$test
    
    # Set up plot
    plot(x_coords, y_coords, type = "n",
         xlab = "X Coordinate", ylab = "Y Coordinate",
         main = main, ...)
    
    # Plot training points
    points(x_coords[train_idx], y_coords[train_idx], 
           col = "blue", pch = 19, cex = 0.8)
    
    # Plot test points
    points(x_coords[test_idx], y_coords[test_idx], 
           col = "red", pch = 19, cex = 0.8)
    
    # Add legend
    legend("topright", legend = c("Training", "Test"), 
           col = c("blue", "red"), pch = 19, cex = 0.8)
  }
  
  # Add block boundaries for spatial block method if available
  if (folds$method == "spatial_block" && !is.null(folds$parameters$x_breaks)) {
    abline(v = folds$parameters$x_breaks, col = "gray", lty = 2)
    abline(h = folds$parameters$y_breaks, col = "gray", lty = 2)
  }
  
  invisible(folds)
}

#' Plot Spatial Residuals
#'
#' Creates visualizations of spatial residuals to analyze the spatial 
#' distribution of model errors.
#'
#' @param residuals_obj A spatial_residuals object
#' @param type Type of plot: "scatter", "histogram", or "qq" (default: "scatter")
#' @param main Plot title (default: NULL, auto-generated)
#' @param ... Additional graphical parameters passed to plot()
#'
#' @return Invisibly returns the residuals object
#'
#' @details
#' Creates different types of residual plots:
#' \itemize{
#'   \item "scatter": Spatial scatter plot of residuals colored by magnitude
#'   \item "histogram": Histogram of residual values
#'   \item "qq": Q-Q plot for normality assessment
#' }
#'
#' @examples
#' \dontrun{
#' observed <- c(1, 2, 3, 4, 5)
#' predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
#' coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
#' residuals <- spatial_residuals(observed, predicted, coords)
#' plot_spatial_residuals(residuals, type = "scatter")
#' }
#'
#' @export
#' @family visualization functions
plot_spatial_residuals <- function(residuals_obj, type = "scatter", 
                                   main = NULL, ...) {
  
  # Validate residuals object
  if (!inherits(residuals_obj, "spatial_residuals")) {
    stop("'residuals_obj' must be a spatial_residuals object")
  }
  
  # Set plot title
  if (is.null(main)) {
    main <- paste("Spatial Residuals -", toupper(type))
  }
  
  if (type == "scatter") {
    # Spatial scatter plot colored by residual magnitude
    coords <- residuals_obj$coordinates
    residuals <- residuals_obj$residuals
    
    # Color scale based on residual magnitude
    residual_range <- range(abs(residuals))
    colors <- colorRampPalette(c("blue", "white", "red"))(100)
    color_idx <- cut(abs(residuals), 
                     breaks = seq(residual_range[1], residual_range[2], 
                                 length.out = 101),
                     labels = FALSE)
    color_idx[is.na(color_idx)] <- 1
    point_colors <- colors[color_idx]
    
    # Create plot
    plot(coords[, "x"], coords[, "y"], 
         col = point_colors, pch = 19, cex = 1.2,
         xlab = "X Coordinate", ylab = "Y Coordinate",
         main = main, ...)
    
    # Add color scale legend
    legend("topright", legend = c("Negative", "Near Zero", "Positive"),
           col = c("blue", "white", "red"), pch = 19, cex = 0.8)
    
  } else if (type == "histogram") {
    # Histogram of residuals
    residuals <- residuals_obj$residuals
    
    hist(residuals, 
         xlab = "Residual Value", ylab = "Frequency",
         main = main,
         col = "lightblue", border = "darkblue", ...)
    
    # Add mean line
    abline(v = mean(residuals), col = "red", lwd = 2, lty = 2)
    legend("topright", legend = "Mean", col = "red", lwd = 2, lty = 2)
    
  } else if (type == "qq") {
    # Q-Q plot for normality
    residuals <- residuals_obj$residuals
    
    qqnorm(residuals, main = main, ...)
    qqline(residuals, col = "red", lwd = 2)
    
  } else {
    stop("'type' must be one of: 'scatter', 'histogram', 'qq'")
  }
  
  invisible(residuals_obj)
}