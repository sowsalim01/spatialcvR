#' Sample Spatial Data for Demonstration
#'
#' A synthetic dataset containing 200 spatial observations with coordinates
#' and variables for demonstration and testing purposes.
#'
#' @format A data frame with 200 rows and 6 columns:
#' \describe{
#'   \item{id}{Unique identifier for each observation (integer)}
#'   \item{longitude}{X coordinate in projected CRS (numeric)}
#'   \item{latitude}{Y coordinate in projected CRS (numeric)}
#'   \item{variable1}{First predictor variable with spatial structure (numeric)}
#'   \item{variable2}{Second predictor variable with spatial structure (numeric)}
#'   \item{target}{Target variable for prediction (numeric)}
#' }
#'
#' @details
#' The data was generated to simulate spatial autocorrelation:
#' - Coordinates are in a UTM-like projected system (0-1000 range)
#' - Variables show gradients in X and Y directions
#' - Target variable combines predictors with spatial structure
#' - Some missing values are included for testing NA handling
#'
#' @source Synthetic data generated for package demonstration
#' @docType data
#' @keywords datasets
#' @name sample_spatial_data
#' @usage data(sample_spatial_data)
#' @examples
#' data(sample_spatial_data)
#' head(sample_spatial_data)
#' summary(sample_spatial_data)
NULL