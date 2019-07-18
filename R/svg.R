#' Make SVG interactive with modal (popup) or nonmodal (normal) links based on data.frame linked by id
#'
#' @param df data.frame containing fields \code{id}, \code{title}, \code{link_nonmodal}, \code{link_modal}
#' @param svg url to svg relative to generated html
#' @param color_default default color, defaults to black
#' @param color_hover default color on hover, defaults to yellow
#' @param width width of output svg (TODO)
#' @param height height of output svg (TODO)
#' @param modal_id used by JavaScript for turning on/off modal window; defaults to "modal"
#' @param debug add debug messages to JavaScript console; defaults to FALSE
#'
#' @return linked interactive infographic using svg illustration with links included
#' @export
#' @import r2d3 htmltools bsplus
#'
#' @examples
info_svg <- function(
  df, svg, 
  width = NULL, height = NULL,
  color_default = "black", color_hover = "yellow", modal_id = "modal", debug = FALSE){
  
  # df = readr::read_csv("~/github/fk-iea/content/svg_links.csv")
  # svg = "file:///Users/bbest/github/fk-iea/content/svg/fl-keys.svg"
  # width = NULL; height = NULL
  # color_default="black"; color_hover="yellow"; modal_id="modal"; debug = F
  
  library(r2d3)
  library(htmltools)
  library(bsplus)
  library(rmarkdown)
  
  # checks
  #stopifnot(file.exists(svg))
  stopifnot(nrow(df) > 0)
  stopifnot(all(c("id", "title", "link_nonmodal", "link_modal") %in% names(df)))
  # TODO: c("svg", "modal_before", "modal_after", "status_text", "status_color")
  if (any(as.numeric(!is.na(df$link_nonmodal)) + as.numeric(!is.na(df$link_modal)) > 1)){
    stop("The link_nonmodal and link_modal in df are mutually exclusive, so cannot define both; one should be empty, ie NA.")
  }

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
  w <- r2d3::r2d3(
    script = system.file("infographiq.js", package = "infographiq"),
    d3_version = "5",
    dependencies = list(
      rmarkdown::html_dependency_jquery(),
      rmarkdown::html_dependency_bootstrap("default"),
      htmltools::htmlDependency(
        'infographiq-css', '0.1', 
        src = system.file(package = "infographiq"),
        stylesheet = 'infographiq.css')),
    data = df, 
    options = list(
      svg           = svg,
      color_default = color_default,
      color_hover   = color_hover,
      modal_id      = modal_id,
      width         = width,
      height        = height,
      debug         = debug))
  
  # add modal id
  w <- htmlwidgets::prependContent(w, tags)
  
  w
}