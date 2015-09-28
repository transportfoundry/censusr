#' Retrieve data from the Census API
#'
#' Returns Census data for the 2010 SF1 for requested variables and geographies.
#'
#' @param variables_to_get the variable name for the Census API call,
#' defined at \url{http://api.census.gov/}
#' @param geoids A character vector of FIPS codes; must be at least to the
#'   county (5-digit) level, and can accept down to blocks (15-digit).
#' @param data_source A string identifying whether the SF1 (decennial census) or
#'   ACS data is desired.
#' @param year If \code{data_source = "acs"}, the final year of the summary
#'   period. Default is \code{2013}.
#' @param period If \code{data_source = "acs"}, the length of aggregation period.
#'   Default is \code{5}, or a 5-year aggregation table.
#'
#' @return a data_frame with each requested variable at each requested geography.
#'
#' @export
#' @importFrom dplyr select tbl_df
call_census_api <- function(variables_to_get, geoids,
                            data_source = c("sf1", "acs"),
                            year = 2013, period = 5) {


  # call_api_once for each requested geography
  all_vars <- do.call(
    "rbind",
    lapply(geoids, function(geoid)
      call_api_once(variables_to_get, geoid, data_source)
    )
  )

  # Keep geoid and variable columns (throw out others)
  col_indexes <- match(variables_to_get, names(all_vars))
  all_vars <- dplyr::select(all_vars, geoid, col_indexes)

  dplyr::tbl_df(all_vars)
}

#' Call Census API for a set of variables
#'
#' This is an internal function and is not intended for users. See instead
#' \link{call_census_api}.
#'
#' @inheritParams call_census_api
#' @param geoid A character string with a FIPS code, between 2 and 15 digits long.
#'
#' @return A code{data.frame} with the requested variables at the requested
#'   geography.
#'
#' @importFrom httr content GET
#'
call_api_once <- function(variables_to_get, geoid, data_source) {

  # construct primary url depending on requested dataset
  if(data_source == "sf1"){
    # Census SF1 data
    call_start <- "http://api.census.gov/data/2010/sf1?get="
  } else if(data_source == "acs"){
    # ACS summary tables
    call_start <- paste(
      "http://api.census.gov/data/", year,
      "/acs", period, "?get=", sep = ""
    )
  }

  # construct variable url string
  var_string <- paste(variables_to_get, collapse = ",")

  # construct geo url string
  geo_string <- get_geo_url(geoid)

  # consruct api string
  api_string = paste("&key=", "1209214b319264ae3163b6d262dda4106e5c77f0",
                     sep = "")
  # assemble url
  url <- paste(call_start, var_string, geo_string, api_string, sep = "")

  # Gives back a list of lists; first list has the headers
  response <- httr::content(httr::GET(url))
  header <- response[[1]]
  values <- as.numeric(response[[2]])

  # Build data frame
  values <- lapply(values, function(x) ifelse(is.null(x), NA, x))
  nicified_response <- data.frame(values, stringsAsFactors=FALSE)
  names(nicified_response) <- header
  nicified_response$geoid <- as.character(geoid)
  return(nicified_response)
}


#' Construct a geography request string from a FIPS Code
#'
#' @inheritParams call_api_once
#' @return A string with the FIPS formatted for an API request.
#'
get_geo_url <- function(geoid) {

  split_geo <- function(geoid) {
    list(
      st = substr(geoid, 1, 2),
      co = substr(geoid, 3, 5),
      tr = substr(geoid, 6, 11),
      bg = substr(geoid, 12, 12),
      bl = substr(geoid, 12, 15)
    )
  }

  newgeo <- split_geo(geoid)
  st <- newgeo$st; co <- newgeo$co; tr <- newgeo$tr;
  bg <- newgeo$bg; bl <- newgeo$bl

  if(bl != ""){
    # if using blocks
    paste(
      "&for=block:", bl,
      "&in=state:", st,
      "+county:", co,
      "+tract:", tr,
      sep = ""
    )

  } else if(bg != ""){
    # block groups
    paste(
      "&for=block+group:", bg,
      "&in=state:", st,
      "+county:", co,
      "+tract:", tr,
      sep = ""
    )

  } else if(tr != ""){
    # tracts
    paste(
      "&for=tract:", tr,
      "&in=state:", st,
      "+county:", co,
      sep = ""
    )
  } else {
    # if using counties
    paste(
      "&for=county:", co,
      "&in=state:", st,
      sep = ""
    )
  }


}
