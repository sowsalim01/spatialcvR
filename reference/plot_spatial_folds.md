# Plot Spatial Cross-Validation Folds

Creates a visual representation of spatial cross-validation folds,
showing the spatial distribution of training and test observations.

## Usage

``` r
plot_spatial_folds(folds, data, x = NULL, y = NULL, fold = 1, main = NULL, ...)
```

## Arguments

- folds:

  A spatial_folds object

- data:

  Spatial observations (data.frame or sf object)

- x:

  Name of the x coordinate column (required for data.frame, ignored for
  sf)

- y:

  Name of the y coordinate column (required for data.frame, ignored for
  sf)

- fold:

  Fold number to plot (default: 1, or "all" for all folds)

- main:

  Plot title (default: NULL, auto-generated)

- ...:

  Additional graphical parameters passed to plot()

## Value

Invisibly returns the fold object

## Details

Creates a scatter plot showing training and test observations with
different colors. For spatial block CV, also shows block boundaries when
available.

## See also

Other visualization functions:
[`plot_spatial_residuals()`](https://sowsalim01.github.io/spatialcvR/reference/plot_spatial_residuals.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data(sample_spatial_data)
folds <- spatial_folds(sample_spatial_data, "longitude", "latitude", k = 5)
plot_spatial_folds(folds, sample_spatial_data, "longitude", "latitude", fold = 1)
} # }
```
