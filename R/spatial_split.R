# Random spatial split implementation (baseline)

#' Random Spatial Split
#'
#' Creates a random spatial split serving as a baseline for comparison with 
#' spatial cross-validation methods. This represents traditional random 
#' cross-validation without spatial considerations.
#'
#' @param data Spatial observations (data.frame or sf object)
#' @param x Name of the x coordinate column (required for data.frame, ignored for sf)
#' @param y Name of the y coordinate column (required for data.frame, ignored for sf)
#' @param k Number of folds (default: 5)
#' @param seed Random seed for reproducibility (default: NULL)
#'
#' @return An object of class "spatial_folds" containing fold assignments
#'
#' @details
#' This method performs standard random k-fold cross-validation without any 
#' spatial constraints. It serves as a baseline to compare against spatial 
#' cross-validation methods and demonstrate the impact of spatial dependence 
#' on model evaluation.
#'
#' @examples
#' \dontrun{
#' data(sample_spatial_data)
#' folds <- spatial_split(
#'   data = sample_spatial_data,
#'   x = "longitude",
#'   y = "latitude",
#'   k = 5
#' )
#' }
#'
#' @export
#' @family spatial cross-validation functions
spatial_split <- function(data, 
                          x = NULL, 
                          y = NULL, 
                          k = 5,
                          seed = NULL) {
  
  # Set seed for reproducibility
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # Validate coordinates
  coord_info <- .validate_coordinates(data, x, y)
  
  # Validate k
  k <- .validate_k(k, coord_info$n)
  
  # Extract coordinates
  n <- coord_info$n
  
  # Random assignment to folds
  fold_assignment <- sample(rep(1:k, length.out = n))
  
  # Create fold assignments
  folds <- vector("list", k)
  for (i in 1:k) {
    test_indices <- which(fold_assignment == i)
    train_indices <- which(fold_assignment != i)
    
    folds[[i]] <- list(
      train = train_indices,
      test = test_indices
    )
  }
  
  # Create result object
  result <- list(
    folds = folds,
    method = "random",
    k = k,
    parameters = list()
  )
  
  class(result) <- "spatial_folds"
  
  return(result)
}