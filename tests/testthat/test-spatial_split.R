# Tests for spatial_split function

test_that("spatial_split creates valid folds", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds <- spatial_split(test_data, "longitude", "latitude", k = 5)
  
  # Check that it returns a spatial_folds object
  expect_s3_class(folds, "spatial_folds")
  
  # Check method name
  expect_equal(folds$method, "random")
  
  # Check number of folds
  expect_equal(folds$k, 5)
})

test_that("spatial_split is reproducible with seed", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds1 <- spatial_split(test_data, "longitude", "latitude", k = 5, seed = 123)
  folds2 <- spatial_split(test_data, "longitude", "latitude", k = 5, seed = 123)
  
  expect_equal(folds1$folds, folds2$folds)
})

test_that("spatial_split handles minimal data", {
  test_data <- data.frame(
    longitude = c(0, 10),
    latitude = c(0, 10),
    value = 1:2
  )
  
  folds <- spatial_split(test_data, "longitude", "latitude", k = 2)
  
  # Should create valid folds
  expect_s3_class(folds, "spatial_folds")
  expect_equal(folds$k, 2)
})