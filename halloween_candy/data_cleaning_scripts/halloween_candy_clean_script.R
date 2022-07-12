## Script Information -------------------------------------------------------
##
## Script name:  halloween_candy_clean_script.R
##
## Purpose of script: 
##  The script is used to merge and clean halloween candy files
##    - boing-boing-candy-2015.xlsx
##    - boing-boing-candy-2016.xlsx
##    - boing-boing-candy-2017.xlsx
##
## Author: Ross Morton
##
## Date Created: 2022/07/01
## 
## Output:
##  halloween_candy_clean.csv : 
##      Cleaned data of .csv file.
##      - 
## 
##
##/////////////////////////////////////////////////////////////////////////////
##
## Notes:
##   Packages required to be installed-
##        {tidyverse}
##        {janitor}
##        {assertr}
##
##
##    Data file require:
##      -  boing-boing-candy-2015.xlsx
##      - boing-boing-candy-2016.xlsx
##      - boing-boing-candy-2017.xlsx
##
## ////////////////////////////////////////////////////////////////////////////

# Read in Libraries -------------------------------------------------------

library(tidyverse)
library(readxl)
library(janitor)


# Load in functions -------------------------------------------------------

# Load in the `column_name_replace()` function
source(here::here("data_cleaning_scripts/column_rename_function.R"))


# Read in data ------------------------------------------------------------

hwc_2015 <- read_xlsx(here::here("raw_data/boing-boing-candy-2015.xlsx")) %>% 
  clean_names()
hwc_2016 <- read_xlsx(here::here("raw_data/boing-boing-candy-2016.xlsx")) %>% 
  clean_names()
hwc_2017 <- read_xlsx(here::here("raw_data/boing-boing-candy-2017.xlsx")) %>% 
  rename_with(~str_remove(.x, "^Q[:digit:]")) %>% 
  clean_names()



# Clean data --------------------------------------------------------------

# Search string - uses regex input
old_vector <- c("how_old", "trick|going_out", "country", "state_prov", "_gender")
# output name (!must match the length of )
new_vector <- c("age", "trick_or_treat", "country", "region", "gender")

hwc_2015 <- hwc_2015 %>% 
  column_name_replace(old_vector, new_vector) %>% 
  select(-starts_with(c("please","fill", "that_dress", "if_you","guess")))

hwc_2016 <- hwc_2016 %>% 
  column_name_replace(old_vector, new_vector)

hwc_2017 <- hwc_2017 %>% 
  column_name_replace(old_vector, new_vector)


  

# column_name_replace <- function(.data, old_names, new_names){
#   
#   # Determine the location of names to replace which match vector check
#   old_index <- str_which(names(.data), str_c(old_names, collapse = "|"))
#   
#   # Extract an array of terms which have been used
#   string_used <- na.omit(str_extract(names(.data), 
#                                      str_c(old_names, collapse = "|")))
#   
#   # Obtain the index of names which are to be used for replacement
#   new_index <- str_which(old_names, 
#                          str_c(string_used, collapse = "|"))
#   
#   # Change the variable names
#   .data %>% 
#     rename_with(~ new_names[new_index], .cols = all_of(old_index))
#   
# }








# 
# names(hwc_2015)[which(!(names(hwc_2015) %in% names(hwc_2016)))]
# 
 names(hwc_2016)[which(!(names(hwc_2016) %in% names(hwc_2017)))]
# 
names(hwc_2015)[which(!(names(hwc_2015) %in% names(hwc_2017)))]



# What is the total number of candy ratings given across the three years. 
# (Number of candy ratings, not the number of raters. Don’t count missing values)
# What was the average age of people who are going out trick or treating?
#   What was the average age of people who are not going trick or treating?
#   For each of joy, despair and meh, which candy bar received the most of these ratings?
#   How many people rated Starburst as despair?
#   For the next three questions, count despair as -1, joy as +1, and meh as 0.
# 
# What was the most popular candy bar by this rating system for each gender in the dataset ?
#   What was the most popular candy bar in each year?
#   What was the most popular candy bar by this rating for people in US, Canada, UK, and all other countries?




# hwc_2015 <- hwc_2015 %>% 
#   rename_with(~new_name[~str_which(.x, paste(old_names, sep = "|"))], .cols = contains(paste(old_names, sep = "|")))
# 
# hwc_2016 <- hwc_2016 %>% 
#   rename_with(~new_name[which(~str_detect(.x, old_names))], .cols = contains(old_names))
# 
# hwc_2017 <- hwc_2017 %>% 
#   rename_with(~new_name[which(str_detect(.x, old_names))], .cols = contains(old_names))