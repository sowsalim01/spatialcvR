# Spatial Clustering Cross-Validation

Creates spatial cross-validation folds by clustering observations
spatially and assigning clusters to folds. This method is useful for
data with complex spatial structure.

## Usage

``` r
spatial_cluster_folds(
  data,
  x = NULL,
  y = NULL,
  k = 5,
  n_clusters = NULL,
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

- n_clusters:

  Number of spatial clusters (default: k)

- seed:

  Random seed for reproducibility (default: NULL)

## Value

An object of class "spatial_folds" containing fold assignments

## Details

The clustering method groups spatially proximate observations into
clusters using k-means clustering on coordinates, then assigns clusters
to folds. This ensures spatial coherence within folds while maintaining
separation between folds.

## See also

Other spatial cross-validation functions:
[`spatial_block_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_block_folds.md),
[`spatial_buffer_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_buffer_folds.md),
[`spatial_folds()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_folds.md),
[`spatial_split()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_split.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data(sample_spatial_data)
folds <- spatial_cluster_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  n_clusters = 10
)
} # }
```
