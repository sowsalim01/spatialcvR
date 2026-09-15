# Plot Spatial Residuals

Creates visualizations of spatial residuals to analyze the spatial
distribution of model errors.

## Usage

``` r
plot_spatial_residuals(residuals_obj, type = "scatter", main = NULL, ...)
```

## Arguments

- residuals_obj:

  A spatial_residuals object

- type:

  Type of plot: "scatter", "histogram", or "qq" (default: "scatter")

- main:

  Plot title (default: NULL, auto-generated)

- ...:

  Additional graphical parameters passed to plot()

## Value

Invisibly returns the residuals object

## Details

Creates different types of residual plots:

- "scatter": Spatial scatter plot of residuals colored by magnitude

- "histogram": Histogram of residual values

- "qq": Q-Q plot for normality assessment

## See also

Other visualization functions:
[`plot_spatial_folds()`](https://sowsalim01.github.io/spatialcvR/reference/plot_spatial_folds.md)

## Examples

``` r
if (FALSE) { # \dontrun{
observed <- c(1, 2, 3, 4, 5)
predicted <- c(1.1, 2.2, 2.8, 4.1, 4.9)
coords <- cbind(x = c(0, 1, 2, 3, 4), y = c(0, 1, 2, 3, 4))
residuals <- spatial_residuals(observed, predicted, coords)
plot_spatial_residuals(residuals, type = "scatter")
} # }
```
