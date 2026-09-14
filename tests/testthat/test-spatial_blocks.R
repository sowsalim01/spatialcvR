# Tests for spatial_block_folds function

test_that("spatial_block_folds creates valid folds", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds <- spatial_block_folds(test_data, "longitude", "latitude", k = 5)
  
  # Check that it returns a spatial_folds object
  expect_s3_class(folds, "spatial_folds")
  
  # Check method name
  expect_equal(folds$method, "spatial_block")
  
  # Check number of folds
  expect_equal(folds$k, 5)
})

test_that("spatial_block_folds handles block_size parameter", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  # Test with valid block_size
  expect_silent({
    folds <- spatial_block_folds(test_data, "longitude", "latitude", k = 5,
                                  block_size = c(20, 20))
  })
  
  # Test with invalid block_size (negative)
  expect_error(
    spatial_block_folds(test_data, "longitude", "latitude", k = 5,
                        block_size = c(-10, 20)),
    "must be positive"
  )
  
  # Test with invalid block_size (wrong length)
  expect_error(
    spatial_block_folds(test_data, "longitude", "latitude", k = 5,
                        block_size = c(20)),
    "vector of length 2"
  )
})

test_that("spatial_block_folds handles n_blocks parameter", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  # Test with valid n_blocks
  expect_silent({
    folds <- spatial_block_folds(test_data, "longitude", "latitude", k = 5,
                                  n_blocks = c(3, 3))
  })
  
  # Test with invalid n_blocks (negative)
  expect_error(
    spatial_block_folds(test_data, "longitude", "latitude", k = 5,
                        n_blocks = c(-3, 3)),
    "must be positive"
  )
})

test_that("spatial_block_folds handles assignment strategies", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  # Test systematic assignment
  folds_systematic <- spatial_block_folds(test_data, "longitude", "latitude", 
                                           k = 5, assignment = "systematic")
  expect_equal(folds_systematic$parameters$assignment, "systematic")
  
  # Test random assignment
  folds_random <- spatial_block_folds(test_data, "longitude", "latitude", 
                                       k = 5, assignment = "random")
  expect_equal(folds_random$parameters$assignment, "random")
  
  # Test invalid assignment
  expect_error(
    spatial_block_folds(test_data, "longitude", "latitude", k = 5,
                        assignment = "invalid"),
    "must be one of|doit être un de"
  )
})

test_that("spatial_block_folds reduces k when insufficient blocks", {
  test_data <- data.frame(
    longitude = runif(10, 0, 100),
    latitude = runif(10, 0, 100),
    value = rnorm(10)
  )
  
  # Request more folds than available blocks
  expect_warning(
    folds <- spatial_block_folds(test_data, "longitude", "latitude", k = 10,
                                  n_blocks = c(2, 2)),
    "reducing k"
  )
  
  # Check that k was reduced
  expect_true(folds$k <= 4)  # 2x2 = 4 blocks max
})

test_that("spatial_block_folds is reproducible with seed", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds1 <- spatial_block_folds(test_data, "longitude", "latitude", k = 5,
                                assignment = "random", seed = 123)
  folds2 <- spatial_block_folds(test_data, "longitude", "latitude", k = 5,
                                assignment = "random", seed = 123)
  
  expect_equal(folds1$folds, folds2$folds)
})

test_that("spatial_block_folds handles edge cases", {
  # Test with minimal data
  test_data <- data.frame(
    longitude = c(0, 10, 20),
    latitude = c(0, 10, 20),
    value = 1:3
  )
  
  folds <- spatial_block_folds(test_data, "longitude", "latitude", k = 2)
  
  # Should still create valid folds
  expect_s3_class(folds, "spatial_folds")
  expect_true(folds$k >= 2)
})