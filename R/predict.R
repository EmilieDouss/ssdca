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

predict_fitdist_prop <- function(prop, boot, level) {
  quantile <- quantile(boot, prop, CI.level = level)
  est <- quantile$quantiles[1,1]
  se <- sd(quantile$bootquant[,1], 2)
  lcl <- quantile$quantCI[1,1]
  ucl <- quantile$quantCI[2,1]
  tibble::data_frame(prop = prop, est = est, se = se, lcl = lcl, ucl = ucl)
}

model_average <- function(x) {
  est <- sum(x$est * x$weight)
  se <- sqrt(sum(x$weight * (x$se^2 + (x$est - est)^2)))
  lcl <- sum(x$lcl * x$weight)
  ucl <- sum(x$ucl * x$weight)
  tibble::data_frame(est = est, se = se, lcl = lcl, ucl = ucl)
}

#' Predict fitdist
#'
#' @inheritParams predict.fitdists
#' @export
#' @examples
#' predict(boron_lnorm, props = c(0.05, 0.5))
predict.fitdist <- function(object, props = seq(0.01, 0.99, by = 0.01),
                            nboot = 1001, level = 0.95, ...) {
  check_vector(props, c(0.001, 0.999), length = c(1, Inf), unique = TRUE)
  check_count(nboot, coerce = TRUE)
  check_probability(level)
  boot <- bootdist(object, niter = nboot)
  prediction <- map_df(props, predict_fitdist_prop, boot = boot, level = level)
  prediction
}

#' Predict censored fitdist
#'
#' @inheritParams predict.fitdists
#' @export
#' @examples
#' predict(fluazinam_lnorm, props = c(0.05, 0.5))
predict.fitdistcens <- function(object, props = seq(0.01, 0.99, by = 0.01),
                            nboot = 1001, level = 0.95, ...) {
  check_vector(props, c(0.001, 0.999), length = c(1, Inf), unique = TRUE)
  check_count(nboot, coerce = TRUE)
  check_probability(level)
  boot <- bootdistcens(object, niter = nboot)
  prediction <- map_df(props, predict_fitdist_prop, boot = boot, level = level)
  prediction
}

#' Predict fitdist
#'
#' @param object The object.
#' @param props A numeric vector of the densities to calculate the estimated concentrations for.
#' @param nboot A count of the number of bootstrap samples to use to estimate the se and confidence limits.
#' @param ic A string indicating which information-theoretic criterion ('aic', 'aicc' or 'bic') to use for model averaging.
#' @param average A flag indicating whether to model-average.
#' @param level The confidence level.
#' @param ... Unused
#' @export
#' @examples
#' \dontrun{
#' predict(boron_dists)
#' }
predict.fitdists <- function(object, props = seq(0.01, 0.99, by = 0.01),
                             nboot = 1001, ic = "aicc", average = TRUE, level = 0.95, ...) {
  check_vector(ic, c("aic", "aicc", "bic"), length = 1)

  ic <- ssd_gof(object)[c("dist", ic)]

  ic$delta <- ic[[2]] - min(ic[[2]])
  ic$weight <- round(exp(-ic$delta/2)/sum(exp(-ic$delta/2)), 3)

  ic %<>% split(., 1:nrow(.))

  predictions <- lapply(object, predict, props = props, nboot = nboot, level = level) %>%
    map2(ic, function(x, y) {x$weight <- y$weight; x}) %>%
    dplyr::bind_rows(.id = "dist")

  if(!average) return(predictions)

  predictions %<>%
    plyr::ddply("prop", model_average) %>%
    tibble::as_tibble()

  predictions
}

#' Predict Censored fitdists
#'
#' @inheritParams predict.fitdists
#' @export
#' @examples
#' \dontrun{
#' predict(fluazinam_dists)
#' }
predict.fitdistscens <- function(object, props = seq(0.01, 0.99, by = 0.01),
                             nboot = 1001, ic = "aic", average = TRUE, level = 0.95, ...) {
  check_vector(ic, c("aic", "bic"), length = 1)
  NextMethod(object = object, props = props, nboot = nboot, ic = ic, average = average,
             level = level, ...)
}
