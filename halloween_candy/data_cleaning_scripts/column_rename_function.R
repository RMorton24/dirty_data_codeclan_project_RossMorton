#' Converts names of columns
#'
#' Searching for strings (can have issues `regex`) with `old_names` before 
#' changing them to the new names stored within `new_names`.
#'
#' @param .data 	A data frame, data frame extension (e.g. a tibble), 
#' or a lazy data frame (e.g. from dbplyr or dtplyr)
#' @param old_names A vector of names to search through
#' @param new_names A vector of new column names
#'
#' @return The Tibble/Data frame with renamed column variables
#' @export
#'
#' @examples
#' # A vector with old names
#' current <- c("^P[alpha]*L", "orange", "Species")
#' 
column_name_replace <- function(.data, old_names, new_names){
  
  # # Determine the location of names to replace which match vector check
  # old_index <- str_which(names(.data), str_c(old_names, collapse = "|"))
  # 
  # # Extract an array of terms which have been used
  # string_used <- na.omit(str_extract(names(.data), 
  #                                    str_c(old_names, collapse = "|")))
  # 
  # # Obtain the index of names which are to be used for replacement
  # new_index <- str_which(old_names, 
  #                        str_c(string_used, collapse = "|"))
  # 
  # # Change the variable names
  # .data %>% 
  #   rename_with(~ new_names[new_index], .cols = all_of(old_index))
  

  
  
  for (name_index in 1:length(old_names)){

    if (any(str_detect(names(.data), old_names[name_index]))){
      
      if (sum(new_vector[name_index] == names(.data)) > 1){
        stop(paste("Column name", new_vector[name_index], "already exists"))
      }
      
      
      names(.data)[str_which(names(.data), old_vector[name_index])] <- 
        new_vector[name_index]
    }
  }
  return(.data)
}


# hwc_2017 <- hwc_2017 %>% 
#   rename_with(~new_name[which(str_detect(.x, old_names))], .cols = contains(old_names))