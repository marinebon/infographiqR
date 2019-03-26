#' Make SVG interactive with links and/or modals based on data.frame linked by id
#'
#' @param df data.frame containing fields \code{id}, \code{title}, \code{link}, \code{modal}
#' @param svg path to svg relative to generated html
#' @param color_default default color, defaults to black
#' @param color_hover default color on hover, defaults to yellow
#' @param width width of output svg (TODO)
#' @param height height of output svg (TODO)
#'
#' @return linked interactive infographic using svg illustration with links for \code{link}, which using modal window if applicable
#' @export
#' @import r2d3 htmltools bsplus
#'
#' @examples
info_svg <- function(
  df, svg, 
  color_default="black", color_hover="yellow", 
  width = NULL, height = NULL, modal_id="modal"){
  
  library(r2d3)
  library(htmltools)
  library(bsplus)
  
  # checks
  stopifnot(file.exists(svg))
  stopifnot(is.data.frame(df))
  stopifnot(all(c("id", "title", "link", "modal") %in% names(df)))
  # TODO: c("svg", "modal_before", "modal_after", "status_text", "status_color")
  if (any(as.numeric(!is.na(df$link)) + as.numeric(!is.na(df$modal)) > 1)){
    stop("Link and modal in df are mutually exclusive, so cannot define both; one should be empty, ie NA.")
  }

  # library(tidyverse)
  # library(r2d3)
  # library(htmltools)
  # library(bsplus)
  # library(here)
  # devtools::load_all("~/github/infographiq")
  # here <- here::here
  # 
  # df <- read_csv("~/github/cinms/docs/svg/svg_elements.csv") %>% 
  #   filter(svg == "overview.svg")
  
  tags <- list()
  # if only links and no modals, skip modal
  if (sum(as.numeric(!is.na(df$modal))) > 0){
    # setup generic modal, with values to be replaced with infographiq.js
    
    tags <- bsplus::bs_modal(
      id = modal_id, title = "title",
      body = htmltools::HTML(
        '<iframe data-src="modal.html" height="100%" width="100%" frameborder="0"></iframe>'), 
      size="large")
  }
  
  # operate on svg using data in df
  tag_svg <- r2d3::r2d3(
    script = system.file("infographiq.js", package = "infographiq"),
    data = df, 
    options = list(
      svg           = svg,
      color_default = color_default,
      color_hover   = color_hover,
      modal_id      = modal_id,
      width         = width,
      height        = height),
    d3_version = "5")
  tags <- htmltools::tagList(tags, tag_svg)
  
  deps = htmltools::htmlDependency(
    'infographiq-css', '0.1', 
    src = system.file(package = "infographiq"),
    stylesheet = 'infographiq.css')
  tags <- htmltools::attachDependencies(tags, deps)
  
  tags
}