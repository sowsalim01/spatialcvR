# Spatial block cross-validation implementation

#' Spatial Block Cross-Validation
#'
#' Creates spatial cross-validation folds by dividing the study area into 
#' rectangular blocks and assigning observations to folds based on their 
#' block membership. This method ensures spatial separation between training 
#' and test sets.
#'
#' @param data Spatial observations (data.frame or sf object)
#' @param x Name of the x coordinate column (required for data.frame, ignored for sf)
#' @param y Name of the y coordinate column (required for data.frame, ignored for sf)
#' @param k Number of folds (default: 5)
#' @param block_size Size of blocks as c(width, height) in coordinate units
#' @param n_blocks Number of blocks in x and y directions as c(nx, ny)
#' @param assignment Strategy for assigning blocks to folds: "systematic" or "random"
#' @param seed Random seed for reproducibility (default: NULL)
#'
#' @return An object of class "spatial_folds" containing fold assignments
#'
#' @details
#' The spatial block method divides the spatial extent into a grid of rectangular 
#' blocks. Two approaches are available:
#' 
#' \itemize{
#'   \item Fixed block size: Specify block_size to control block dimensions
#'   \item Fixed number of blocks: Specify n_blocks to control grid resolution
#' }
#' 
#' If neither is specified, the function attempts to create approximately sqrt(k) 
#' blocks in each direction.
#' 
#' Assignment strategies:
#' \itemize{
#'   \item "systematic": Assigns blocks to folds in a systematic pattern
#'   \item "random": Randomly assigns blocks to folds
#' }
#'
#' @examples
#' \dontrun{
#' data(sample_spatial_data)
#' folds <- spatial_block_folds(
#'   data = sample_spatial_data,
#'   x = "longitude",
#'   y = "latitude",
#'   k = 5,
#'   block_size = c(200, 200)
#' )
#' }
#'
#' @export
#' @family spatial cross-validation functions
spatial_block_folds <- function(data, 
                                x = NULL, 
                                y = NULL, 
                                k = 5,
                                block_size = NULL,
                                n_blocks = NULL,
                                assignment = "systematic",
                                seed = NULL) {
  
  # Set seed for reproducibility
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # Validate coordinates
  coord_info <- .validate_coordinates(data, x, y)
  
  # Validate k
  k <- .validate_k(k, coord_info$n)
  
  # Validate assignment strategy
  assignment <- match.arg(assignment, c("systematic", "random"))
  
  # Extract coordinates
  x_coords <- coord_info$x
  y_coords <- coord_info$y
  
  # Determine block grid
  if (!is.null(block_size)) {
    # User specified block size
    if (length(block_size) != 2) {
      stop("block_size must be a vector of length 2: c(width, height)")
    }
    if (any(block_size <= 0)) {
      stop("block_size values must be positive")
    }
    
    # Calculate number of blocks needed
    x_range <- range(x_coords)
    y_range <- range(y_coords)
    x_span <- x_range[2] - x_range[1]
    y_span <- y_range[2] - y_range[1]
    
    nx <- max(1, ceiling(x_span / block_size[1]))
    ny <- max(1, ceiling(y_span / block_size[2]))
    
  } else if (!is.null(n_blocks)) {
    # User specified number of blocks
    if (length(n_blocks) != 2) {
      stop("n_blocks must be a vector of length 2: c(nx, ny)")
    }
    if (any(n_blocks < 1)) {
      stop("n_blocks values must be positive integers")
    }
    
    nx <- as.integer(n_blocks[1])
    ny <- as.integer(n_blocks[2])
    
  } else {
    # Default: create roughly sqrt(k) blocks in each direction
    n_blocks_side <- max(2, ceiling(sqrt(k)))
    nx <- n_blocks_side
    ny <- n_blocks_side
  }
  
  # Calculate block boundaries
  x_range <- range(x_coords)
  y_range <- range(y_coords)
  x_span <- x_range[2] - x_range[1]
  y_span <- y_range[2] - y_range[1]
  
  x_breaks <- seq(x_range[1], x_range[2], length.out = nx + 1)
  y_breaks <- seq(y_range[1], y_range[2], length.out = ny + 1)
  
  # Assign each observation to a block
  x_block <- cut(x_coords, breaks = x_breaks, labels = FALSE, include.lowest = TRUE)
  y_block <- cut(y_coords, breaks = y_breaks, labels = FALSE, include.lowest = TRUE)
  
  # Handle edge cases where points fall exactly on boundaries
  x_block[is.na(x_block)] <- nx
  y_block[is.na(y_block)] <- ny
  
  # Create block IDs
  block_ids <- (y_block - 1) * nx + x_block
  
  # Get unique blocks
  unique_blocks <- sort(unique(block_ids))
  n_unique_blocks <- length(unique_blocks)
  
  if (n_unique_blocks < k) {
    warning(paste("Only", n_unique_blocks, "unique blocks available, reducing k to", n_unique_blocks))
    k <- n_unique_blocks
  }
  
  # Assign blocks to folds
  if (assignment == "systematic") {
    # Systematic assignment: assign blocks in order
    block_folds <- rep(1:k, length.out = n_unique_blocks)
  } else {
    # Random assignment
    block_folds <- sample(rep(1:k, length.out = n_unique_blocks))
  }
  
  names(block_folds) <- unique_blocks
  
  # Assign each observation to a fold based on its block
  obs_folds <- block_folds[as.character(block_ids)]
  
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
    method = "spatial_block",
    k = k,
    parameters = list(
      block_size = block_size,
      n_blocks = c(nx, ny),
      assignment = assignment,
      x_breaks = x_breaks,
      y_breaks = y_breaks
    )
  )
  
  class(result) <- "spatial_folds"
  
  return(result)
}