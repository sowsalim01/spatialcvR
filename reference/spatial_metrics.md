# Spatial Model Evaluation Metrics

Calculates standard model evaluation metrics for comparing observed and
predicted values. These metrics are commonly used in machine learning
and spatial modeling.

## Usage

``` r
spatial_metrics(observed, predicted, na.rm = TRUE)
```

## Arguments

- observed:

  Numeric vector of observed values

- predicted:

  Numeric vector of predicted values

- na.rm:

  Logical, whether to remove NA values (default: TRUE)

## Value

An object of class "spatial_metrics" containing:

- n:

  Number of observations

- RMSE:

  Root Mean Square Error

- MAE:

  Mean Absolute Error

- R2:

  R-squared (coefficient of determination)

- MAPE:

  Mean Absolute Percentage Error (when applicable)

## Details

The function calculates the following metrics:

- RMSE: sqrt(mean((observed - predicted)^2))

- MAE: mean(abs(observed - predicted))

- R2: 1 - sum((observed - predicted)^2) / sum((observed -
  mean(observed))^2)

- MAPE: mean(abs((observed - predicted) / observed)) \* 100 (only when
  no zeros in observed)

## See also

Other model evaluation functions:
[`compare_cv()`](https://sowsalim01.github.io/spatialcvR/reference/compare_cv.md)

## Examples

``` r
observed <- c(1, 2, 3, 4, 5)
predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
metrics <- spatial_metrics(observed, predicted)
print(metrics)
#> Model Evaluation Metrics
#> =======================
#> Number of observations: 5 
#> RMSE: 0.1483 
#> MAE: 0.14 
#> R2: 0.989 
#> MAPE: 6.23 %
```
