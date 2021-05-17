#' Create new site from template
#'
#' This function creates a new website from a template stored within the package.
#'
#' @param dir_path The directory path where the new site should be located.
#' @return The output is a directory containing the template version of a site.
#' @export
#' @examples \dontrun{
#' directory_name("test_location")
#' }
#'
create_website <- function(dir_path, open = rlang::is_interactive()){
  # dir_path <- here("vignettes/MyFirstInfographiq"); open = T
  # unlink(dir_path, recursive = T)
  
  if (dir.exists(dir_path)){
    stop(paste("Error: the directory -", dir_path, "- already exists."))
    
  }
  dir_template <- system.file("template_website", package = "infographiqR")
  
  file.copy(dir_template, dirname(dir_path), recursive = T)
  dir_tmp <- file.path(dirname(dir_path), basename(dir_template))
  file.rename(dir_tmp, dir_path)
  
  if (open)
    servr::httd(dir_path)
}

#' Generate introductory info for the html of a modal window
#'
#' This function generates the html tags for the top portion of a rmd modal window,
#' containing the introductory information about that window. This function only
#' will work within a rmd file to be knitted.
#'
#' @param rmd  The name of an input file passed to knit().
#' @param info_modal_links_csv A hyperlink to the google sheet, in csv format, that contains the modal links info.
#' @return The function returns a string that is a set of html tags to be inserted into a html file.
#' @export
#' @examples \dontrun{
#' get_modal_info()
#' }
#'
get_modal_info <- function(
  rmd = knitr::current_input(),
  info_modal_links_csv = "https://docs.google.com/spreadsheets/d/1yEuI7BT9fJEcGAFNPM0mCq16nFsbn0b-bNirYPU5W8c/gviz/tq?tqx=out:csv&sheet=info_modal_links"){
  
  modal_id <- basename(fs::path_ext_remove(rmd))
  row <- readr::read_csv(info_modal_links_csv) %>%
    dplyr::filter(modal == modal_id)
  
  if (nrow(row) == 0) stop("Need link in cinms_content:info_modal_links Google Sheet!")
  
  icons_html = NULL
  if (!is.na(row$url_info)){
    icons_html =
      htmltools::a(shiny::icon("info-circle"), href=row$url_info, target='_blank')
  }
  if (!is.na(row$url_photo)){
    icons_html = htmltools::tagList(
      icons_html,
      htmltools::a(shiny::icon("camera"), href=row$url_photo, target='_blank'))
  }
  
  htmltools::div(
    htmltools::div(htmltools::tagList(icons_html), style = "margin-top: 10px;margin-bottom: 10px; margin-right: 10px; flex: 1;"), htmltools::div(
      ifelse(!is.na(row$tagline), row$tagline, ""), style = "margin: 10px; font-style: italic; flex: 20; "), style="display: flex"
    
  )
}