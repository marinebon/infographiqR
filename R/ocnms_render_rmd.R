#' OCNMS version: generate introductory info for the html of a modal window
#'
#' This function generates the html tags for the top portion of a rmd modal window,
#' containing the introductory information about that window. This function only
#' will work within a rmd file to be knitted.
#'
#' @param rmd  The name of an input file passed to knit().
#' @return The function returns a string that is a set of html tags to be inserted into a html file.
#' @export
#' @examples \dontrun{
#' ocnms_get_modal_info()
#' }
#'
ocnms_get_modal_info <- function(rmd = knitr::current_input()){
  
  modal_id <- basename(fs::path_ext_remove(rmd))
  row <- ocnms_get_sheet(sheets_tab = "pages") %>%
    dplyr::filter(svg == modal_id)
  
  if (nrow(row) == 0) stop("Need link in Master_OCNMS_infographic_content:modals Google Sheet!")
  
  icons_html = NULL
  if (!is.na(row$info_link)){
    icons_html =
      htmltools::a(shiny::icon("info-circle"), href=row$info_link, target='_blank')
  }
  if (!is.na(row$info_photo_link)){
    icons_html = htmltools::tagList(
      icons_html,
      htmltools::a(shiny::icon("camera"), href=row$info_photo_link, target='_blank'))
  }
  
  htmltools::div(
    htmltools::div(htmltools::tagList(icons_html), style = "margin-top: 10px;margin-bottom: 10px; margin-right: 10px; flex: 1;"), htmltools::div(
      ifelse(!is.na(row$info_tagline), row$info_tagline, ""), style = "margin: 10px; font-style: italic; flex: 20; "), style="display: flex"
    
  )
}

#' OCNMS version: get contents of tab of google spreadsheet
#'
#' This function retrieves the contents of a tab of a google spreadsheet that is 
#' protected.
#'
#' @param gsheet Link to the target google sheet.
#' @param sheets_tab The tab of the google sheet to be returned.
#' @return The function returns the contents of a tab of a google sheet.
#' @export
#' @examples \dontrun{
#' ocnms_get_sheet(sheets_tab = "figures")
#' }
#'
ocnms_get_sheet <- function(gsheet = "https://docs.google.com/spreadsheets/d/1C5YAp77WcnblHoIRwA_rloAagkLn0gDcJCda8E8Efu4/edit",
                            sheets_tab){

  gsheets_sa_json <- switch(
    Sys.info()[["effective_user"]],
    bbest      = "/Volumes/GoogleDrive/My Drive/projects/nms-web/data/nms4gargle-774a9e9ec703.json",
    jai        = "/Volumes/GoogleDrive/My Drive/service-tokens/nms4gargle-774a9e9ec703.json",
    PikesStuff = "/Users/PikesStuff/Theseus/Private/nms4gargle-774a9e9ec703.json")
  
  # ensure secret JSON file exists
  stopifnot(file.exists(gsheets_sa_json))
  
  # authenticate to GoogleSheets using Google Service Account's secret JSON
  googlesheets4::gs4_auth(path = gsheets_sa_json)
  
  # return desired tab of the google sheet
  googlesheets4::read_sheet(gsheet, sheets_tab)
}

#' OCNMS version: create Infographiq link table
#'
#' This function creates or updates the link table used by the Infographiq Javascript. The data for 
#' the link table is pulled from the protected google sheet.
#'
#' @return The function creates or updates the link table used by the Infographiq Javascript.
#' @export
#' @examples \dontrun{
#' ocnms_create_link_table()
#' }
#'
ocnms_create_link_table <- function(csv_path = "svg/svg_links_ocnms.csv"){
  tab_contents <- ocnms_get_sheet(sheets_tab = "modals")
  link_table <- tibble::tibble(tab_contents["svg"], tab_contents["icon"], tab_contents["link"], tab_contents["title"], tab_contents["not_modal"])
  readr::write_csv(link_table, csv_path)
}
