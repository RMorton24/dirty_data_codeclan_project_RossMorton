## Script Information -------------------------------------------------------
##
## Script name:  seabirds_clean_script.R
##
## Purpose of script: 
##  The script is used to merge and clean seabirds excel file (seabirds_raw.xls)
##    - sheet - "Bird data by record ID"
##    - Sheet - "Shipping data by record ID"
##
## Author: Ross Morton
##
## Date Created: 2022/07/11
## 
## Output:
##    birds_clean.csv : 
##      Cleaned data of .xls file.
##      - Load in the bird data codes to aid in loading columns correctly
##      - Load in shipping data and convert longitude / latitude columns
##      - Load in bird data
##      - Rename columns, select columns and remove missing bird data
##      - Join with shipping data using the record id
##      - Clean the species columns by removing age, plumage and sex characters
##      - If the record id and species data is the same, then combine since
##        age etc. has now been removed.
## 
##
##/////////////////////////////////////////////////////////////////////////////
##
## Notes:
##   Packages required to be installed-
##        {tidyverse}
##        {janitor}
##        {readxl}
##        {rstudioapi}
##
##
##    Data file require:
##        seabirds_raw.xls
##
## ////////////////////////////////////////////////////////////////////////////

## Read in Libraries -------------------------------------------------------

library(tidyverse)
library(readxl)
library(janitor)
library(rstudioapi)



## Load in bird column names----------------------------------------------------

# Get the column types based off of the bird code sheet
# Note that this was added in due to the warning for columns becoming incorrect
# values- so creating a vector of strings to give what each column is.
bird_code_class <- read_xls(here::here("raw_data/seabirds_raw.xls"),
                      sheet = "Bird data codes", skip = 1) %>% 
  clean_names() %>% 
  drop_na(label) %>%
  distinct(label) %>% 
  mutate(class_detection = case_when(
    str_detect(label, "^N") | str_to_lower(label) == "count" | 
      str_detect(label, "(?i)record") | str_detect(label, "^WAN") ~ "numeric",
    TRUE ~ "text"
  )) %>% 
  pull(class_detection)



# Load and clean the shipping ---------------------------------------------

shipping <- read_xls(here::here("raw_data/seabirds_raw.xls"),
                     sheet = "Ship data by record ID") %>% 
  clean_names() %>% 
  select(c("record_id", "lat", "long")) %>%
  rename("longitude" = long,
         "latitude" = lat)



# Load and clean birds ----------------------------------------------------

birds <- read_xls(here::here("raw_data/seabirds_raw.xls"),
                  sheet = "Bird data by record ID", 
                  col_types = bird_code_class) %>% 
  # Clean the column names to snake_case etc.
  clean_names() %>% 
  # Shorten species column names and rename count
  rename_with(~str_remove(.x, "_tax.*")) %>%
  rename("number_birds" = "count") %>% 
  # Select desired columns
  select(starts_with("record"), contains("species_"), "number_birds") %>% 
  # Filter to remove blank data fields in column name
  filter(str_to_upper(species_common_name) != "[NO BIRDS RECORDED]" &
           !is.na(number_birds)) %>% 
  # Join the shipping and shipping and birds data
  left_join(shipping, by = c("record_id" = "record_id")) %>%
  # Remove the age and plumage from species columns
  mutate(across(contains("species_"),~str_remove_all(.x, " [A-Z0-9 ]*$"))) %>% 
  #  Add each age, plumage which have the same record ID and bird together
  group_by(record_id, species_common_name) %>% 
  mutate(number_birds = sum(number_birds)) %>% 
  select(-record) %>% 
  ungroup() %>% 
  distinct()
 


## Write output ------------------------------------------------------------

write_csv(birds, here::here("clean_data/birds_cleaned.csv"))



# Clean global environment ------------------------------------------------

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
