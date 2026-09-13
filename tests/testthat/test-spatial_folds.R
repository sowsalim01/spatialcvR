# Tests for spatial_folds function

test_that("spatial_folds validates inputs correctly", {
  # Create test data
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  # Test that function works with valid inputs
  expect_silent({
    folds <- spatial_folds(
      data = test_data,
      x = "longitude",
      y = "latitude",
      k = 5,
      method = "block"
    )
  })
  
  # Test that it returns a spatial_folds object
  expect_s3_class(folds, "spatial_folds")
  
  # Test with invalid method
  expect_error(
    spatial_folds(test_data, "longitude", "latitude", k = 5, method = "invalid"),
    "Unknown method"
  )
})

test_that("spatial_folds handles sf objects", {
  skip_if_not_installed("sf")
  
  # Create test sf object
  library(sf)
  coords <- matrix(runif(20, 0, 100), ncol = 2)
  test_sf <- st_sf(geometry = st_sfc(st_point(coords[1,]), st_point(coords[2,])),
                   value = 1:2)
  
  # Test that sf objects work without x/y parameters
  expect_silent({
    folds <- spatial_folds(data = test_sf, k = 2, method = "block")
  })
})

test_that("spatial_folds validates coordinates", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  # Test missing x column
  expect_error(
    spatial_folds(test_data, x = "invalid", y = "latitude", k = 5),
    "not found in data"
  )
  
  # Test missing y column
  expect_error(
    spatial_folds(test_data, x = "longitude", y = "invalid", k = 5),
    "not found in data"
  )
  
  # Test with NA coordinates
  test_data_na <- test_data
  test_data_na$longitude[1] <- NA
  expect_error(
    spatial_folds(test_data_na, "longitude", "latitude", k = 5),
    "Missing values"
  )
})

test_that("spatial_folds validates k parameter", {
  test_data <- data.frame(
    longitude = runif(20, 0, 100),
    latitude = runif(20, 0, 100),
    value = rnorm(20)
  )
  
  # Test k < 2
  expect_error(
    spatial_folds(test_data, "longitude", "latitude", k = 1),
    "at least 2"
  )
  
  # Test k > n
  expect_error(
    spatial_folds(test_data, "longitude", "latitude", k = 25),
    "cannot be greater than"
  )
})

test_that("spatial_folds produces correct fold structure", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds <- spatial_folds(test_data, "longitude", "latitude", k = 5, method = "block")
  
  # Check that folds list has correct length
  expect_equal(length(folds$folds), 5)
  
  # Check that each fold has train and test indices
  for (fold in folds$folds) {
    expect_true("train" %in% names(fold))
    expect_true("test" %in% names(fold))
  }
  
  # Check that train + test = all observations
  all_train <- unlist(lapply(folds$folds, function(f) f$train))
  all_test <- unlist(lapply(folds$folds, function(f) f$test))
  expect_equal(length(unique(c(all_train, all_test))), 50)
})

test_that("spatial_folds is reproducible with seed", {
  test_data <- data.frame(
    longitude = runif(50, 0, 100),
    latitude = runif(50, 0, 100),
    value = rnorm(50)
  )
  
  folds1 <- spatial_folds(test_data, "longitude", "latitude", k = 5, 
                          method = "random", seed = 123)
  folds2 <- spatial_folds(test_data, "longitude", "latitude", k = 5, 
                          method = "random", seed = 123)
  
  expect_equal(folds1$folds, folds2$folds)
})

test_that("spatial_folds warns about duplicate coordinates", {
  test_data <- data.frame(
    longitude = c(1, 1, 2, 3, 4),
    latitude = c(1, 1, 2, 3, 4),
    value = 1:5
  )
  
  expect_warning(
    spatial_folds(test_data, "longitude", "latitude", k = 2, method = "block"),
    "Duplicate coordinates"
  )
})