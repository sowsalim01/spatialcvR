# Tests for spatial_residuals function

test_that("spatial_residuals validates inputs", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  
  # Test with valid inputs
  expect_silent({
    residuals <- spatial_residuals(observed, predicted, coords)
  })
  
  # Check that it returns a spatial_residuals object
  expect_s3_class(residuals, "spatial_residuals")
})

test_that("spatial_residuals requires numeric inputs", {
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  
  # Test with non-numeric observed
  expect_error(
    spatial_residuals(c("a", "b", "c"), c(1, 2, 3), coords),
    "must be numeric"
  )
  
  # Test with non-numeric predicted
  expect_error(
    spatial_residuals(c(1, 2, 3), c("a", "b", "c"), coords),
    "must be numeric"
  )
})

test_that("spatial_residuals requires equal length vectors", {
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  
  expect_error(
    spatial_residuals(c(1, 2, 3, 4, 5), c(1, 2, 3, 4), coords),
    "same length"
  )
})

test_that("spatial_residuals handles matrix coordinates", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  
  expect_silent({
    residuals <- spatial_residuals(observed, predicted, coords)
  })
  
  expect_s3_class(residuals, "spatial_residuals")
})

test_that("spatial_residuals handles data.frame coordinates", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  coords <- data.frame(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  
  expect_silent({
    residuals <- spatial_residuals(observed, predicted, coords, x = "x", y = "y")
  })
  
  expect_s3_class(residuals, "spatial_residuals")
})

test_that("spatial_residuals validates coordinate dimensions", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  coords <- cbind(x = c(0, 1, 2), y = c(0, 1, 2))  # Wrong length
  
  expect_error(
    spatial_residuals(observed, predicted, coords),
    "must match length"
  )
})

test_that("spatial_residuals calculates correct statistics", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1, 2, 3, 4, 5)  # Perfect prediction
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  
  residuals <- spatial_residuals(observed, predicted, coords)
  
  # Check that residuals are zero
  expect_equal(residuals$statistics$mean, 0)
  expect_equal(residuals$statistics$median, 0)
  expect_equal(residuals$statistics$sd, 0)
})

test_that("spatial_residuals returns correct structure", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
  
  residuals <- spatial_residuals(observed, predicted, coords)
  
  # Check that all expected fields are present
  expect_true("residuals" %in% names(residuals))
  expect_true("observed" %in% names(residuals))
  expect_true("predicted" %in% names(residuals))
  expect_true("coordinates" %in% names(residuals))
  expect_true("statistics" %in% names(residuals))
  expect_true("n" %in% names(residuals))
  
  # Check statistics structure
  expect_true("mean" %in% names(residuals$statistics))
  expect_true("median" %in% names(residuals$statistics))
  expect_true("sd" %in% names(residuals$statistics))
})