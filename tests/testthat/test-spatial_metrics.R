# Tests for spatial_metrics function

test_that("spatial_metrics validates inputs", {
  # Test with valid inputs
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  
  expect_silent({
    metrics <- spatial_metrics(observed, predicted)
  })
  
  # Test that it returns a spatial_metrics object
  expect_s3_class(metrics, "spatial_metrics")
})

test_that("spatial_metrics requires numeric inputs", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  
  # Test with non-numeric observed
  expect_error(
    spatial_metrics(c("a", "b", "c"), predicted),
    "must be numeric"
  )
  
  # Test with non-numeric predicted
  expect_error(
    spatial_metrics(observed, c("a", "b", "c")),
    "must be numeric"
  )
})

test_that("spatial_metrics requires equal length vectors", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1)
  
  expect_error(
    spatial_metrics(observed, predicted),
    "same length"
  )
})

test_that("spatial_metrics handles NA values", {
  observed <- c(1, 2, NA, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  
  # Test with na.rm = TRUE (default)
  expect_silent({
    metrics <- spatial_metrics(observed, predicted, na.rm = TRUE)
  })
  expect_equal(metrics$n, 4)  # Should have 4 non-NA observations
  
  # Test with na.rm = FALSE
  expect_error(
    spatial_metrics(observed, predicted, na.rm = FALSE),
    "NA values found"
  )
})

test_that("spatial_metrics requires minimum observations", {
  observed <- c(1)
  predicted <- c(1.1)
  
  expect_error(
    spatial_metrics(observed, predicted),
    "At least 2 non-NA observations"
  )
})

test_that("spatial_metrics calculates RMSE correctly", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1, 2, 3, 4, 5)  # Perfect prediction
  
  metrics <- spatial_metrics(observed, predicted)
  expect_equal(metrics$RMSE, 0)
  
  # Test with some error
  predicted <- c(2, 3, 4, 5, 6)  # All off by 1
  metrics <- spatial_metrics(observed, predicted)
  expect_equal(metrics$RMSE, 1)
})

test_that("spatial_metrics calculates MAE correctly", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1, 2, 3, 4, 5)  # Perfect prediction
  
  metrics <- spatial_metrics(observed, predicted)
  expect_equal(metrics$MAE, 0)
  
  # Test with some error
  predicted <- c(2, 3, 4, 5, 6)  # All off by 1
  metrics <- spatial_metrics(observed, predicted)
  expect_equal(metrics$MAE, 1)
})

test_that("spatial_metrics calculates R2 correctly", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1, 2, 3, 4, 5)  # Perfect prediction
  
  metrics <- spatial_metrics(observed, predicted)
  expect_equal(metrics$R2, 1)
  
  # Test with prediction equal to mean (worst case)
  predicted <- rep(mean(observed), 5)
  metrics <- spatial_metrics(observed, predicted)
  expect_equal(metrics$R2, 0)
})

test_that("spatial_metrics handles MAPE calculation", {
  observed <- c(10, 20, 30, 40, 50)
  predicted <- c(11, 22, 33, 44, 55)  # 10% error each
  
  metrics <- spatial_metrics(observed, predicted)
  expect_false(is.na(metrics$MAPE))
  expect_equal(metrics$MAPE, 10)  # Should be 10%
  
  # Test with zeros in observed (MAPE should be NA)
  observed <- c(0, 1, 2, 3, 4)
  predicted <- c(0, 1, 2, 3, 4)
  metrics <- spatial_metrics(observed, predicted)
  expect_true(is.na(metrics$MAPE))
})

test_that("spatial_metrics handles constant observed values", {
  observed <- c(5, 5, 5, 5, 5)
  predicted <- c(5, 5, 5, 5, 5)  # Perfect prediction
  
  metrics <- spatial_metrics(observed, predicted)
  expect_equal(metrics$R2, 1)  # Should be 1 for perfect prediction
  
  # Test with imperfect prediction
  predicted <- c(6, 6, 6, 6, 6)
  metrics <- spatial_metrics(observed, predicted)
  expect_equal(metrics$R2, 0)  # Should be 0 when SS_tot = 0
})

test_that("spatial_metrics returns correct structure", {
  observed <- c(1, 2, 3, 4, 5)
  predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
  
  metrics <- spatial_metrics(observed, predicted)
  
  # Check that all expected fields are present
  expect_true("n" %in% names(metrics))
  expect_true("RMSE" %in% names(metrics))
  expect_true("MAE" %in% names(metrics))
  expect_true("R2" %in% names(metrics))
  expect_true("MAPE" %in% names(metrics))
  
  # Check that all values are numeric
  expect_true(is.numeric(metrics$n))
  expect_true(is.numeric(metrics$RMSE))
  expect_true(is.numeric(metrics$MAE))
  expect_true(is.numeric(metrics$R2))
})