# Random Spatial Split

Creates a random spatial split serving as a baseline for comparison with
spatial cross-validation methods. This represents traditional random
cross-validation without spatial considerations.

## Usage

``` r
spatial_split(data, x = NULL, y = NULL, k = 5, seed = NULL)
```

## Arguments

- data:

  Spatial observations (data.frame or sf object)

- x:

  Name of the x coordinate column (required for data.frame, ignored for
  sf)

- y:

  Name of the y coordinate column (required for data.frame, ignored for
  sf)

- k:

  Number of folds (default: 5)

- seed:

  Random seed for reproducibility (default: NULL)

## Value

An object of class "spatial_folds" containing fold assignments

## Details

This method performs standard random k-fold cross-validation without any
spatial constraints. It serves as a baseline to compare against spatial
cross-validation methods and demonstrate the impact of spatial
dependence on model evaluation.

## See also

Other spatial cross-validation functions:
[`spatial_block_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_block_folds.md),
[`spatial_buffer_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_buffer_folds.md),
[`spatial_cluster_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_cluster_folds.md),
[`spatial_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_folds.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data(sample_spatial_data)
folds <- spatial_split(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5
)
} # }
```
