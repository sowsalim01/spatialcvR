# Spatial Leakage Detection

## Understanding Spatial Leakage

Spatial leakage occurs when training and test observations are too close
spatially, leading to over-optimistic performance estimates. This
vignette explains how to detect and assess spatial leakage using
`spatialcvR`.

## What is Spatial Leakage?

### Definition

Spatial leakage happens when the spatial separation between training and
test sets is insufficient, allowing the model to “cheat” by learning
local spatial patterns that don’t generalize to new areas.

### Consequences

- **Inflated performance metrics**: RMSE, MAE, R² appear better than
  reality
- **Poor real-world performance**: Model fails when applied to new
  geographic areas
- **Misleading model selection**: Suboptimal models may appear superior
- **Overconfidence**: Uncertainty in model performance is underestimated

## Detecting Spatial Leakage

### Basic Usage

``` r

library(spatialcvR)

# Load sample data
data(sample_spatial_data)

# Create spatial folds
folds <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "block",
  seed = 123
)

# Detect spatial leakage
leakage <- detect_spatial_leakage(
  data = sample_spatial_data,
  folds = folds,
  x = "longitude",
  y = "latitude"
)

print(leakage)
```

    ## Spatial Leakage Detection
    ## =========================
    ## Method: spatial_block 
    ## Overall Risk Level: LOW 
    ## Distance Threshold: 53.04 
    ## 
    ## Summary Statistics:
    ##   Min distance: 11.24
    ##   Mean distance: 521.24
    ##   Median distance: 530.91
    ##   Proportion below threshold: 0.1%
    ## 
    ## Fold Analysis:
    ##   Fold 1: LOW risk (0.1% below threshold)
    ##   Fold 2: LOW risk (0.0% below threshold)
    ##   Fold 3: LOW risk (0.1% below threshold)
    ##   Fold 4: LOW risk (0.2% below threshold)
    ##   Fold 5: LOW risk (0.1% below threshold)
    ## 
    ## Recommendations:
    ##   - Spatial separation appears adequate. 
    ##   - Current cross-validation setup should provide reliable performance estimates. 
    ##   - Consider increasing spatial separation if you need more conservative estimates.

### Understanding the Output

The leakage detection provides:

1.  **Overall risk level**: Low, moderate, or high
2.  **Distance statistics**: Minimum, mean, median distances
3.  **Proportion below threshold**: Percentage of too-close pairs
4.  **Fold-by-fold analysis**: Risk assessment for each fold
5.  **Recommendations**: Specific suggestions for improvement

## Analyzing Spatial Distances

### Calculating Distances

``` r

# Calculate detailed spatial distances
distances <- spatial_distance(
  data = sample_spatial_data,
  folds = folds,
  x = "longitude",
  y = "latitude"
)

print(distances)
```

    ## Spatial Distance Analysis
    ## =========================
    ## Method: spatial_block 
    ## Number of folds: 5 
    ## Observations: 200 
    ## CRS: Not defined 
    ## 
    ## Fold Distance Summaries:
    ##   Fold 1:
    ##     Min: 11.24
    ##     Mean: 539.63
    ##     Median: 530.91
    ##     Max: 1235.71
    ##     SD: 219.62
    ##   Fold 2:
    ##     Min: 37.11
    ##     Mean: 542.84
    ##     Median: 522.37
    ##     Max: 1273.37
    ##     SD: 224.38
    ##   Fold 3:
    ##     Min: 11.24
    ##     Mean: 558.55
    ##     Median: 543.15
    ##     Max: 1273.37
    ##     SD: 227.29
    ##   Fold 4:
    ##     Min: 28.54
    ##     Mean: 545.10
    ##     Median: 532.45
    ##     Max: 1235.71
    ##     SD: 223.72
    ##   Fold 5:
    ##     Min: 32.80
    ##     Mean: 420.09
    ##     Median: 419.68
    ##     Max: 859.00
    ##     SD: 142.21

### Distance Statistics Explained

- **Minimum distance**: Closest train/test pair (most concerning)
- **Mean distance**: Average separation across all pairs
- **Median distance**: Typical separation (robust to outliers)
- **Maximum distance**: Furthest train/test pair
- **Standard deviation**: Variability in distances

### Interpreting Distance Values

The interpretation depends on your domain and coordinate system:

- **Small minimum distance** (\< 1% of study area): High risk of leakage
- **Large mean distance** (\> 10% of study area): Generally good
  separation
- **High variability** (large SD): Inconsistent spatial separation

## Customizing Leakage Detection

### Setting Custom Thresholds

``` r

# Use custom distance threshold
leakage_custom <- detect_spatial_leakage(
  data = sample_spatial_data,
  folds = folds,
  x = "longitude",
  y = "latitude",
  threshold = 50  # 50 unit threshold
)

print(leakage_custom)
```

    ## Spatial Leakage Detection
    ## =========================
    ## Method: spatial_block 
    ## Overall Risk Level: LOW 
    ## Distance Threshold: 50 
    ## 
    ## Summary Statistics:
    ##   Min distance: 11.24
    ##   Mean distance: 521.24
    ##   Median distance: 530.91
    ##   Proportion below threshold: 0.1%
    ## 
    ## Fold Analysis:
    ##   Fold 1: LOW risk (0.1% below threshold)
    ##   Fold 2: LOW risk (0.0% below threshold)
    ##   Fold 3: LOW risk (0.1% below threshold)
    ##   Fold 4: LOW risk (0.2% below threshold)
    ##   Fold 5: LOW risk (0.1% below threshold)
    ## 
    ## Recommendations:
    ##   - Spatial separation appears adequate. 
    ##   - Current cross-validation setup should provide reliable performance estimates. 
    ##   - Consider increasing spatial separation if you need more conservative estimates.

### Custom Risk Levels

``` r

# Define custom risk thresholds
leakage_custom_risk <- detect_spatial_leakage(
  data = sample_spatial_data,
  folds = folds,
  x = "longitude",
  y = "latitude",
  risk_levels = list(
    low = 0.05,      # < 5% below threshold
    moderate = 0.15   # < 15% below threshold
  )
)

print(leakage_custom_risk)
```

    ## Spatial Leakage Detection
    ## =========================
    ## Method: spatial_block 
    ## Overall Risk Level: LOW 
    ## Distance Threshold: 53.04 
    ## 
    ## Summary Statistics:
    ##   Min distance: 11.24
    ##   Mean distance: 521.24
    ##   Median distance: 530.91
    ##   Proportion below threshold: 0.1%
    ## 
    ## Fold Analysis:
    ##   Fold 1: LOW risk (0.1% below threshold)
    ##   Fold 2: LOW risk (0.0% below threshold)
    ##   Fold 3: LOW risk (0.1% below threshold)
    ##   Fold 4: LOW risk (0.2% below threshold)
    ##   Fold 5: LOW risk (0.1% below threshold)
    ## 
    ## Recommendations:
    ##   - Spatial separation appears adequate. 
    ##   - Current cross-validation setup should provide reliable performance estimates. 
    ##   - Consider increasing spatial separation if you need more conservative estimates.

## Comparing Different CV Methods

### Spatial vs Random CV

``` r

# Create spatial block folds
folds_spatial <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "block",
  seed = 123
)

# Create random folds
folds_random <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "random",
  seed = 123
)

# Detect leakage for both
leakage_spatial <- detect_spatial_leakage(
  data = sample_spatial_data,
  folds = folds_spatial,
  x = "longitude",
  y = "latitude"
)

leakage_random <- detect_spatial_leakage(
  data = sample_spatial_data,
  folds = folds_random,
  x = "longitude",
  y = "latitude"
)

# Compare results
cat("Spatial Block CV:\n")
```

    ## Spatial Block CV:

``` r

print(leakage_spatial)
```

    ## Spatial Leakage Detection
    ## =========================
    ## Method: spatial_block 
    ## Overall Risk Level: LOW 
    ## Distance Threshold: 53.04 
    ## 
    ## Summary Statistics:
    ##   Min distance: 11.24
    ##   Mean distance: 521.24
    ##   Median distance: 530.91
    ##   Proportion below threshold: 0.1%
    ## 
    ## Fold Analysis:
    ##   Fold 1: LOW risk (0.1% below threshold)
    ##   Fold 2: LOW risk (0.0% below threshold)
    ##   Fold 3: LOW risk (0.1% below threshold)
    ##   Fold 4: LOW risk (0.2% below threshold)
    ##   Fold 5: LOW risk (0.1% below threshold)
    ## 
    ## Recommendations:
    ##   - Spatial separation appears adequate. 
    ##   - Current cross-validation setup should provide reliable performance estimates. 
    ##   - Consider increasing spatial separation if you need more conservative estimates.

``` r

cat("\nRandom CV:\n")
```

    ## 
    ## Random CV:

``` r

print(leakage_random)
```

    ## Spatial Leakage Detection
    ## =========================
    ## Method: random 
    ## Overall Risk Level: LOW 
    ## Distance Threshold: 51.27 
    ## 
    ## Summary Statistics:
    ##   Min distance: 2.21
    ##   Mean distance: 512.67
    ##   Median distance: 504.43
    ##   Proportion below threshold: 0.8%
    ## 
    ## Fold Analysis:
    ##   Fold 1: LOW risk (0.7% below threshold)
    ##   Fold 2: LOW risk (0.8% below threshold)
    ##   Fold 3: LOW risk (0.8% below threshold)
    ##   Fold 4: LOW risk (0.7% below threshold)
    ##   Fold 5: LOW risk (0.8% below threshold)
    ## 
    ## Recommendations:
    ##   - Spatial separation appears adequate. 
    ##   - Current cross-validation setup should provide reliable performance estimates. 
    ##   - Consider increasing spatial separation if you need more conservative estimates.

### Expected Differences

- **Random CV**: Typically shows high spatial leakage (small distances)
- **Spatial CV**: Should show better spatial separation (larger
  distances)
- **Magnitude of difference**: Indicates strength of spatial dependence

## Case Studies

### Case 1: High Spatial Leakage

``` r

# Simulate high leakage scenario
folds_high_leakage <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 10,  # Many folds with small blocks
  method = "block",
  seed = 123
)

leakage_high <- detect_spatial_leakage(
  data = sample_spatial_data,
  folds = folds_high_leakage,
  x = "longitude",
  y = "latitude"
)

print(leakage_high)
```

    ## Spatial Leakage Detection
    ## =========================
    ## Method: spatial_block 
    ## Overall Risk Level: LOW 
    ## Distance Threshold: 52.4 
    ## 
    ## Summary Statistics:
    ##   Min distance: 18.64
    ##   Mean distance: 511.61
    ##   Median distance: 524.39
    ##   Proportion below threshold: 0.1%
    ## 
    ## Fold Analysis:
    ##   Fold 1: LOW risk (0.1% below threshold)
    ##   Fold 2: LOW risk (0.2% below threshold)
    ##   Fold 3: LOW risk (0.2% below threshold)
    ##   Fold 4: LOW risk (0.2% below threshold)
    ##   Fold 5: LOW risk (0.1% below threshold)
    ##   Fold 6: LOW risk (0.1% below threshold)
    ##   Fold 7: LOW risk (0.1% below threshold)
    ##   Fold 8: LOW risk (0.2% below threshold)
    ##   Fold 9: LOW risk (0.1% below threshold)
    ##   Fold 10: LOW risk (0.0% below threshold)
    ## 
    ## Recommendations:
    ##   - Spatial separation appears adequate. 
    ##   - Current cross-validation setup should provide reliable performance estimates. 
    ##   - Consider increasing spatial separation if you need more conservative estimates.

**Interpretation**: High risk indicates need for better spatial
separation.

### Case 2: Low Spatial Leakage

``` r

# Simulate low leakage scenario
folds_low_leakage <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 3,  # Few folds with large blocks
  method = "block",
  seed = 123
)

leakage_low <- detect_spatial_leakage(
  data = sample_spatial_data,
  folds = folds_low_leakage,
  x = "longitude",
  y = "latitude"
)

print(leakage_low)
```

    ## Spatial Leakage Detection
    ## =========================
    ## Method: spatial_block 
    ## Overall Risk Level: LOW 
    ## Distance Threshold: 57.79 
    ## 
    ## Summary Statistics:
    ##   Min distance: 30.24
    ##   Mean distance: 582.74
    ##   Median distance: 599.86
    ##   Proportion below threshold: 0.1%
    ## 
    ## Fold Analysis:
    ##   Fold 1: LOW risk (0.2% below threshold)
    ##   Fold 2: LOW risk (0.1% below threshold)
    ##   Fold 3: LOW risk (0.1% below threshold)
    ## 
    ## Recommendations:
    ##   - Spatial separation appears adequate. 
    ##   - Current cross-validation setup should provide reliable performance estimates. 
    ##   - Consider increasing spatial separation if you need more conservative estimates.

**Interpretation**: Low risk indicates good spatial separation.

## Addressing Spatial Leakage

### Recommendations by Risk Level

#### Low Risk

- Current setup is adequate
- Consider more conservative estimates if needed
- Monitor for changes in new data

#### Moderate Risk

- Increase block size or buffer radius
- Try different spatial CV methods
- Compare performance across methods
- Consider spatial clustering CV

#### High Risk

- Strongly increase spatial separation
- Use buffered CV with larger radius
- Results from random CV likely unreliable
- Review spatial distribution of data

### Practical Solutions

``` r

# Solution 1: Increase block size
folds_larger_blocks <- spatial_block_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  block_size = c(300, 300),  # Larger blocks
  seed = 123
)

# Solution 2: Use buffered CV
folds_buffered <- spatial_buffer_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  buffer_radius = 150,  # Larger buffer
  seed = 123
)

# Solution 3: Reduce number of folds
folds_fewer <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 3,  # Fewer folds
  method = "block",
  seed = 123
)
```

## Integration with Model Evaluation

### Full Workflow Example

``` r

# 1. Create folds
folds <- spatial_folds(sample_spatial_data, "longitude", "latitude", 
                      k = 5, method = "block", seed = 123)

# 2. Check for leakage
leakage <- detect_spatial_leakage(sample_spatial_data, folds, 
                                   "longitude", "latitude")

# 3. If high risk, adjust parameters
if (leakage$risk_level == "high") {
  folds <- spatial_folds(sample_spatial_data, "longitude", "latitude",
                        k = 3, method = "block", seed = 123)
}

# 4. Proceed with model training and evaluation
# (Model training code would go here)
```

## Important Considerations

### Coordinate Reference Systems

Distance calculations assume Euclidean geometry on the provided
coordinates:

- **Projected CRS**: Accurate metric distances
- **Geographic CRS**: Approximate distances (not true metric distances)
- **Recommendation**: Use projected CRS for distance-based analysis

``` r

# Warning for geographic coordinates
# (This is automatically triggered by the package)
```

### Threshold Selection

Choosing appropriate thresholds depends on:

- **Domain knowledge**: What distance is “too close” in your field?
- **Spatial scale**: Relative to the size of your study area
- **Prediction requirements**: How far will predictions be made?
- **Empirical testing**: Compare performance across different thresholds

### Multiple Metrics

Don’t rely solely on minimum distance:

- Consider mean and median distances
- Look at distribution across quantiles
- Examine fold-by-fold variability
- Combine with residual analysis

## Next Steps

- Learn about [model evaluation and
  comparison](https://sowsalim01.github.io/spatialcvR/articles/model-evaluation.md)
- Explore [spatial residual diagnostics](#spatial-residual-diagnostics)

## Key Takeaways

1.  **Spatial leakage** leads to over-optimistic performance estimates
2.  **Detection tools** help assess train/test spatial separation
3.  **Compare methods** to understand the impact of spatial dependence
4.  **Address high risk** by adjusting CV parameters or methods
5.  **Integrate checks** into your model evaluation workflow
