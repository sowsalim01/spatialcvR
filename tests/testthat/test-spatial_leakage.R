# Tests for detect_spatial_leakage function

test_that("detect_spatial_leakage validates folds object", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  # Test with non-spatial_folds object
  expect_error(
    detect_spatial_leakage(test_data, list(), "longitude", "latitude"),
    "must be a spatial_folds object"
  )
})

test_that("detect_spatial_leakage analyzes distances correctly", {
  test_data <- data.frame(
    longitude = runif(30, 0, 100),
    latitude = runif(30, 0, 100),
    value = rnorm(30)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  
  expect_silent({
    leakage <- detect_spatial_leakage(test_data, folds, "longitude", "latitude")
  })
  
  # Check that it returns a spatial_leakage_result object
  expect_s3_class(leakage, "spatial_leakage_result")
})

test_that("detect_spatial_leakage calculates summary statistics", {
  test_data <- data.frame(
    longitude = runif(30, 0, 100),
    latitude = runif(30, 0, 100),
    value = rnorm(30)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  leakage <- detect_spatial_leakage(test_data, folds, "longitude", "latitude")
  
  # Check that summary statistics are present
  expect_true("min_distance" %in% names(leakage$summary_statistics))
  expect_true("mean_distance" %in% names(leakage$summary_statistics))
  expect_true("median_distance" %in% names(leakage$summary_statistics))
  expect_true("proportion_below_threshold" %in% names(leakage$summary_statistics))
  
  # Check that distances are non-negative
  expect_true(leakage$summary_statistics$min_distance >= 0)
  expect_true(leakage$summary_statistics$mean_distance >= 0)
})

test_that("detect_spatial_leakage assesses risk levels", {
  test_data <- data.frame(
    longitude = runif(30, 0, 100),
    latitude = runif(30, 0, 100),
    value = rnorm(30)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  leakage <- detect_spatial_leakage(test_data, folds, "longitude", "latitude")
  
  # Check that risk level is one of the expected values
  expect_true(leakage$risk_level %in% c("low", "moderate", "high"))
})

test_that("detect_spatial_leakage provides recommendations", {
  test_data <- data.frame(
    longitude = runif(30, 0, 100),
    latitude = runif(30, 0, 100),
    value = rnorm(30)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  leakage <- detect_spatial_leakage(test_data, folds, "longitude", "latitude")
  
  # Check that recommendations are provided
  expect_true(length(leakage$recommendations) > 0)
  expect_true(is.character(leakage$recommendations))
})

test_that("detect_spatial_leakage accepts custom threshold", {
  test_data <- data.frame(
    longitude = runif(30, 0, 100),
    latitude = runif(30, 0, 100),
    value = rnorm(30)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  
  # Test with custom threshold
  expect_silent({
    leakage <- detect_spatial_leakage(test_data, folds, "longitude", "latitude", 
                                      threshold = 50)
  })
  
  # Check that threshold is stored
  expect_equal(leakage$threshold, 50)
})

test_that("detect_spatial_leakage analyzes each fold", {
  test_data <- data.frame(
    longitude = runif(30, 0, 100),
    latitude = runif(30, 0, 100),
    value = rnorm(30)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  leakage <- detect_spatial_leakage(test_data, folds, "longitude", "latitude")
  
  # Check that fold analysis has correct length
  expect_equal(length(leakage$fold_analysis), 5)
  
  # Check that each fold has required fields
  for (fold in leakage$fold_analysis) {
    expect_true("fold" %in% names(fold))
    expect_true("min_distance" %in% names(fold))
    expect_true("mean_distance" %in% names(fold))
    expect_true("proportion_below_threshold" %in% names(fold))
    expect_true("risk_level" %in% names(fold))
    
    # Check that risk level is valid
    expect_true(fold$risk_level %in% c("low", "moderate", "high"))
  }
})

test_that("detect_spatial_leakage returns correct structure", {
  test_data <- data.frame(
    longitude = runif(30, 0, 100),
    latitude = runif(30, 0, 100),
    value = rnorm(30)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  leakage <- detect_spatial_leakage(test_data, folds, "longitude", "latitude")
  
  # Check top-level structure
  expect_true("method" %in% names(leakage))
  expect_true("fold_analysis" %in% names(leakage))
  expect_true("summary_statistics" %in% names(leakage))
  expect_true("risk_level" %in% names(leakage))
  expect_true("recommendations" %in% names(leakage))
  expect_true("threshold" %in% names(leakage))
  expect_true("risk_levels" %in% names(leakage))
})