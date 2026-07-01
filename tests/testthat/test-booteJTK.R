test_that("Kendall tau-b matches reference values", {
  x <- c(1, 1, 2, 3, 3, 3, 4, 5)
  y <- c(3, 1, 2, 5, 4, 8, 6, 7)
  expect_equal(kendall_tau(x, y), 0.6943650748294136, tolerance = 1e-12)
})

test_that("circular mean/std match reference values", {
  v <- c(20, 22, 0, 2, 20, 20)
  expect_equal(circ_mean(v, 24, 0), 21.89693581927196, tolerance = 1e-10)
  expect_equal(circ_std(v, 24, 0),  2.349441022882545, tolerance = 1e-10)
  expect_equal(circ_mean(c(6, 6, 6, 6), 24, 0), 6, tolerance = 1e-12)
})

test_that("Fisher transform clamps at +/-0.99", {
  expect_equal(farctanh(0.5), atanh(0.5))
  expect_equal(farctanh(1.0), atanh(0.99))
  expect_equal(farctanh(-1.0), atanh(-0.99))
})

test_that("gamma_fit recovers scipy-like parameters", {
  set.seed(1)
  x <- rgamma(2000, shape = 3, scale = 0.25) + 0.05
  p <- gamma_fit(x)
  expect_equal(unname(p[1]), 3, tolerance = 0.2)
  expect_true(p[3] > 0 && p[1] > 0 && p[2] < min(x))
})

test_that("engine reproduces deterministic descriptive columns", {
  f <- system.file("extdata", "TestInput4.txt", package = "BooteJTKr")
  d <- read_in(f)
  res <- boote_jtk(d$mat, d$header, 24,
                   phases = seq(0, 22, 2), widths = seq(2, 22, 2),
                   size = 10, variance = "ebayes", seed = 42)
  r5 <- res[res$ID == "5", ]
  # These come from the raw data and must match the original exactly.
  expect_equal(r5$Mean,    10.0109275596, tolerance = 1e-8)
  expect_equal(r5$Std_Dev, 0.719205503138, tolerance = 1e-8)
  expect_equal(r5$Max,     11.0371295912, tolerance = 1e-8)
  expect_equal(r5$Max_Amp, 2.11298958689, tolerance = 1e-8)
  # Strong rhythmic series resolves to phase 20h regardless of RNG.
  expect_equal(r5$PhaseMean, 20)
})

test_that("full pipeline yields significant calls for rhythmic test data", {
  f <- system.file("extdata", "TestInput4.txt", package = "BooteJTKr")
  res <- run_booteJTK(file = f, periods = 24,
                      phases = seq(0, 22, 2), widths = seq(2, 22, 2),
                      size = 10, n_null = 100, variance = "ebayes", seed = 42)
  expect_true(all(c("empP", "GammaP", "GammaBH") %in% names(res)))
  expect_true(max(res$GammaBH) < 0.05)
})
