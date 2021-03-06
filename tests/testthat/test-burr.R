#    Copyright 2015 Province of British Columbia
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

context("burr")

test_that("rburr", {
  set.seed(99)
  r <- rburr(100000,1,1)
  expect_identical(length(r), 100000L)
  expect_equal(mean(r), 10.9, tolerance = 0.1)
})

test_that("pqburr", {
  expect_equal(qburr(0.5, 1,1), 1, tolerance = 0.000001)
  expect_equal(pburr(exp(3), 1,1), 0.9525741, tolerance = 0.0000001)
  expect_equal(pburr(exp(4), 1, 1), 0.9820138, tolerance = 0.0000001)
  expect_equal(pburr(qburr(0.5, 3, 1), 3, 1), 0.5)
})

test_that("dburr", {
 expect_equal(dburr(0.5, 3, 1), 0.5925926, tolerance = 0.0000001)
 expect_equal(dburr(0.6, 3, 1), 0.4577637, tolerance = 0.0000001)
})
