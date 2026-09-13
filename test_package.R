# Script to test the basic functionality of spatialcvR
# Run this script in R to validate the package implementation

# Install/load devtools if needed
if (!require("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Load the package
devtools::load_all()

cat("=== Testing spatialcvR Package ===\n\n")

# Test 1: Load sample data
cat("Test 1: Loading sample data...\n")
data(sample_spatial_data)
cat("  Sample data loaded successfully\n")
cat("  Dimensions:", dim(sample_spatial_data), "\n\n")

# Test 2: Create spatial folds with block method
cat("Test 2: Creating spatial block folds...\n")
folds_block <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "block",
  seed = 123
)
print(folds_block)
cat("\n")

# Test 3: Create spatial folds with cluster method
cat("Test 3: Creating spatial cluster folds...\n")
folds_cluster <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "cluster",
  seed = 123
)
print(folds_cluster)
cat("\n")

# Test 4: Create spatial folds with random method
cat("Test 4: Creating random spatial folds...\n")
folds_random <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "random",
  seed = 123
)
print(folds_random)
cat("\n")

# Test 5: Test spatial_block_folds directly
cat("Test 5: Testing spatial_block_folds directly...\n")
folds_direct <- spatial_block_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  block_size = c(200, 200),
  seed = 123
)
print(folds_direct)
cat("\n")

# Test 6: Test reproducibility
cat("Test 6: Testing reproducibility with seed...\n")
folds1 <- spatial_folds(sample_spatial_data, "longitude", "latitude", k = 5, 
                       method = "random", seed = 42)
folds2 <- spatial_folds(sample_spatial_data, "longitude", "latitude", k = 5, 
                       method = "random", seed = 42)
if (all.equal(folds1$folds, folds2$folds)) {
  cat("  Reproducibility test: PASSED\n")
} else {
  cat("  Reproducibility test: FAILED\n")
}
cat("\n")

# Test 7: Test error handling
cat("Test 7: Testing error handling...\n")
tryCatch({
  spatial_folds(sample_spatial_data, "invalid_col", "latitude", k = 5)
  cat("  Error handling test: FAILED (should have thrown error)\n")
}, error = function(e) {
  cat("  Error handling test: PASSED (correctly caught invalid column)\n")
})
cat("\n")

# Test 8: Test spatial_metrics
cat("Test 8: Testing spatial_metrics...\n")
observed <- sample_spatial_data$target[1:10]
predicted <- observed + rnorm(10, 0, 0.5)
metrics <- spatial_metrics(observed, predicted)
print(metrics)
cat("\n")

# Test 9: Test spatial_distance
cat("Test 9: Testing spatial_distance...\n")
folds <- spatial_folds(sample_spatial_data, "longitude", "latitude", k = 5, seed = 123)
distances <- spatial_distance(sample_spatial_data, folds, "longitude", "latitude")
print(distances)
cat("\n")

# Test 10: Test detect_spatial_leakage
cat("Test 10: Testing detect_spatial_leakage...\n")
leakage <- detect_spatial_leakage(sample_spatial_data, folds, "longitude", "latitude")
print(leakage)
cat("\n")

# Test 11: Test spatial_residuals
cat("Test 11: Testing spatial_residuals...\n")
coords <- cbind(x = sample_spatial_data$longitude[1:10], 
                y = sample_spatial_data$latitude[1:10])
residuals <- spatial_residuals(observed, predicted, coords)
print(residuals)
cat("\n")

# Test 12: Test compare_cv
cat("Test 12: Testing compare_cv...\n")
results <- list(
  random = list(RMSE = 0.5, MAE = 0.4, R2 = 0.8),
  block = list(RMSE = 0.7, MAE = 0.6, R2 = 0.6)
)
comparison <- compare_cv(results)
print(comparison)
cat("\n")

# Test 13: Run unit tests
cat("Test 13: Running unit tests...\n")
test_results <- devtools::test()
cat("  Unit tests completed\n")
cat("  Summary:", test_results$passed, "passed,", test_results$failed, "failed,",
    test_results$skipped, "skipped\n\n")

cat("=== Validation Complete ===\n")
cat("If all tests passed, the package is ready for the next development phase.\n")