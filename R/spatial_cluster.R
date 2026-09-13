# Spatial clustering cross-validation implementation

#' Spatial Clustering Cross-Validation
#'
#' Creates spatial cross-validation folds by clustering observations spatially 
#' and assigning clusters to folds. This method is useful for data with complex 
#' spatial structure.
#'
#' @param data Spatial observations (data.frame or sf object)
#' @param x Name of the x coordinate column (required for data.frame, ignored for sf)
#' @param y Name of the y coordinate column (required for data.frame, ignored for sf)
#' @param k Number of folds (default: 5)
#' @param n_clusters Number of spatial clusters (default: k)
#' @param seed Random seed for reproducibility (default: NULL)
#'
#' @return An object of class "spatial_folds" containing fold assignments
#'
#' @details
#' The clustering method groups spatially proximate observations into clusters 
#' using k-means clustering on coordinates, then assigns clusters to folds. 
#' This ensures spatial coherence within folds while maintaining separation 
#' between folds.
#'
#' @examples
#' \dontrun{
#' data(sample_spatial_data)
#' folds <- spatial_cluster_folds(
#'   data = sample_spatial_data,
#'   x = "longitude",
#'   y = "latitude",
#'   k = 5,
#'   n_clusters = 10
#' )
#' }
#'
#' @export
#' @family spatial cross-validation functions
spatial_cluster_folds <- function(data, 
                                  x = NULL, 
                                  y = NULL, 
                                  k = 5,
                                  n_clusters = NULL,
                                  seed = NULL) {
  
  # Set seed for reproducibility
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # Validate coordinates
  coord_info <- .validate_coordinates(data, x, y)
  
  # Validate k
  k <- .validate_k(k, coord_info$n)
  
  # Set default number of clusters
  if (is.null(n_clusters)) {
    n_clusters <- k
  }
  
  # Validate n_clusters
  if (!is.numeric(n_clusters) || n_clusters < k) {
    stop("n_clusters must be at least equal to k")
  }
  
  # Extract coordinates
  x_coords <- coord_info$x
  y_coords <- coord_info$y
  n <- coord_info$n
  
  # Perform k-means clustering on coordinates
  coord_matrix <- cbind(x_coords, y_coords)
  clusters <- kmeans(coord_matrix, centers = n_clusters, nstart = 10)
  
  # Assign clusters to folds
  cluster_folds <- sample(rep(1:k, length.out = n_clusters))
  names(cluster_folds) <- 1:n_clusters
  
  # Assign each observation to a fold based on its cluster
  obs_folds <- cluster_folds[as.character(clusters$cluster)]
  
  # Create fold assignments
  folds <- vector("list", k)
  for (i in 1:k) {
    test_indices <- which(obs_folds == i)
    train_indices <- which(obs_folds != i)
    
    folds[[i]] <- list(
      train = train_indices,
      test = test_indices
    )
  }
  
  # Create result object
  result <- list(
    folds = folds,
    method = "spatial_cluster",
    k = k,
    parameters = list(
      n_clusters = n_clusters,
      cluster_centers = clusters$centers
    )
  )
  
  class(result) <- "spatial_folds"
  
  return(result)
}