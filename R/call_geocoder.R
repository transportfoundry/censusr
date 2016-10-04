#' Retrieve GEOID from the Census Geocoder by address
#'
#' Returns GEOID for 2010 geographies.
#'
#' @param address A tibble/data frame with the following character columns at
#'   a minimum: street, city, state.
#' @param geoid_type GEOID level to return, \code{c('co', 'tr', 'bg', 'bl')}.
#'   Defaults to block.
#'
#' @return the original tibble with GEOIDs appended as a new column called
#'   \code{geoid}.
#'
#' @examples
#' airports <- data_frame("street" = "700 Catalina Dr", "city" = "Daytona Beach",
#'                        "state" = "FL")
#' airports %>% append_geoid('tr')
#'
#' @importFrom dplyr mutate
#' @export
append_geoid <- function(address, geoid = 'bl') {
  # If street, city, or state columns are factors, convert them
  # Call for each row of the data
  geoids <- vector(mode="character", length = nrow(address))
  for (i in nrow(address)) {
    geoids[i] <- call_geolocator(
      as.character(address$street[i]),
      as.character(address$city[i]),
      as.character(address$state[i])
      )
  }

  # Append onto database
  address <- mutate(address, geoid = geoids)

  # AABBBCCCCCCDEEE
  if (geoid == 'co') {
    end <- 5
  } else if (geoid == 'tr') {
    end <- 11
  } else if (geoid == 'bg') {
    end <- 12
  } else {
    end <- 15
  }

  return(mutate(address, geoid = substr(geoid, 1, end)))
}


#' Call gelocator for one address
call_geolocator <- function(street, city, state) {
  # Build url
  call_start <- "https://geocoding.geo.census.gov/geocoder/geographies/address?"

  url <- paste0(
    "street=", URLencode(street),
    "&city=", URLencode(city),
    "&state=", state
  )

  call_end <- "&benchmark=Public_AR_Census2010&vintage=Census2010_Census2010&layers=14&format=json"

  url_full <- paste0(call_start, url, call_end)

  # Check response
  r <- httr::GET(url_full)
  httr::stop_for_status(r)
  response <- httr::content(r)
  if (length(response$result$addressMatches) == 0) {
    message(paste0("Address (",
                   street, " ", city, " ", state,
                   ") returned no address matches. An NA was returned."))
    return("NA")
  } else if (length(response$result$addressMatches) != 1) {
    message(paste0("Address (",
                   street, " ", city, " ", state,
                   ") returned more than one address match. The first match was returned."))
  }

  # Return
  return(response$result$addressMatches[[1]]$geographies$`Census Blocks`[[1]]$GEOID)
}
