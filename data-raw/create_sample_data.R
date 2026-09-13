# Script to create sample spatial data for demonstration and testing
# This script generates a synthetic dataset with spatial coordinates and variables

set.seed(123)

# Number of observations
n <- 200

# Create spatial coordinates in a projected CRS (UTM-like)
# Using a simple grid with some noise
x_coords <- runif(n, min = 0, max = 1000)
y_coords <- runif(n, min = 0, max = 1000)

# Create variables with some spatial structure
# Variable 1: gradient in x direction with noise
variable1 <- 50 + 0.05 * x_coords + rnorm(n, mean = 0, sd = 10)

# Variable 2: gradient in y direction with noise
variable2 <- 30 + 0.03 * y_coords + rnorm(n, mean = 0, sd = 8)

# Target variable: combination of variables with spatial autocorrelation
target <- 10 + 0.8 * variable1 + 0.5 * variable2 + 
          0.01 * x_coords + 0.02 * y_coords + 
          rnorm(n, mean = 0, sd = 5)

# Create data frame
sample_spatial_data <- data.frame(
  id = 1:n,
  longitude = x_coords,
  latitude = y_coords,
  variable1 = variable1,
  variable2 = variable2,
  target = target
)

# Add some missing values for testing
sample_spatial_data$variable1[sample(1:n, 5)] <- NA
sample_spatial_data$target[sample(1:n, 3)] <- NA

# Save the data
usethis::use_data(sample_spatial_data, overwrite = TRUE)

# Print summary
cat("Sample spatial data created:\n")
cat("  Number of observations:", nrow(sample_spatial_data), "\n")
cat("  Number of variables:", ncol(sample_spatial_data), "\n")
cat("  Coordinate range:\n")
cat("    X:", range(sample_spatial_data$longitude), "\n")
cat("    Y:", range(sample_spatial_data$latitude), "\n")
cat("  Missing values:\n")
cat("    variable1:", sum(is.na(sample_spatial_data$variable1)), "\n")
cat("    target:", sum(is.na(sample_spatial_data$target)), "\n")