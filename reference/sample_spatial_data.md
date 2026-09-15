# Sample Spatial Data for Demonstration

A synthetic dataset containing 200 spatial observations with coordinates
and variables for demonstration and testing purposes.

## Usage

``` r
data(sample_spatial_data)
```

## Format

A data frame with 200 rows and 6 columns:

- id:

  Unique identifier for each observation (integer)

- longitude:

  X coordinate in projected CRS (numeric)

- latitude:

  Y coordinate in projected CRS (numeric)

- variable1:

  First predictor variable with spatial structure (numeric)

- variable2:

  Second predictor variable with spatial structure (numeric)

- target:

  Target variable for prediction (numeric)

## Source

Synthetic data generated for package demonstration

## Details

The data was generated to simulate spatial autocorrelation:

- Coordinates are in a UTM-like projected system (0-1000 range)

- Variables show gradients in X and Y directions

- Target variable combines predictors with spatial structure

- Some missing values are included for testing NA handling

## Examples

``` r
data(sample_spatial_data)
head(sample_spatial_data)
#>   id longitude latitude variable1 variable2    target
#> 1  1  287.5775 238.7260  86.36698  36.57333 110.40061
#> 2  2  788.3051 962.3589 102.53939  49.52156 143.78578
#> 3  3  408.9769 601.3657  67.79740  42.96299 101.66984
#> 4  4  883.0174 515.0297  99.58281  45.22016 123.82676
#> 5  5  940.4673 402.5733  92.87996  47.44277 129.43342
#> 6  6   45.5565 880.2465  47.51536  43.20302  86.62062
summary(sample_spatial_data)
#>        id           longitude           latitude         variable1     
#>  Min.   :  1.00   Min.   :  0.6248   Min.   :  6.301   Min.   : 35.77  
#>  1st Qu.: 50.75   1st Qu.:272.1181   1st Qu.:235.623   1st Qu.: 62.71  
#>  Median :100.50   Median :482.0961   Median :469.024   Median : 76.43  
#>  Mean   :100.50   Mean   :506.3919   Mean   :489.122   Mean   : 76.10  
#>  3rd Qu.:150.25   3rd Qu.:733.3708   3rd Qu.:741.910   3rd Qu.: 88.61  
#>  Max.   :200.00   Max.   :994.2698   Max.   :999.405   Max.   :117.70  
#>                                                        NAs    :5       
#>    variable2         target      
#>  Min.   :13.68   Min.   : 55.91  
#>  1st Qu.:37.38   1st Qu.: 95.10  
#>  Median :45.02   Median :109.90  
#>  Mean   :44.93   Mean   :108.22  
#>  3rd Qu.:52.88   3rd Qu.:122.62  
#>  Max.   :74.62   Max.   :154.56  
#>                  NAs    :3       
```
