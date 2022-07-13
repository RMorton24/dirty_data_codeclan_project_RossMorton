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
##  halloween_candy_clean.rds : 
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
library(assertr)


# Load in functions -------------------------------------------------------

# Load in the `column_name_replace()` function
source(here::here("data_cleaning_scripts/column_rename_function.R"))


# Read in data ------------------------------------------------------------
# Note that some columns will be re
hwc_2015 <- read_xlsx(here::here("raw_data/boing-boing-candy-2015.xlsx"))

hwc_2016 <- read_xlsx(here::here("raw_data/boing-boing-candy-2016.xlsx"))

hwc_2017 <- read_xlsx(here::here("raw_data/boing-boing-candy-2017.xlsx"))




# Clean Column names------------------------------------------------------------

# Search string - uses regex input
old_vector <- c("how_old", "trick|going_out", "country", "state_prov", "_gender",
                "brown_globs", "third_party", "bonkers", "raisins",
                "kissa", "late_hersh", "^l.*y.*k",
                "sweetums", "internal_id")
# output name (!must match the length of )
new_vector <- c("age", "trick_or_treat", "country", "region", "gender",
                "annonym_brown_globs", "independent_m_ms", "bonkers", "raisins",
                "hersheys_kisses", "hersheys_dark_chocolate", "licorice",
                "sweetums", "id_num")

hwc_2015 <- hwc_2015 %>% 
  select(2:3 , starts_with("[")) %>% 
  clean_names() %>% 
  column_name_replace(old_vector, new_vector) %>% 
  rowid_to_column("id_num") %>% 
  mutate(id_num = as.numeric(paste0("2015",str_pad(id_num, 5, pad = "0")))) %>% 
  mutate(data_year = 2015L, .after = id_num)
  #select(-starts_with(c("please","fill", "that_dress", "if_you","guess", "check")))

hwc_2016 <- hwc_2016 %>% 
  select(2:6 , starts_with("["), -ends_with("Ignore"), 
         -contains(c("DVD", "board"))) %>%
  clean_names() %>% 
  column_name_replace(old_vector, new_vector) %>% 
  rowid_to_column("id_num") %>% 
  mutate(data_year = 2017L, .after = id_num) %>% 
  mutate(id_num = as.numeric(paste0("2016",str_pad(id_num, 5, pad = "0")))) %>% 
  mutate(data_year = 2016L, .after = id_num)

hwc_2017 <- hwc_2017 %>%
  select(1:6 , starts_with("Q6"), -contains(c("housewives", "board"))) %>%
  rename_with(~str_remove(.x, "^Q[:digit:]")) %>% 
  clean_names() %>% 
  column_name_replace(old_vector, new_vector) %>% 
  mutate(id_num = as.numeric(paste0("2017", 
                                    str_pad(row_number(), 5, pad = "0")))) %>% 
  mutate(data_year = 2017L, .after = id_num)



# Combine data sets -------------------------------------------------------

candy <- bind_rows(hwc_2017, hwc_2016, hwc_2015)


# Clean Row data ----------------------------------------------------------
  
candy <- candy %>% 
  # Extract the numbers from the character array (will cause NA's for missing)
  mutate(age = str_extract(age, "[:digit:]{1,3}[\\.[:digit:]]{0,5}")) %>% 
  # If age is below 5 then set to an error
  mutate(age = if_else(as.numeric(age) < 5, NA_real_, as.numeric(age))) %>% 
  mutate(country = str_to_title(str_remove_all(country, "[:punct:]|(?i)the "))) %>% 
  # Correct the country names
  mutate(country = case_when(
    # Remove numeric and set errors if required
    !is.na(as.numeric(country)) | str_detect(country, "^Not") ~ NA_character_,
    # Check for forms of United States
    str_detect(country, 
               paste0("(?i)[esd] s[ta]|(?<![Aa])(?i)u[ sd]{1,2}|(?i)m[ue]r{1,2}",
                      "|Tru|y{4}$|(?i)w [yj]|(?i)ca[rl][oi]|(?i)pit|(?i)^Ala")) 
               ~ "United States",
    # Check for forms of United Kingdom
    str_detect(country, "(?i)uk|d k|^(?i)En[dg]|(?i)Scot") ~ "United Kingdom",
    # Check for Canada
    str_detect(country, "(?i)can") ~ "Canada",
    # Check for spain
    country == "España" ~ "Spain",
    # Otherwise set to current country
    TRUE ~ country
  )) %>% 
  # Convert to pivot for easier analysis
  # NOTE THAT THIS WILL DUPLICATE THE FIRST FEW ROWS BEFORE "REGION"
  pivot_longer((str_which(names(candy), "region")+1):last_col(), 
                 names_to = "sweet_name", values_to = "thoughts")


# Write Output -------------------------------------------------------------
write_rds(candy, here::here("clean_data/halloween_candy_clean.rds"))




# 
# names(hwc_2015)[which(!(names(hwc_2015) %in% names(hwc_2016)))]
# 
# names(hwc_2016)[which(!(names(hwc_2016) %in% names(hwc_2017)))]
# # 
# names(hwc_2015)[which(!(names(hwc_2015) %in% names(hwc_2017)))]
# 
# names(hwc_2017)[which(!(names(hwc_2017) %in% names(hwc_2016)))]

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