# Create Spatial Cross-Validation Folds

Creates spatially separated folds for model evaluation to address
spatial dependence in observations. This function serves as a wrapper
for different spatial cross-validation methods.

## Usage

``` r
spatial_folds(
  data,
  x = NULL,
  y = NULL,
  k = 5,
  method = "block",
  seed = NULL,
  ...
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

- method:

  Spatial CV method: "block", "buffer", "cluster", or "random" (default:
  "block")

- seed:

  Random seed for reproducibility (default: NULL)

- ...:

  Additional parameters passed to specific methods

## Value

An object of class "spatial_folds" containing:

- folds:

  List of train/test indices for each fold

- method:

  Method used for fold creation

- k:

  Number of folds

- parameters:

  List of parameters used

- coordinates:

  Coordinate matrix of observations

- crs:

  Coordinate reference system

- metadata:

  Additional metadata

## Details

The function validates inputs and dispatches to the appropriate spatial
CV method:

- "block": Spatial block cross-validation (default)

- "buffer": Buffered cross-validation

- "cluster": Spatial clustering cross-validation

- "random": Random spatial split (baseline)

## See also

Other spatial cross-validation functions:
[`spatial_block_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_block_folds.md),
[`spatial_buffer_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_buffer_folds.md),
[`spatial_cluster_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_cluster_folds.md),
[`spatial_split()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_split.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data(sample_spatial_data)
folds <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "block"
)
} # }
```
