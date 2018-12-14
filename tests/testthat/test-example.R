context("test-example")

set.seed(20181214)
x <- (matrix(c(0,1), ncol = 128, nrow = 128))
y <- c(x)
y[sample(1:(128*128), 200)] <- sample(c(0,1), 200, replace = TRUE)
y <- matrix(y, 128)
x <- raster::raster(x)
y <- raster::raster(y)
#tmp <- tempfile()
test_that("MSSims should be equal", {
expect_equal(msssim(x,x,5),1, tolerance = .001)
expect_equal(msssim(y,y,5),1, tolerance = .001)
expect_equal(msssim(x,y,5),msssim(y,x,5), tolerance = .001)
})

#expect_known_value(msssim(x,y,5), tmp)
test_that("SSIMs should be equal:", {
expect_equal(ssim(x,x,5)[[1]],1, tolerance = .001)
expect_equal(ssim(y,y,5)[[1]],1, tolerance = .001)
expect_equal(ssim(x,y,5)[[1]],ssim(y,x,5)[[1]], tolerance = .001)
#expect_equal_to_reference(ssim(x,y,5))
})