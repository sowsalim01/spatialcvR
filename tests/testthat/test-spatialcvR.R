# Basic package tests

test_that("package can be loaded", {
  expect_true(requireNamespace("spatialcvR", quietly = TRUE))
})

test_that("package has a namespace", {
  expect_true("spatialcvR" %in% loadedNamespaces())
})