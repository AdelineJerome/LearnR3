library(here) # tell R to first look for the .Rproj file and then start looking for the file we actually want
library(fs)
library(tidyverse)
source(here::here("R/functions.R"))


# Download ----------------------------------------------------------------

mmash_link <- "https://physionet.org/static/published-projects/mmash/multilevel-monitoring-of-activity-and-sleep-in-healthy-people-1.0.0.zip"

# download.file(mmash_link, destfile = here("data-raw/mmash-data.zip"))
# usethis::use_git_ignore("data-raw/mmash-data.zip")


# Unzip -------------------------------------------------------------------

# unzip(here("data-raw/mmash-data.zip"),
#   exdir = here("data-raw"),
#   junkpaths = TRUE
# )
#
# unzip(here("data-raw/MMASH.zip"),
#   exdir = here("data-raw")
# )
#
# # NOTE: You don't need to run this code,
# # its here to show how we got the file list.
# #fs::dir_tree("data-raw", recurse = 1)


# Remove/tidy up left over files ------------------------------------------

# # Remove/tidy up left over files
# file_delete(here(c(
#     "data-raw/MMASH.zip",
#     "data-raw/SHA256SUMS.txt",
#     "data-raw/LICENSE.txt"
# )))
# file_move(here("data-raw/DataPaper"), here("data-raw/mmash"))


# Import data into df -----------------------------------------------------

user_info_df <- import_multiple_files(
  "user_info.csv",
  import_user_info
)
saliva_df <- import_multiple_files(
  "saliva.csv",
  import_saliva
)
rr_df <- import_multiple_files(
  "RR.csv",
  import_rr
)
actigraph_df <- import_multiple_files(
  "Actigraph.csv",
  import_actigraph
)


# Summarised data ---------------------------------------------------------

summarised_rr_df <- rr_df %>%
  group_by(user_id, day) %>%
  summarise(across(ibi_s, list(
    mean = ~ mean(.x, na.rm = TRUE), # and not mean alone so the treatment of missing value can be precised
    sd = ~ sd(.x, na.rm = TRUE) #na.rm = TRUE to exclude missing values
  ))) %>%
  ungroup() # to remove some metadata in the code to avoid issues in further wrangling

summarised_actigraph_df <- actigraph_df %>%
  group_by(user_id, day) %>%
  summarise(across(hr, list(
    mean = ~ mean(.x, na.rm = TRUE),
    sd = ~ sd(.x, na.rm = TRUE)
  ))) %>%
  ungroup()


# Combined datasets -------------------------------------------------------

saliva_with_day_df <- saliva_df %>%
  mutate(day = case_when(
    samples == "before sleep" ~ 1,
    samples == "wake up" ~ 2
  ))

mmash <- list(
  user_info_df,
  summarised_rr_df,
  summarised_actigraph_df,
  saliva_with_day_df
) %>%
  reduce(full_join)

usethis::use_data(mmash, overwrite = TRUE)
# to create a dataset in data/ (create the folder if it does not exists)

saliva_with_day_df %>%
    filter(user_id == "user_8")
