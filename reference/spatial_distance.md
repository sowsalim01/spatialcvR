# Calculate Spatial Distances Between Train and Test Observations

Computes distances between training and test observations for each fold
in a spatial cross-validation setup. This helps assess the spatial
separation between training and test sets.

## Usage

``` r
spatial_distance(data, folds, x = NULL, y = NULL)
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

## Value

A list containing distance information for each fold:

- fold:

  Fold number

- min_distance:

  Minimum distance between train and test observations

- mean_distance:

  Mean distance between train and test observations

- median_distance:

  Median distance between train and test observations

- max_distance:

  Maximum distance between train and test observations

- sd_distance:

  Standard deviation of distances

- quantiles:

  Distance quantiles (25%, 50%, 75%)

## Details

For each fold, the function calculates Euclidean distances between all
pairs of training and test observations. This provides a comprehensive
view of spatial separation.

Note: Distance calculations use Euclidean distance on the provided
coordinates. For accurate metric distances, ensure data is in a
projected CRS. Geographic coordinates (longitude/latitude) will produce
approximate distances.

## See also

Other spatial analysis functions:
[`detect_spatial_leakage()`](https://sowsalim01.github.io/spatialcvR/reference/detect_spatial_leakage.md)

## Examples

``` r
if (FALSE) { # \dontrun{
data(sample_spatial_data)
folds <- spatial_folds(sample_spatial_data, "longitude", "latitude", k = 5)
distances <- spatial_distance(sample_spatial_data, folds, "longitude", "latitude")
print(distances)
} # }
```
