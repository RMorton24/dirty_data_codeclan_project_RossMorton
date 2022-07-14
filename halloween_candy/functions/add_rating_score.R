#' Add rating column to data table
#' 
#' Adds an additional column to the current data frame using the following
#' criteria:
#' joy = +1
#' despair = -1
#' meh = 0
#' 
#' Note- the search of character string is case insensitive (i.e."D" == "d" )
#' 
#' This requires the function `column_validity()` to be loaded
#' 
#' @param .data 
#'
#' @return output_data - Modified data table with added scoring
#' @export
#'
#' @examples
#' #' # Create data.frame
#' joyous_data <- data.frame(matrix(c("despair", "joy", "meh"), 3, 2))
#' 
#' # Add scoriting to the table
#' joyous_data <- add_rating_score(joyous_data)
#' 
add_rating_score <- function(.data){
  
  # Check if the column `thoughts` is in the data and type of input
  stopifnot("Input class invalid" = is.data.frame(.data) | is_tibble(.data),
            "Missing 'thoughts' column in data" = "thoughts" %in% names(.data)
  )
  # Create the pattern to search
  pattern_search <- "^(?i)despair$|^(?i)joy$|^(?i)meh$"
  
  # Check the column validity
  #  From source here::here("/functions/column_validity_function.R")
  column_validity(.data, "thoughts", pattern_search, FALSE)
  
  # Add the ratings column
  output_data <- .data %>% 
    mutate(rating = case_when(
      str_detect(thoughts, "(?i)despair") ~ -1,
      str_detect(thoughts, "(?i)joy") ~ 1,
      str_detect(thoughts, "(?i)meh") ~ 0,
      TRUE ~ NA_real_
    ))
  
  return(output_data)
}




