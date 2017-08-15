#' Create site
#'
#' @param dir 
#'
#' @return
#' @import rmarkdown
#' @export
#'
#' @examples
create_site = function(dir='./docs'){
  
  clear_site()
  
  # render top level pages
  render_site()
  
  # filter indicators to element from parameter
  d = read_csv('data/csv_indicators.csv') %>%
    filter(!is.na(csv_url)) # View(d)
  
  dir.create('docs/pages', showWarnings = F)
  
  for (x in unique(d$element)){ # x = unique(d$element)[2]
    rmd = sprintf('docs/pages/%s.Rmd', x) 
    write_lines(sprintf(
      '---
      output:
      html_document:
      self_contained: false
      lib_dir: "libs"
      fig_height: 2
      fig_width: 4
      params:
      element: "%s"
      ---
      
      ```{r, echo=FALSE, message=FALSE, warning=FALSE}
      knitr::opts_chunk$set(echo=F, message=F)
      source("../../functions.R")
      ```
      ', x), rmd)
    
    d_e = filter(d, element == x)
    
    for (i in 1:nrow(d_e)){ # i = 1
      
      write_lines(with(d_e, sprintf(
        '
        ```{r}
        plot_timeseries(
        csv_tv  = "%s",
        title   = "%s",
        y_label = "%s",
        skip    = %d,
        filter  = %s,
        col_t   = %s,
        col_y   = %s)
        ```
        ', 
        csv_url[i], 
        indicator[i], 
        y_label[i],
        ifelse(is.na(skip_lines[i]), 2, skip_lines[i]), 
        ifelse(is.na(filter[i]), 'NULL', sprintf('"%s"', str_replace_all(filter[i], '"', '\\\\"'))), 
        ifelse(is.na(col_t[i]), 'NULL', sprintf('"%s"', col_t[i])), 
        ifelse(is.na(col_y[i]), 'NULL', sprintf('"%s"', col_y[i])))), rmd, append=T)
      
    }
    rmarkdown::render(rmd)
  }
  
  # copy needed dirs to output docs
  for (dir in c('data','img','libs','svg')){
    file.copy(dir, 'docs', recursive=T)
  }
  
  # turn off jekyll for quicker rendering
  system('touch docs/.nojekyll')
  
  # serve site
  servr::httd('docs')
}