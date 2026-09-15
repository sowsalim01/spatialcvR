# Compare Cross-Validation Methods

Compares performance metrics across different cross-validation methods
to assess the impact of spatial dependence on model evaluation.

## Usage

``` r
compare_cv(results_list, methods = NULL)
```

## Arguments

- results_list:

  Named list of spatial_metrics objects from different CV methods

- methods:

  Character vector of method names (optional, uses names of
  results_list)

## Value

An object of class "cv_comparison" containing:

- summary:

  Data frame with summary statistics for each method

- by_fold:

  Data frame with fold-level results

- best_method:

  Method with best performance according to RMSE

- comparison:

  Performance comparison between methods

## Details

The function compares metrics across different CV methods:

- Creates summary table with mean and SD of metrics per method

- Identifies best performing method

- Provides fold-level comparison

- Calculates performance differences between methods

This is useful for comparing spatial CV methods against random CV to
demonstrate the impact of spatial dependence.

## See also

Other model evaluation functions:
[`spatial_metrics()`](https://sowsalim01.github.io/spatialcvR/reference/spatial_metrics.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Train model with different CV methods
results_random <- list(RMSE = 0.5, MAE = 0.4, R2 = 0.8)
results_block <- list(RMSE = 0.7, MAE = 0.6, R2 = 0.6)
results_cluster <- list(RMSE = 0.6, MAE = 0.5, R2 = 0.7)

comparison <- compare_cv(
  list(random = results_random, block = results_block, cluster = results_cluster)
)
print(comparison)
} # }
```
