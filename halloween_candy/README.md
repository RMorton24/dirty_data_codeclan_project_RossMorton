# Dirty Data Project Task 4 - Haloween Candy
> The following tasks are from the dirty data project at CodeClan as part of the
Professional Data Anlayst course (week 4). The work within the repository shows
the cleaning scripts, data and analysis.

## Information
> The repository cleans three data sets for candy ratings (2015-2017) and 
combines into one data file. This is the data is then analysed based upon the 
output from this. All scripts and data are stored with this.

## Installations
Ensure the following packages are installed prior to running:

+ tidyverse
+ janitor
+ assertr
+ readxl
+ rstudioapi

__Run the following if required to install__
```
install.packages(tidyverse)
install.packages(janitor)
install.packages(assertr)
install.packages(testthat)
install.packages(rstudioapi) # may be in tidyverse
install.packages(readxl) # may be in tidyverse

```

## Folder Structure

The folder structure is the following:

| Folder | Description |
| :------|:-----------:|
| **clean_data** | contains the cleaned |
| **data_cleaning_scripts** | Contains the script for cleaning the raw data |
| **analysis_and_documentation** | Contains files which analyse the cleaned data |
| **functions** | Contains any functions created for cleaning/analysis |
| **raw_data** | Contains the raw data |

## Cleaning file

Purpose of script:
 The script is used to merge and clean halloween candy files:
 
   + boing-boing-candy-2015.xlsx
   + boing-boing-candy-2016.xlsx
   + boing-boing-candy-2017.xlsx


Output:
 halloween_candy_clean.rds :
 
 Cleaned data of as .rds file.
 
 * Import in all data sets and functions for cleaning
 * Modify the column names in each data set for alignment/remove extras
 * Add year and id_num columns for ease when data is combined
 * Combine all three datasets using the 2017 data as the primary
 * Complete pivot longer to make the analysis easier (note this will
 provide duplications of rows before the candy results)
 * Clean the age and country columns
 * Check the candy column (warnings may appear if incorrect but will
 continue running script - please read and clean columns if needed)
 * Write the data to a halloween_candy_clean.rds
 
[Link to raw data](raw_data/)

[Link to cleaning script](cleaning_script/halloween_candy_clean_script.R)

[Link to cleaned data](clean_data/halloween_candy_clean.rds)


### Functions

The following functions are contained within the cleaning file:

* `column_validity()` - Prints a warning if the pattern does not find variables 
                        from the data frame column. A vector of column names 
                        can be applied but only one search string.

| Arguments | Description |
| :---------|:-----------:|
| .data | Data frame to check |
| column_names | Name of columns as character vector to check |
| search_pattern | Character/Regex to be used for search |
| print_check | Print output if no issues detected(Set to **TRUE** automatically) |

[Link to function](functions/column_validity_function.R)

Code:
```
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
```
</br>
</br>

* `column_name_replace()` - Searching for strings (can use `regex`) with `old_names` before 
                            changing them to the new names stored within `new_names`.
                            Output is a modified Data.Frame.

| Arguments | Description |
| :---------|:-----------:|
| .data | Data frame to change |
| old_names | Character vector to find current column names |
| new_names | Character vector of new column names |

[Link to function](functions/column_rename_function.R)

Code:
```
column_name_replace <- function(.data, old_names, new_names){
  
  stopifnot("Column search and replacement vectors are different lengths" = 
              length(old_names) == length(new_names))
  
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
```

## Analysis file

The .Rmd file is to analyse the halloween_candy_clean.rds file.
The raw data set is a csv for each year (2015-2017) and is stored within the 
/raw_data sub folder. This has been cleaned as mentioned above.

[Link to analysis](analysis_and_documentation/halloween_candy_analysis.rmd)

[Link to analysis rmd output](analysis_and_documentation/halloween_candy_analysis.html)

[Link to raw data](raw_data/)

[Link to cleaning script](cleaning_script/halloween_candy_clean_script.R)

[Link to cleaned data](clean_data/halloween_candy_clean.rds)

Purpose of this file is to analyse some particular points of the data set.
Primarilay this is:

1. What is the total number of candy ratings given across the three years.
(Number of candy ratings, not the number of raters. Don’t count missing values)
2. What was the average age of people who are going out trick or treating?
3. What was the average age of people who are not going trick or treating?
4. For each of joy, despair and meh, which candy bar received the most of these 
ratings?
5. How many people rated Starburst as despair?
+ For the next three questions, count despair as -1, joy as +1, and meh as 0.
6. What was the most popular candy bar by this rating system for each gender in 
the dataset ?
7. What was the most popular candy bar in each year?
8. What was the most popular candy bar by this rating for people in US, Canada, 
UK, and all other countries?

### Functions Used

Functions used within the analysis files are:

**Also in cleaning script**

* `column_validity()` - Prints a warning if the pattern does not find variables 
                        from the data frame column. A vector of column names 
                        can be applied but only one search string.

| Arguments | Description |
| :---------|:-----------:|
| .data | Data frame to check |
| column_names | Name of columns as character vector to check |
| search_pattern | Character/Regex to be used for search |
| print_check | Print output if no issues detected(Set to **TRUE** automatically) |

[Link to function](functions/column_validity_function.R)



</br>
</br>


Code:

* `add_rating_score()` - Prints a warning if the pattern does not find variables 
                        from the data frame column. A vector of column names 
                        can be applied but only one search string.

| Arguments | Description |
| :---------|:-----------:|
| .data | Data frame to change |

[Link to function](functions/add_rating_score.R)

<i>Note that `column_validity()` is required to complete this function and
should therefore be loaded into the Global Environment before running.</i>

```
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
```
