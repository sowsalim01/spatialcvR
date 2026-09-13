# This file is part of the spatialcvR package
# It is used to run tests during package development

test_that("package loads correctly", {
  expect_true(requireNamespace("spatialcvR", quietly = TRUE))
})