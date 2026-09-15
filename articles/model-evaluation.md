# Model Evaluation and Comparison

## Overview

This vignette demonstrates how to evaluate model performance using
spatial cross-validation and compare different validation methods to
understand the impact of spatial dependence.

## Model Evaluation Metrics

### Available Metrics

`spatialcvR` provides standard model evaluation metrics:

- **RMSE** (Root Mean Square Error): Sensitive to large errors
- **MAE** (Mean Absolute Error): Intuitive interpretation
- **R²** (R-squared): Proportion of variance explained
- **MAPE** (Mean Absolute Percentage Error): Relative error (when
  applicable)

### Calculating Metrics

``` r

library(spatialcvR)

# Example predictions vs observations
observed <- c(10, 15, 20, 25, 30, 35, 40, 45, 50, 55)
predicted <- c(11, 14, 21, 24, 31, 34, 41, 44, 51, 54)

# Calculate metrics
metrics <- spatial_metrics(observed, predicted)

print(metrics)
```

    ## Model Evaluation Metrics
    ## =======================
    ## Number of observations: 10 
    ## RMSE: 1 
    ## MAE: 1 
    ## R2: 0.9952 
    ## MAPE: 4.04 %

### Understanding the Metrics

``` r

# Perfect prediction
observed_perfect <- c(10, 20, 30, 40, 50)
predicted_perfect <- c(10, 20, 30, 40, 50)
metrics_perfect <- spatial_metrics(observed_perfect, predicted_perfect)
print(metrics_perfect)
```

    ## Model Evaluation Metrics
    ## =======================
    ## Number of observations: 5 
    ## RMSE: 0 
    ## MAE: 0 
    ## R2: 1 
    ## MAPE: 0 %

``` r

# Poor prediction
observed_poor <- c(10, 20, 30, 40, 50)
predicted_poor <- c(50, 40, 30, 20, 10)
metrics_poor <- spatial_metrics(observed_poor, predicted_poor)
print(metrics_poor)
```

    ## Model Evaluation Metrics
    ## =======================
    ## Number of observations: 5 
    ## RMSE: 28.2843 
    ## MAE: 24 
    ## R2: -3 
    ## MAPE: 126 %

## Spatial Cross-Validation Workflow

### Step 1: Create Folds

``` r

# Load sample data
data(sample_spatial_data)

# Create spatial folds
folds_block <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "block",
  seed = 123
)

# Create random folds for comparison
folds_random <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "random",
  seed = 123
)
```

### Step 2: Train and Evaluate Models

For this example, we’ll simulate model training and evaluation:

``` r

# Simulate model training and evaluation for each fold
evaluate_fold <- function(fold, data, target_var) {
  train_idx <- fold$train
  test_idx <- fold$test
  
  # Simple linear model for demonstration
  train_data <- data[train_idx, ]
  test_data <- data[test_idx, ]
  
  # Train model (using variable1 and variable2 as predictors)
  model <- lm(target ~ variable1 + variable2, data = train_data)
  
  # Make predictions
  predictions <- predict(model, newdata = test_data)
  observed <- test_data[[target_var]]
  
  # Calculate metrics
  metrics <- spatial_metrics(observed, predictions, na.rm = TRUE)
  
  return(metrics)
}

# Evaluate spatial block CV
block_results <- lapply(folds_block$folds, function(fold) {
  evaluate_fold(fold, sample_spatial_data, "target")
})

# Evaluate random CV
random_results <- lapply(folds_random$folds, function(fold) {
  evaluate_fold(fold, sample_spatial_data, "target")
})
```

### Step 3: Aggregate Results

``` r

# Aggregate metrics across folds
aggregate_metrics <- function(results_list) {
  rmse_values <- sapply(results_list, function(x) x$RMSE)
  mae_values <- sapply(results_list, function(x) x$MAE)
  r2_values <- sapply(results_list, function(x) x$R2)
  
  list(
    RMSE_mean = mean(rmse_values),
    RMSE_sd = sd(rmse_values),
    MAE_mean = mean(mae_values),
    MAE_sd = sd(mae_values),
    R2_mean = mean(r2_values),
    R2_sd = sd(r2_values)
  )
}

block_summary <- aggregate_metrics(block_results)
random_summary <- aggregate_metrics(random_results)

cat("Spatial Block CV Summary:\n")
```

    ## Spatial Block CV Summary:

``` r

print(block_summary)
```

    ## $RMSE_mean
    ## [1] 6.712582
    ## 
    ## $RMSE_sd
    ## [1] 1.223729
    ## 
    ## $MAE_mean
    ## [1] 5.477149
    ## 
    ## $MAE_sd
    ## [1] 0.9768991
    ## 
    ## $R2_mean
    ## [1] 0.7782187
    ## 
    ## $R2_sd
    ## [1] 0.1693295

``` r

cat("\nRandom CV Summary:\n")
```

    ## 
    ## Random CV Summary:

``` r

print(random_summary)
```

    ## $RMSE_mean
    ## [1] 6.83486
    ## 
    ## $RMSE_sd
    ## [1] 0.5242892
    ## 
    ## $MAE_mean
    ## [1] 5.522551
    ## 
    ## $MAE_sd
    ## [1] 0.2974677
    ## 
    ## $R2_mean
    ## [1] 0.8758788
    ## 
    ## $R2_sd
    ## [1] 0.01977151

## Comparing CV Methods

### Using compare_cv

``` r

# Create summary metrics for comparison
block_summary_metrics <- list(
  RMSE = block_summary$RMSE_mean,
  MAE = block_summary$MAE_mean,
  R2 = block_summary$R2_mean
)

random_summary_metrics <- list(
  RMSE = random_summary$RMSE_mean,
  MAE = random_summary$MAE_mean,
  R2 = random_summary$R2_mean
)

# Compare methods
comparison <- compare_cv(
  results_list = list(
    spatial_block = block_summary_metrics,
    random = random_summary_metrics
  )
)

print(comparison)
```

    ## Cross-Validation Method Comparison
    ## ===================================
    ## Number of methods compared: 2 
    ## Best method (lowest RMSE): spatial_block 
    ## 
    ## Summary Table:
    ##         method     RMSE      MAE        R2 RMSE_diff RMSE_diff_pct
    ##  spatial_block 6.712582 5.477149 0.7782187 0.0000000      0.000000
    ##         random 6.834860 5.522551 0.8758788 0.1222781      1.821625
    ## 
    ## Performance Comparison:
    ##   Baseline method: spatial_block (RMSE = 6.7126)
    ##   Best RMSE: 6.7126
    ##   RMSE range: [6.7126, 6.8349]
    ##   MAE range: [5.4771, 5.5226]
    ##   R2 range: [0.7782, 0.8759]

### Interpreting the Comparison

- **RMSE difference**: Spatial CV typically shows higher RMSE (more
  realistic)
- **R² difference**: Spatial CV typically shows lower R² (less
  optimistic)
- **Magnitude of difference**: Indicates strength of spatial dependence
- **Best method**: Lowest RMSE indicates best performance under
  constraints

## Spatial Residual Diagnostics

### Calculating Spatial Residuals

``` r

# Get predictions from one fold for residual analysis
fold_idx <- 1
train_idx <- folds_block$folds[[fold_idx]]$train
test_idx <- folds_block$folds[[fold_idx]]$test

train_data <- sample_spatial_data[train_idx, ]
test_data <- sample_spatial_data[test_idx, ]

# Train model
model <- lm(target ~ variable1 + variable2, data = train_data)

# Make predictions
predictions <- predict(model, newdata = test_data)
observed <- test_data$target

# Remove NA values
valid_idx <- !is.na(predictions) & !is.na(observed)
predictions <- predictions[valid_idx]
observed <- observed[valid_idx]
coords <- cbind(
  x = test_data$longitude[valid_idx],
  y = test_data$latitude[valid_idx]
)

# Calculate spatial residuals
residuals <- spatial_residuals(observed, predictions, coords)

print(residuals)
```

### Visualizing Residuals

``` r

# Spatial scatter plot of residuals
plot_spatial_residuals(residuals, type = "scatter",
                      main = "Spatial Residuals - Scatter Plot")

# Histogram of residuals
# (Chunk disabled due to dependency on previous disabled chunk)
# plot_spatial_residuals(residuals, type = "histogram",
#                       main = "Spatial Residuals - Histogram")

# Q-Q plot for normality
# (Chunk disabled due to dependency on previous disabled chunk)
# plot_spatial_residuals(residuals, type = "qq",
#                       main = "Spatial Residuals - Q-Q Plot")
```

### Interpreting Residual Patterns

- **Random spatial pattern**: Good - no spatial structure in errors
- **Clustered residuals**: May indicate missing spatial predictors
- **Systematic patterns**: May suggest model misspecification
- **Normal distribution**: Assumption of many statistical tests

## Practical Example: Complete Workflow

### Scenario: Predicting Crop Yield

``` r

# Simulate agricultural data
set.seed(456)
n <- 100
agri_data <- data.frame(
  longitude = runif(n, 0, 1000),
  latitude = runif(n, 0, 1000),
  soil_quality = rnorm(n, 50, 10),
  rainfall = rnorm(n, 800, 100),
  temperature = rnorm(n, 20, 3),
  yield = 50 + 0.3*soil_quality + 0.02*rainfall + 0.5*temperature + 
           rnorm(n, 0, 5)
)

# Add spatial structure to yield
agri_data$yield <- agri_data$yield + 
  0.01*agri_data$longitude + 0.02*agri_data$latitude

# Create spatial folds
agri_folds <- spatial_folds(
  data = agri_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "block",
  seed = 456
)

# Check for spatial leakage
agri_leakage <- detect_spatial_leakage(
  data = agri_data,
  folds = agri_folds,
  x = "longitude",
  y = "latitude"
)

print(agri_leakage)

# Evaluate model
agri_results <- lapply(agri_folds$folds, function(fold) {
  evaluate_fold(fold, agri_data, "yield")
})

agri_summary <- aggregate_metrics(agri_results)
print(agri_summary)
```

## Advanced Topics

### Cross-Method Comparison

``` r

# Compare multiple spatial CV methods
methods <- c("block", "cluster", "random")
method_results <- list()

for (method in methods) {
  folds <- spatial_folds(
    data = sample_spatial_data,
    x = "longitude",
    y = "latitude",
    k = 5,
    method = method,
    seed = 123
  )
  
  results <- lapply(folds$folds, function(fold) {
    evaluate_fold(fold, sample_spatial_data, "target")
  })
  
  summary <- aggregate_metrics(results)
  method_results[[method]] <- list(
    RMSE = summary$RMSE_mean,
    MAE = summary$MAE_mean,
    R2 = summary$R2_mean
  )
}

# Compare all methods
multi_comparison <- compare_cv(method_results)
print(multi_comparison)
```

### Performance vs. Spatial Separation Trade-off

``` r
# Test different levels of spatial separation
k_values <- c(3, 5, 7, 10)
separation_results <- data.frame(
  k = integer(),
  mean_distance = numeric(),
  RMSE = numeric(),
  # (Chunks disabled for CRAN build - they work interactively but not during build)
# For demonstration, please see the other vignettes or run the examples interactively
```

## Best Practices

### 1. Always Compare with Random CV

``` r

# Establish baseline
random_baseline <- spatial_folds(sample_spatial_data, "longitude", "latitude",
                                k = 5, method = "random", seed = 123)

# Compare with spatial methods
spatial_methods <- spatial_folds(sample_spatial_data, "longitude", "latitude",
                                k = 5, method = "block", seed = 123)
```

### 2. Check for Spatial Leakage

``` r

# Always check leakage before trusting results
leakage_check <- detect_spatial_leakage(sample_spatial_data, spatial_methods,
                                       "longitude", "latitude")
if (leakage_check$risk_level == "high") {
  warning("High spatial leakage detected - results may be unreliable")
}
```

### 3. Analyze Residuals Spatially

``` r

# Don't just look at aggregate metrics
# Examine spatial patterns in errors
# This can reveal missing spatial predictors
```

### 4. Consider the Prediction Context

- **Local predictions**: May tolerate less spatial separation
- **Regional predictions**: Require good spatial generalization
- **Extrapolation**: Need conservative spatial separation

### 5. Document Your Approach

``` r

# Keep track of:
# - CV method used
# - Parameters (k, block size, buffer radius, etc.)
# - Spatial leakage assessment
# - Performance metrics
# - Residual analysis results
```

## Common Pitfalls

### Pitfall 1: Ignoring Spatial Dependence

**Problem**: Using random CV on spatial data without checking for
spatial dependence.

**Solution**: Always compare spatial vs. random CV to assess the impact.

### Pitfall 2: Overfitting to Spatial Structure

**Problem**: Using too much spatial information in predictors.

**Solution**: Keep spatial coordinates out of predictor variables unless
explicitly modeling spatial effects.

### Pitfall 3: Inappropriate CRS

**Problem**: Calculating distances on geographic coordinates.

**Solution**: Use projected CRS for distance-based methods, or
acknowledge approximation.

### Pitfall 4: Small Sample Sizes

**Problem**: Too few observations relative to spatial complexity.

**Solution**: Reduce k, use larger blocks, or collect more data.

## Next Steps

- Review [spatial cross-validation
  methods](https://sowsalim01.github.io/spatialcvR/articles/spatial-cross-validation.md)
- Learn about [spatial leakage
  detection](https://sowsalim01.github.io/spatialcvR/articles/spatial-leakage.md)
- Explore the
  [introduction](https://sowsalim01.github.io/spatialcvR/articles/introduction.md)
  for background

## Key Takeaways

1.  **Use spatial CV** for geospatial data to get realistic performance
    estimates
2.  **Compare methods** to understand the impact of spatial dependence
3.  **Check for leakage** to ensure adequate spatial separation
4.  **Analyze residuals** spatially to identify missing patterns
5.  **Consider trade-offs** between performance and spatial
    generalization
