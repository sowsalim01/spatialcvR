# Detect Spatial Leakage in Cross-Validation Folds

Analyzes the proximity between training and test observations to detect
potential spatial leakage, where training and test sets are too close
spatially, leading to over-optimistic performance estimates.

## Usage

``` r
detect_spatial_leakage(
  data,
  folds,
  x = NULL,
  y = NULL,
  threshold = NULL,
  risk_levels = NULL
)
```

## Arguments

- data:

  Spatial observations (data.frame or sf object)

- folds:

  A spatial_folds object

- x:

  Name of the x coordinate column (required for data.frame, ignored for
  sf)

- y:

  Name of the y coordinate column (required for data.frame, ignored for
  sf)

- threshold:

  Distance threshold for considering observations "too close" (default:
  NULL, auto-calculated)

- risk_levels:

  Custom risk level thresholds as list(min, moderate, high) (default:
  NULL)

## Value

An object of class "spatial_leakage_result" containing:

- method:

  CV method used

- fold_distances:

  Distance analysis for each fold

- summary_statistics:

  Overall summary across all folds

- risk_level:

  Overall risk assessment: "low", "moderate", or "high"

- recommendations:

  Text recommendations based on analysis

- threshold:

  Threshold used for risk assessment

## Details

The function analyzes spatial distances between training and test
observations:

- Calculates minimum, mean, and median distances per fold

- Identifies observations within threshold distance

- Assesses overall risk level

- Provides recommendations for improvement

Risk levels are based on the proportion of train/test pairs that are too
close:

- "low": \< 10% of pairs below threshold

- "moderate": 10-30% of pairs below threshold

- "high": \> 30% of pairs below threshold

## See also

Other spatial analysis functions:
[`spatial_distance()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_distance.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data(sample_spatial_data)
folds <- spatial_folds(sample_spatial_data, "longitude", "latitude", k = 5)
leakage <- detect_spatial_leakage(sample_spatial_data, folds, "longitude", "latitude")
print(leakage)
} # }
```
