#' Import info data files
#'
#' @param file_path contains here(path of the file)
#'
#' @return info_data
import_user_info <- function(file_path) {
  info_data <- vroom::vroom( # do not forget vroom:: (no need to load library)
    file_path,
    col_select = -1,
    col_types = vroom::cols(
      vroom::col_skip(),
      gender = vroom::col_character(),
      weight = vroom::col_double(),
      height = vroom::col_double(),
      age = vroom::col_double()
    ), # col_types to force the type of data
    .name_repair = snakecase::to_snake_case
  ) # Import data again
  return(info_data)
}

#' Import saliva data
#'
#' @param file_path contains here(path of the file)
#'
#' @return saliva_data
import_saliva <- function(file_path) {
  saliva_data <- vroom::vroom(
    file_path,
    col_select = -1,
    col_types = vroom::cols(
      vroom::col_skip(),
      samples = vroom::col_character(),
      cortisol_norm = vroom::col_double(),
      melatonin_norm = vroom::col_double()
    ),
    .name_repair = snakecase::to_snake_case
  )
  return(saliva_data)
}

#' Import RR data
#'
#' @param file_path contains here(path of the file)
#'
#' @return rr_data
import_rr <- function(file_path) {
  rr_data <- vroom::vroom(
    file_path,
    col_select = -1,
    col_types = vroom::cols(
      vroom::col_skip(),
      ibi_s = vroom::col_double(),
      day = vroom::col_double(),
      time = vroom::col_time(format = "")
    ),
    .name_repair = snakecase::to_snake_case
  )
  return(rr_data)
}

#' Import Actigraph data
#'
#' @param file_path contains here(path of the file)
#'
#' @return actigraph_data
import_actigraph <- function(file_path) {
  actigraph_data <- vroom::vroom(
    file_path,
    col_select = -1,
    col_types = vroom::cols(
      vroom::col_skip(),
      axis_1 = vroom::col_double(),
      axis_2 = vroom::col_double(),
      axis_3 = vroom::col_double(),
      steps = vroom::col_double(),
      hr = vroom::col_double(),
      inclinometer_off = vroom::col_double(),
      inclinometer_standing = vroom::col_double(),
      inclinometer_sitting = vroom::col_double(),
      inclinometer_lying = vroom::col_double(),
      vector_magnitude = vroom::col_double(),
      day = vroom::col_double(),
      time = vroom::col_time(format = "")
    ),
    .name_repair = snakecase::to_snake_case
  )
  return(actigraph_data)
}

#' Import multiple files
#'
#' @param file_pattern the name of the files to import
#' @param import_function the function (as an object) to import the files
#'
#' @return combined_data
import_multiple_files <- function(file_pattern, import_function) {
  data_files <- fs::dir_ls(
    here::here("data-raw/mmash/"),
    regexp = file_pattern,
    recurse = TRUE
  )
  combined_data <- purrr::map(
    data_files,
    import_function
  ) %>%
    purrr::list_rbind(names_to = "file_path_id") %>%
    extract_user_id()
  return(combined_data)
}

#' Extract user ID
#'
#' @param imported_data dataframe with imported data
#'
#' @return data_with_user_id
extract_user_id <- function(imported_data) {
  data_with_user_id <- imported_data %>%
    dplyr::mutate(
      user_id = stringr::str_extract(
        file_path_id,
        "user_[1-9][0-9]?"
      ),
      .before = everything()
    ) %>%
    dplyr::select(-file_path_id)
  return(data_with_user_id)
}

#' Summarise data by day
#'
#' @param data data to be summarised
#'
#' @return daily_summary
tidy_summarise_by_day <- function(data, summary_fn) {
  daily_summary <- data %>%
    dplyr::select(-samples) %>%
    tidyr::pivot_longer(c(-user_id, -day, -gender)) %>%
    tidyr::drop_na(day, gender) %>%
    dplyr::group_by(gender, day, name) %>%
    dplyr::summarise(dplyr::across(
      value,
      summary_fn
    )) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(dplyr::across(
      dplyr::starts_with("value"),
      ~ round(.x, digits = 2)
    )) %>%
    tidyr::pivot_wider(
      names_from = day,
      values_from = starts_with("value")
    )
  return(daily_summary)
}

#' Import activity
#'
#' @param file_path path to the "Activity.csv" file
#'
#' @return imported_activity_data
import_activity <- function(file_path) {
  imported_activity_data <- vroom::vroom(
    file_path,
    col_select = -1,
    col_types = vroom::cols(
      vroom::col_skip(),
      activity = vroom::col_double(),
      start = vroom::col_time(format = ""),
      end = vroom::col_time(format = ""),
      day = vroom::col_double()
    ),
    .name_repair = snakecase::to_snake_case
  )
  return(imported_activity_data)
}
