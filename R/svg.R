#' Make SVG interactive with modal (popup) or nonmodal (normal) links based on data.frame linked by id
#'
#' @param df data.frame containing fields \code{id}, \code{title}, \code{link_nonmodal}, \code{link_modal}
#' @param svg path to svg relative to generated html
#' @param color_default default color, defaults to black
#' @param color_hover default color on hover, defaults to yellow
#' @param width width of output svg (TODO)
#' @param height height of output svg (TODO)
#'
#' @return linked interactive infographic using svg illustration with links included
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
  stopifnot(nrow(df) > 0)
  stopifnot(all(c("id", "title", "link_nonmodal", "link_modal") %in% names(df)))
  # TODO: c("svg", "modal_before", "modal_after", "status_text", "status_color")
  if (any(as.numeric(!is.na(df$link_nonmodal)) + as.numeric(!is.na(df$link_modal)) > 1)){
    stop("The link_nonmodal and link_modal in df are mutually exclusive, so cannot define both; one should be empty, ie NA.")
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
  # if only link_nonmodal and no link_modal, skip modal
  if (sum(as.numeric(!is.na(df$link_modal))) > 0){
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