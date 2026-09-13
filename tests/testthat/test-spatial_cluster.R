# Tests for spatial_cluster_folds function

test_that("spatial_cluster_folds creates valid folds", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds <- spatial_cluster_folds(test_data, "longitude", "latitude", k = 5)
  
  # Check that it returns a spatial_folds object
  expect_s3_class(folds, "spatial_folds")
  
  # Check method name
  expect_equal(folds$method, "spatial_cluster")
  
  # Check number of folds
  expect_equal(folds$k, 5)
})

test_that("spatial_cluster_folds handles n_clusters parameter", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  # Test with default n_clusters (should equal k)
  folds_default <- spatial_cluster_folds(test_data, "longitude", "latitude", k = 5)
  expect_equal(folds_default$parameters$n_clusters, 5)
  
  # Test with custom n_clusters
  folds_custom <- spatial_cluster_folds(test_data, "longitude", "latitude", 
                                        k = 5, n_clusters = 10)
  expect_equal(folds_custom$parameters$n_clusters, 10)
  
  # Test with invalid n_clusters (less than k)
  expect_error(
    spatial_cluster_folds(test_data, "longitude", "latitude", k = 5, n_clusters = 3),
    "at least equal to k"
  )
})

test_that("spatial_cluster_folds stores cluster centers", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds <- spatial_cluster_folds(test_data, "longitude", "latitude", k = 5, n_clusters = 8)
  
  # Check that cluster centers are stored
  expect_true("cluster_centers" %in% names(folds$parameters))
  
  # Check dimensions of cluster centers
  expect_equal(nrow(folds$parameters$cluster_centers), 8)
  expect_equal(ncol(folds$parameters$cluster_centers), 2)
})

test_that("spatial_cluster_folds is reproducible with seed", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds1 <- spatial_cluster_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  folds2 <- spatial_cluster_folds(test_data, "longitude", "latitude", k = 5, seed = 123)
  
  expect_equal(folds1$folds, folds2$folds)
})

test_that("spatial_cluster_folds handles minimal data", {
  test_data <- data.frame(
    longitude = c(0, 10, 20, 30),
    latitude = c(0, 10, 20, 30),
    value = 1:4
  )
  
  folds <- spatial_cluster_folds(test_data, "longitude", "latitude", k = 2)
  
  # Should still create valid folds
  expect_s3_class(folds, "spatial_folds")
  expect_true(folds$k >= 2)
})