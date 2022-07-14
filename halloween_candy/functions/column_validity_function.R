#' Check Column Data Validity
#' 
#' Prints a warning if the pattern does not find variables from the data frame
#' column. A vector of column names can be applied but only one search string.
#'
#'
#' @param .data - Data.Frame to search
#' @param column_names - Character vector of column names
#' @param search_pattern - Search pattern
#' @param print_check - Print if all is ok- False will not print anything if 
#' acceptable
#'
#' @return - Warnings and column values with missed in pattern
#' @export
#'
#' @examples
#' # Create data.frame
#' joyous_data <- data.frame(matrix(c("despair", "joy", "meh"), 3, 2))
#' 
#' # What column names do we want to search
#' columns_to_check <- c("X1","X2")
#' 
#' # Pattern we want to use for searching
#' pattern_for_seach <- "^(?i)despair$|^(?i)joy$|^(?i)meh$"
#' 
#' # Check pattern
#' column_validity(joyous_data, columns_to_check, pattern_for_seacrh, TRUE)
#' 
#' # Search another pattern
#' other_pattern<- "^(?i)despair$|^(?i)joy$|bannana"
#' 
#' column_validity(joyous_data, columns_to_check, other_pattern, TRUE)
#' 
column_validity <- function(.data, column_names, search_pattern, print_check = TRUE){
  # Loop through the columns
  for (col_num in 1:length(column_names)){
    # Set column name
    column_check <- select(.data, column_names[col_num])
    
    # Check if values not found with pattern
    if (sum(!str_detect(unlist(column_check), search_pattern), na.rm = TRUE) > 0){
      # Get all unique values in column
      column_check <- unique(column_check)
      # Print warning with column name and variables missing with the pattern
      warning("\nData in ", names(column_check), " are not found with pattern ",
              "=>: ", search_pattern ,"\n Variable Names:\n", 
              paste0("=> ", column_check[which(!str_detect(unlist(column_check), 
                                                           search_pattern)),], 
                     sep = "\n")
      )
    }else{
      #  Column values have all been found check to see if print is wanted
      if (print_check == TRUE){
        cat(paste0("Values in ", names(column_check), 
                   " all found with pattern\n"))
      }
      
    }
  }
}