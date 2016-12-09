#' Aggregated margin of error across multiple geographies
#'
#' @param x A numeric vector containing margins of error for estimates
#'   in multiple geographies.
#' @return The aggregated margin of error for the geographies.
#'
#' @author Josie Kressner
#'
#' @details Applies a root sum of squared errors. See page A-14 of this
#'   guide: http://www.census.gov/acs/www/Downloads/handbooks/ACSResearch.pdf
#'
#' @examples
#' x <- c(3, 5, 12, 4)
#' aggregate_moe(x)
#' data_frame(x = x, group = c(1, 1, 2, 2)) %>%
#'   group_by(group) %>%
#'   summarise(moe = aggregate_moe(x))
#'
#' @export
#'
aggregate_moe <- function(x) {

  list_moes <- list(x)

  if (length(list_moes) == 1) {
    # If a simple vector is passed in, return one moe.
    moes <- list_moes[[1]]
    sqrt(sum(moes^2))

  } else {
    # If a list of vectors are passed in, return a vector of moe's
    # element-by-element. This allows the function to be used with
    # dplyr::mutate.
    sqs <- lapply(list_moes, function(x) {x^2})
    sum_sqs <- Reduce("+", sqs)
    sqrt(sum_sqs)
  }
}
