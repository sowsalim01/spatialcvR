# Tests for spatial_buffer_folds function

test_that("spatial_buffer_folds creates valid folds", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds <- spatial_buffer_folds(test_data, "longitude", "latitude", k = 5, 
                                 buffer_radius = 10)
  
  # Check that it returns a spatial_folds object
  expect_s3_class(folds, "spatial_folds")
  
  # Check method name
  expect_equal(folds$method, "spatial_buffer")
  
  # Check number of folds
  expect_equal(folds$k, 5)
})

test_that("spatial_buffer_folds requires buffer_radius", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  # Test without buffer_radius
  expect_error(
    spatial_buffer_folds(test_data, "longitude", "latitude", k = 5),
    "buffer_radius must be specified"
  )
})

test_that("spatial_buffer_folds validates buffer_radius", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  # Test with negative buffer_radius
  expect_error(
    spatial_buffer_folds(test_data, "longitude", "latitude", k = 5, buffer_radius = -10),
    "must be a positive numeric value"
  )
  
  # Test with non-numeric buffer_radius
  expect_error(
    spatial_buffer_folds(test_data, "longitude", "latitude", k = 5, buffer_radius = "invalid"),
    "must be a positive numeric value"
  )
})

test_that("spatial_buffer_folds is reproducible with seed", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds1 <- spatial_buffer_folds(test_data, "longitude", "latitude", k = 5, 
                                 buffer_radius = 10, seed = 123)
  folds2 <- spatial_buffer_folds(test_data, "longitude", "latitude", k = 5, 
                                 buffer_radius = 10, seed = 123)
  
  expect_equal(folds1$folds, folds2$folds)
})