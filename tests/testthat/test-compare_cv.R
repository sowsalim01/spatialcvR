# Tests for compare_cv function

test_that("compare_cv validates inputs", {
  # Test with non-list input
  expect_error(
    compare_cv("not a list"),
    "must be a list"
  )
  
  # Test with single method
  expect_error(
    compare_cv(list(method1 = list(RMSE = 0.5))),
    "At least 2 methods"
  )
})

test_that("compare_cv handles spatial_metrics objects", {
  results <- list(
    random = spatial_metrics(c(1, 2, 3, 4, 5), c(1.1, 2.2, 2.8, 4.1, 4.9)),
    block = spatial_metrics(c(1, 2, 3, 4, 5), c(1.2, 2.3, 2.9, 4.2, 5.0))
  )
  
  expect_silent({
    comparison <- compare_cv(results)
  })
  
  # Check that it returns a cv_comparison object
  expect_s3_class(comparison, "cv_comparison")
})

test_that("compare_cv handles list results", {
  results <- list(
    random = list(RMSE = 0.5, MAE = 0.4, R2 = 0.8),
    block = list(RMSE = 0.7, MAE = 0.6, R2 = 0.6)
  )
  
  expect_silent({
    comparison <- compare_cv(results)
  })
  
  expect_s3_class(comparison, "cv_comparison")
})

test_that("compare_cv identifies best method", {
  results <- list(
    random = list(RMSE = 0.7, MAE = 0.6, R2 = 0.6),
    block = list(RMSE = 0.5, MAE = 0.4, R2 = 0.8),
    cluster = list(RMSE = 0.6, MAE = 0.5, R2 = 0.7)
  )
  
  comparison <- compare_cv(results)
  
  # Block should be best (lowest RMSE)
  expect_equal(comparison$best_method, "block")
})

test_that("compare_cv calculates performance differences", {
  results <- list(
    random = list(RMSE = 0.5, MAE = 0.4, R2 = 0.8),
    block = list(RMSE = 0.7, MAE = 0.6, R2 = 0.6)
  )
  
  comparison <- compare_cv(results)
  
  # Check that RMSE differences are calculated
  expect_true("RMSE_diff" %in% names(comparison$summary))
  expect_true("RMSE_diff_pct" %in% names(comparison$summary))
  
  # First method should have zero difference (baseline)
  expect_equal(comparison$summary$RMSE_diff[1], 0)
})

test_that("compare_cv returns correct structure", {
  results <- list(
    random = list(RMSE = 0.5, MAE = 0.4, R2 = 0.8),
    block = list(RMSE = 0.7, MAE = 0.6, R2 = 0.6)
  )
  
  comparison <- compare_cv(results)
  
  # Check top-level structure
  expect_true("summary" %in% names(comparison))
  expect_true("best_method" %in% names(comparison))
  expect_true("n_methods" %in% names(comparison))
  expect_true("comparison" %in% names(comparison))
  
  # Check summary structure
  expect_true("method" %in% names(comparison$summary))
  expect_true("RMSE" %in% names(comparison$summary))
  expect_true("MAE" %in% names(comparison$summary))
  expect_true("R2" %in% names(comparison$summary))
})

test_that("compare_cv handles custom method names", {
  results <- list(
    list(RMSE = 0.5, MAE = 0.4, R2 = 0.8),
    list(RMSE = 0.7, MAE = 0.6, R2 = 0.6)
  )
  
  comparison <- compare_cv(results, methods = c("Method A", "Method B"))
  
  # Check that custom names are used
  expect_equal(comparison$summary$method[1], "Method A")
  expect_equal(comparison$summary$method[2], "Method B")
})

test_that("compare_cv handles missing metrics gracefully", {
  results <- list(
    random = list(RMSE = 0.5, MAE = 0.4),  # Missing R2
    block = list(RMSE = 0.7, R2 = 0.6)     # Missing MAE
  )
  
  # Should handle missing metrics by skipping incomplete results
  expect_error(
    comparison <- compare_cv(results),
    "Insufficient valid results"
  )
})