# Spatial Residual Diagnostics

Analyzes the spatial distribution of model residuals to detect spatial
patterns in prediction errors. This helps identify whether model errors
are spatially autocorrelated, which may indicate missing spatial
predictors or inappropriate model specification.

## Usage

``` r
spatial_residuals(observed, predicted, coordinates, x = NULL, y = NULL)
```

## Arguments

- observed:

  Numeric vector of observed values

- predicted:

  Numeric vector of predicted values

- coordinates:

  Coordinate matrix or data.frame with x and y columns

- x:

  Name of x coordinate column if coordinates is a data.frame

- y:

  Name of y coordinate column if coordinates is a data.frame

## Value

An object of class "spatial_residuals" containing:

- residuals:

  Residual values (observed - predicted)

- observed:

  Observed values

- predicted:

  Predicted values

- coordinates:

  Coordinate matrix

- statistics:

  Summary statistics of residuals

## Details

The function calculates residuals and provides summary statistics:

- Mean, median, SD of residuals

- Quantiles of residuals

- Normality test statistics (if sufficient data)

Spatial autocorrelation analysis can be added in future versions when
appropriate dependencies (e.g., spdep) are available.

## Examples

``` r
observed <- c(1, 2, 3, 4, 5)
predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
residuals <- spatial_residuals(observed, predicted, coords)
print(residuals)
#> Spatial Residual Diagnostics
#> ============================
#> Number of observations: 5 
#> 
#> Residual Statistics:
#>   Mean: -0.0200
#>   Median: -0.1000
#>   SD: 0.1643
#>   Min: -0.2000
#>   Max: 0.2000
#>   Q25: -0.1000
#>   Q50: -0.1000
#>   Q75: 0.1000
#> 
#> Coordinate Range:
#>   X: [0.00, 4.00]
#>   Y: [0.00, 4.00]
```
