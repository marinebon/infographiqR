#' Clear all files in the site directory
#'
#' @param dir directory to wipe out, defaults to ./docs per Github Pages convention
#'
#' @return
#' @export
#'
#' @examples
clear_site = function(dir='./docs'){
  # clean up output docs folder, except docs/svg/
  #setdiff(list.files('docs'), c('libs','svg')) %>% file.path('docs', .) %>%
  #  unlink(recursive=T, force=T)
  unlink(dir, recursive=T, force=T)
}
