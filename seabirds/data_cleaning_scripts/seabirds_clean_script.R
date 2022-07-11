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
##      - 
## 
##
##/////////////////////////////////////////////////////////////////////////////
##
## Notes:
##   Packages required to be installed-
##        {tidyverse}
##        {janitor}
##        {readxl}
##
##
##    Data file require:
##        seabirds_clean.csv
##
## ////////////////////////////////////////////////////////////////////////////

## Read in Libraries -------------------------------------------------------

library(tidyverse)
library(readxl)
library(janitor)



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
  




# mutate(species_common_name = str_remove_all(species_common_name, 
  #                                             " [A-Z0-9]{2,5}")) %>% 
  # mutate(species_scientific_name = str_remove_all(species_scientific_name, 
  #                                             " [A-Z0-9]{2,5}")) %>% 
  # mutate(species_abbreviation = str_remove_all(species_abbreviation, 
  #                                                 " [A-Z0-9]{2,5}")) %>% 
  # arrange(species_scientific_name)

#46320

 # birds %>%
 #   filter(!is.na(species_abbreviation)) %>% view()


## Write output ------------------------------------------------------------

write_csv(birds, here::here("clean_data/birds_cleaned.csv"))



# Clean global environment ------------------------------------------------

#rm(list = ls())

# birds %>%
#   summarise(across(.fns = ~sum(is.na(.x)))) %>%
#   view()



# b <- birds %>% 
#   filter(is.na(latitude)) %>%
#   distinct(record_id) %>% pull()
#          
# 
# birds_raw <- read_xls(here::here("raw_data/seabirds.xls"),
#                       sheet = "Bird data by record ID", 
#                       col_types = bird_code_class) %>% 
#   clean_names() %>% 
#   rename_with(~str_remove(.x, "_tax.*"))
# 
# birds %>%
#   filter(is.na(count)) %>% 
#   view()
# 
# c <- birds %>% 
#   filter(is.na(species_scientific_name))
# 
# 
# birds_raw %>% 
#   filter(str_detect(species_common_name, "[A-Z1-9]{2,5}")) %>% 
#   view()
# 
# 
# birds %>% 
#   summarise(across(.fns = ~sum(is.na(.x)))) %>% 
#   view()
# 
# 
# birds_raw %>% 
#   summarise(across(.fns = ~sum(is.na(.x)))) %>% 
#   view()




