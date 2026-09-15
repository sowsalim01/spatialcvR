# Spatial Block Cross-Validation

Creates spatial cross-validation folds by dividing the study area into
rectangular blocks and assigning observations to folds based on their
block membership. This method ensures spatial separation between
training and test sets.

## Usage

``` r
spatial_block_folds(
  data,
  x = NULL,
  y = NULL,
  k = 5,
  block_size = NULL,
  n_blocks = NULL,
  assignment = "systematic",
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

- block_size:

  Size of blocks as c(width, height) in coordinate units

- n_blocks:

  Number of blocks in x and y directions as c(nx, ny)

- assignment:

  Strategy for assigning blocks to folds: "systematic" or "random"

- seed:

  Random seed for reproducibility (default: NULL)

## Value

An object of class "spatial_folds" containing fold assignments

## Details

The spatial block method divides the spatial extent into a grid of
rectangular blocks. Two approaches are available:

- Fixed block size: Specify block_size to control block dimensions

- Fixed number of blocks: Specify n_blocks to control grid resolution

If neither is specified, the function attempts to create approximately
sqrt(k) blocks in each direction.

Assignment strategies:

- "systematic": Assigns blocks to folds in a systematic pattern

- "random": Randomly assigns blocks to folds

## See also

Other spatial cross-validation functions:
[`spatial_buffer_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_buffer_folds.md),
[`spatial_cluster_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_cluster_folds.md),
[`spatial_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_folds.md),
[`spatial_split()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_split.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data(sample_spatial_data)
folds <- spatial_block_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  block_size = c(200, 200)
)
} # }
```
