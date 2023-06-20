#' Import info data files
#'
#' @param file_path contains here(path of the file)
#'
#' @return info_data
import_user_info <- function(file_path) {
    info_data <- vroom::vroom( #do not forget vroom:: (no need to load library)
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
import_saliva_data <- function(file_path) {
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
