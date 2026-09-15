# Spatial Buffered Cross-Validation

Creates spatial cross-validation folds by excluding training
observations within a specified buffer radius around test observations.
This method ensures a minimum spatial separation between training and
test sets.

## Usage

``` r
spatial_buffer_folds(
  data,
  x = NULL,
  y = NULL,
  k = 5,
  buffer_radius = NULL,
  seed = NULL
)
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

- buffer_radius:

  Buffer radius in coordinate units

- seed:

  Random seed for reproducibility (default: NULL)

## Value

An object of class "spatial_folds" containing fold assignments

## Details

The buffered method ensures that for each test observation, no training
observation falls within the specified buffer radius. This is
particularly useful when you need strict control over the minimum
distance between training and test observations.

Note: This method requires a projected CRS for accurate distance
calculations. Using geographic coordinates (longitude/latitude) will
produce warnings.

## See also

Other spatial cross-validation functions:
[`spatial_block_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_block_folds.md),
[`spatial_cluster_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_cluster_folds.md),
[`spatial_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_folds.md),
[`spatial_split()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_split.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data(sample_spatial_data)
folds <- spatial_buffer_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  buffer_radius = 100
)
} # }
```
