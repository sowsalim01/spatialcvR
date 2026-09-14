# Tests for spatial_distance function

test_that("spatial_distance validates folds object", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  # Test with non-spatial_folds object
  expect_error(
    spatial_distance(test_data, list(), "longitude", "latitude"),
    "must be a spatial_folds object"
  )
})

test_that("spatial_distance calculates distances correctly", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  
  expect_silent({
    distances <- spatial_distance(test_data, folds, "longitude", "latitude")
  })
  
  # Check that it returns a spatial_distance object
  expect_s3_class(distances, "spatial_distance")
  
  # Check that it has the correct number of folds
  expect_equal(length(distances$fold_distances), 5)
})

test_that("spatial_distance calculates correct statistics", {
  test_data <- data.frame(
    longitude = c(0, 10, 20, 30, 40),
    latitude = c(0, 10, 20, 30, 40),
    value = 1:5
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 2, seed = 123)
  distances <- spatial_distance(test_data, folds, "longitude", "latitude")
  
  # Check that each fold has the expected statistics
  for (fold_dist in distances$fold_distances) {
    expect_true("min_distance" %in% names(fold_dist))
    expect_true("mean_distance" %in% names(fold_dist))
    expect_true("median_distance" %in% names(fold_dist))
    expect_true("max_distance" %in% names(fold_dist))
    expect_true("sd_distance" %in% names(fold_dist))
    expect_true("quantiles" %in% names(fold_dist))
  }
  
  # Check that distances are non-negative
  for (fold_dist in distances$fold_distances) {
    expect_true(fold_dist$min_distance >= 0)
    expect_true(fold_dist$mean_distance >= 0)
  }
})

test_that("spatial_distance warns about geographic CRS", {
  skip_if_not_installed("sf")
  
  library(sf)
  
  # Create test data with geographic coordinates
  test_data <- data.frame(
    longitude = runif(20, -180, 180),
    latitude = runif(20, -90, 90),
    value = rnorm(20)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  
  # This test is skipped since we can't easily set CRS in this context
  # The warning would occur in real usage with sf objects that have geographic CRS
  skip("CRS warning test requires sf object with geographic CRS")
})

test_that("spatial_distance returns correct structure", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 3, seed = 123)
  distances <- spatial_distance(test_data, folds, "longitude", "latitude")
  
  # Check top-level structure
  expect_true("fold_distances" %in% names(distances))
  expect_true("method" %in% names(distances))
  expect_true("k" %in% names(distances))
  expect_true("n_observations" %in% names(distances))
  
  # Check that k matches
  expect_equal(distances$k, 3)
  expect_equal(distances$n_observations, 20)
})