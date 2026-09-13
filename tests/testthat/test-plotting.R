# Tests for plotting functions

test_that("plot_spatial_folds validates folds object", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  # Test with non-spatial_folds object
  expect_error(
    plot_spatial_folds(list(), test_data, "longitude", "latitude"),
    "must be a spatial_folds object"
  )
})

test_that("plot_spatial_folds creates plot for single fold", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  
  # Test that function runs without error
  expect_silent({
    result <- plot_spatial_folds(folds, test_data, "longitude", "latitude", fold = 1)
  })
  
  # Check that it returns the folds object invisibly
  expect_equal(result, folds)
})

test_that("plot_spatial_folds validates fold number", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  
  # Test with invalid fold number
  expect_error(
    plot_spatial_folds(folds, test_data, "longitude", "latitude", fold = 10),
    "must be between 1 and"
  )
})

test_that("plot_spatial_folds handles 'all' folds", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  
  # Test that function runs without error for all folds
  expect_silent({
    result <- plot_spatial_folds(folds, test_data, "longitude", "latitude", fold = "all")
  })
  
  expect_equal(result, folds)
})

test_that("plot_spatial_residuals validates residuals object", {
  # Test with non-spatial_residuals object
  expect_error(
    plot_spatial_residuals(list()),
    "must be a spatial_residuals object"
  )
})

test_that("plot_spatial_residuals creates scatter plot", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  residuals <- spatial_residuals(observed, predicted, coords)
  
  # Test that function runs without error
  expect_silent({
    result <- plot_spatial_residuals(residuals, type = "scatter")
  })
  
  # Check that it returns the residuals object invisibly
  expect_equal(result, residuals)
})

test_that("plot_spatial_residuals creates histogram", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  residuals <- spatial_residuals(observed, predicted, coords)
  
  # Test that function runs without error
  expect_silent({
    result <- plot_spatial_residuals(residuals, type = "histogram")
  })
  
  expect_equal(result, residuals)
})

test_that("plot_spatial_residuals creates qq plot", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  residuals <- spatial_residuals(observed, predicted, coords)
  
  # Test that function runs without error
  expect_silent({
    result <- plot_spatial_residuals(residuals, type = "qq")
  })
  
  expect_equal(result, residuals)
})

test_that("plot_spatial_residuals validates plot type", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  residuals <- spatial_residuals(observed, predicted, coords)
  
  # Test with invalid plot type
  expect_error(
    plot_spatial_residuals(residuals, type = "invalid"),
    "must be one of"
  )
})