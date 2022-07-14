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
##      Cleaned data of as .rds file.
##      - Import in all data sets and functions for cleaning
##      - Modify the column names in each data set for alignment/remove extras
##      - Add year and id_num columns for ease when data is combined
##      - Combine all three datasets using the 2017 data as the primary
##      - Complete pivot longer to make the analysis easier (note this will 
##        provide duplications of rows before the candy results)
##      - Clean the age and country columns
##      - Check the candy column (warnings may appear if incorrect but will 
##        continue running script - please read and clean columns if needed)
##      - Write the data to a halloween_candy_clean.rds
## 
##
##/////////////////////////////////////////////////////////////////////////////
##
## Notes:
##   Packages required to be installed-
##        {tidyverse}
##        {janitor}
##        {readxl}
##        {assertr}
##        {rstudioapi}
##
##
##    Data file require:
##      -  boing-boing-candy-2015.xlsx
##      - boing-boing-candy-2016.xlsx
##      - boing-boing-candy-2017.xlsx
##
##
##    At the end of the script, you will be asked if you would like to remove
##    the variables from your global environment.
##
## ////////////////////////////////////////////////////////////////////////////

# Read in Libraries -------------------------------------------------------

library(tidyverse)
library(readxl)
library(janitor)
library(assertr)
library(rstudioapi)


# Load in functions -------------------------------------------------------

# Load in the `column_name_replace()` function
source(here::here("functions/column_rename_function.R"))

# Load in the `column_validity()` function
source(here::here("functions/column_validity_function.R"))


# Read in data ------------------------------------------------------------
# Add 2015 halloween candy data
hwc_2015 <- read_xlsx(here::here("raw_data/boing-boing-candy-2015.xlsx"))

# Add 2016 halloween candy data
hwc_2016 <- read_xlsx(here::here("raw_data/boing-boing-candy-2016.xlsx"))

# Add 2017 haloween candy data
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

# Clean the 2015 column data
hwc_2015 <- hwc_2015 %>% 
  # Remove columns that are not required
  select(contains(c("how old", "trick or")), starts_with("[")) %>% 
  # Clean the names to snake_case
  clean_names() %>%
  # Find if any columns match the old_vector and replace with new_vector
  column_name_replace(old_vector, new_vector) %>% 
  # Add row ID column and mutate to add 2015 and pad to 9 digits
  rowid_to_column("id_num") %>% 
  mutate(id_num = as.numeric(paste0("2015",str_pad(id_num, 5, pad = "0")))) %>% 
  # Add year column
  mutate(data_year = 2015L, .after = id_num)


# Clean 2016 data
hwc_2016 <- hwc_2016 %>% 
  # Select and remove columns not required
  select(contains(c("trick or", " gender", "how old", "country", "state, prov")),
         starts_with("["), -ends_with("Ignore"), -contains(c("DVD", "board"))) %>%
  # Convert to snake_case
  clean_names() %>% 
  # Find if any columns match the old_vector and replace with new_vector
  column_name_replace(old_vector, new_vector) %>% 
  # Add row ID column and mutate to add 2016 and pad to 9 digits
  rowid_to_column("id_num") %>% 
  mutate(id_num = as.numeric(paste0("2016",str_pad(id_num, 5, pad = "0")))) %>% 
  # Add year column
  mutate(data_year = 2016L, .after = id_num)

# Clean 2017 data
hwc_2017 <- hwc_2017 %>%
  # Select and remove columns
  select(contains(c("GOING OUT", " GENDER", " AGE", "COUNTRY", "STATE, PROV")), 
         starts_with("Q6"), -contains(c("housewives", "board"))) %>%
  # Remove the question numbering
  rename_with(~str_remove(.x, "^Q[:digit:]")) %>%
  # Convert to snake_case
  clean_names() %>% 
  # Find if any columns match the old_vector and replace with new_vector
  column_name_replace(old_vector, new_vector) %>% 
  # Convert row ID column and mutate to add 2017 and pad to 9 digits
  mutate(id_num = as.numeric(paste0("2017", 
        str_pad(row_number(), 5, pad = "0"))),
         .before = 1) %>% 
  # Add year column
  mutate(data_year = 2017L, .after = id_num)



# Combine data sets -------------------------------------------------------

candy_clean <- bind_rows(hwc_2017, hwc_2016, hwc_2015)


# Clean Row data ----------------------------------------------------------
  
candy_clean <- candy_clean %>% 
  # Extract the numbers from the character array (will cause NA's for missing)
  mutate(age = str_extract(age, "[:digit:]{1,3}[\\.[:digit:]]{0,5}")) %>% 
  # If age is below 3 or above 122 (oldest ever person) then set to an error
  mutate(age = case_when(
    as.numeric(age) < 3 | as.numeric(age) > 122 ~ NA_real_,
    TRUE ~ as.numeric(age)
  )) %>% 
  # Remove all punctuation and "the" from country column
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
  # Replace missing values in gender column with "I'd rather not say"
  mutate(gender = if_else(is.na(gender), "I'd rather not say", gender)) %>% 
  # Convert to pivot for easier analysis
  # NOTE THAT THIS WILL DUPLICATE THE FIRST FEW ROWS BEFORE "REGION"
  pivot_longer((str_which(names(candy_clean), "region")+1):last_col(), 
                 names_to = "sweet_name", values_to = "thoughts")



# Check validity of candy thoughts ----------------------------------------

# Check if the "thoughts" column only has "DESPAIR.", "JOY" or "MEH" or NA's
column_validity(candy_clean, "thoughts" ,"^(?i)despair$|^(?i)joy$|^(?i)meh$")

# Check if the trick or treat column is yes or no only (still has NA's)
column_validity(candy_clean, "trick_or_treat" ,"Yes|No")


# Write Output -------------------------------------------------------------

# File is compressed since size >100MB otherwise
saveRDS(candy_clean, here::here("clean_data/halloween_candy_clean.rds"),
        compress = TRUE)


# Clean the environment ---------------------------------------------------

ask_for_clear <- showQuestion("Finished Script - Clean Environment?", 
                              "Do you want to clean Environment variables?
                              Note: this will only clean varibles created
                              within this script.",
                              cancel = "No")
if (ask_for_clear == TRUE){
  rm(candy_clean,
     hwc_2015,
     hwc_2016,
     hwc_2017,
     new_vector,
     old_vector,
     column_name_replace,
     column_validity,
     ask_for_clear)
}else{
  rm(ask_for_clear)
}






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