# spatialcvR: Spatial Cross-Validation for Machine Learning

[![CRAN
status](https://www.r-pkg.org/badges/version/spatialcvR)](https://cran.r-project.org/package=spatialcvR)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

`spatialcvR` provides tools for spatial cross-validation and model
evaluation for geospatial machine learning applications. It addresses
the fundamental problem that geographic observations are often not
independent, which can lead to over-optimistic performance estimates
when using standard random cross-validation.

## The Problem

In geospatial data analysis, nearby observations tend to be similar
(Tobler’s First Law of Geography). When using traditional random
cross-validation, training and test sets may contain observations that
are spatially close, leading to:

- **Over-optimistic performance estimates**
- **Underestimation of generalization error**
- **Undetected spatial overfitting**

## The Solution

`spatialcvR` implements spatial cross-validation methods that explicitly
control the separation between training and test observations:

- **Spatial Block Cross-Validation**: Divide space into rectangular
  blocks
- **Buffered Cross-Validation**: Exclude training observations within a
  buffer radius
- **Spatial Clustering Cross-Validation**: Group observations spatially
- **Random Spatial Split**: Baseline comparison method

## Installation

``` r

# Install from CRAN (when available)
install.packages("spatialcvR")

# Install development version from GitHub
# devtools::install_github("yourusername/spatialcvR")
```

## Quick Start

``` r

library(spatialcvR)

# Load sample data
data(sample_spatial_data)

# Create spatial folds
folds <- spatial_folds(
  data = sample_spatial_data,
  x = "longitude",
  y = "latitude",
  k = 5,
  method = "block"
)

# Detect spatial leakage
leakage <- detect_spatial_leakage(
  data = sample_spatial_data,
  folds = folds,
  x = "longitude",
  y = "latitude"
)

# Evaluate model performance
metrics <- spatial_metrics(
  observed = test_values,
  predicted = predictions
)
```

## Key Features

- **Multiple spatial CV methods**: Block, buffered, clustering
  approaches
- **Spatial leakage detection**: Identify risky train/test proximity
- **Model evaluation metrics**: RMSE, MAE, R², MAPE
- **Spatial residual diagnostics**: Analyze error distribution in space
- **Method comparison**: Compare spatial vs. random CV
- **Flexible input**: Works with sf objects, data frames, or coordinates
- **CRS-aware**: Proper coordinate system handling

## Use Cases

Perfect for researchers and practitioners working with:

- Agriculture and precision farming
- Environmental monitoring
- Climate and meteorology
- Hydrology and water resources
- Forestry and land management
- Urban planning
- Environmental health
- Ecology and biodiversity
- Remote sensing
- Geology and mineral exploration
- Risk assessment
- Any geospatial machine learning application

## Documentation

- [Introduction
  vignette](https://sowsalim01.github.io/spatialcvR/articles/introduction.html)
- [Spatial cross-validation
  methods](https://sowsalim01.github.io/spatialcvR/articles/spatial-cross-validation.html)
- [Spatial leakage
  detection](https://sowsalim01.github.io/spatialcvR/articles/spatial-leakage.html)
- [Model
  evaluation](https://sowsalim01.github.io/spatialcvR/articles/model-evaluation.html)

## Project Status

This package is currently in **development** (version 0.1.0). The core
functionality is being implemented and tested.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or
open an issue for bugs, feature requests, or questions.

## License

MIT License - see
[LICENSE](https://sowsalim01.github.io/spatialcvR/LICENSE) file for
details.

## Citation

If you use `spatialcvR` in your research, please cite it:

``` bibtex
@software{spatialcvR,
  title = {spatialcvR: Spatial Cross-Validation for Machine Learning},
  author = {Mamadou SOW},
  year = {2026},
  url = {https://github.com/sowsalim01/spatialcvR}
}
```

## Acknowledgments

This package was developed to address the need for robust spatial
validation methods in R’s geospatial machine learning ecosystem.

## Contact

For questions, issues, or suggestions, please [open an
issue](https://github.com/sowsalim01/spatialcvR/issues) on GitHub.
