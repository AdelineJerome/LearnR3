library(here) # tell R to first look for the .Rproj file and then start looking for the file we actually want
library(fs)
library(tidyverse)
source(here::here("R/functions.R"))

# Download
mmash_link <- "https://physionet.org/static/published-projects/mmash/multilevel-monitoring-of-activity-and-sleep-in-healthy-people-1.0.0.zip"

# download.file(mmash_link, destfile = here("data-raw/mmash-data.zip"))
# usethis::use_git_ignore("data-raw/mmash-data.zip")

# # Unzip
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
#
# # Remove/tidy up left over files
# file_delete(here(c(
#     "data-raw/MMASH.zip",
#     "data-raw/SHA256SUMS.txt",
#     "data-raw/LICENSE.txt"
# )))
# file_move(here("data-raw/DataPaper"), here("data-raw/mmash"))

user_info_df <- import_multiple_files(
  "user_info.csv",
  import_user_info
)
saliva_df <- import_multiple_files(
  "saliva.csv",
  import_saliva
)
