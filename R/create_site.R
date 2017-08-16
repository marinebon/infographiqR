#' Create site
#'
#' @param indicators_csv csv table containing pointers going from svg_id to csv_url with data for plot of indicator... 
#' @param site_title 
#' @param dir_root 
#' @param dir_svg 
#' @param svg_elements_csv 
#' @param dir_rmd 
#' @param dir_web 
#' @param svg_paths 
#' @param svg_names 
#' @param site_yml_brew 
#' @param index_md_brew 
#' @param readme_md_brew 
#' @param header 
#' @param footer 
#' @param styles_css 
#' @param index 
#'
#' @return nothing returned from the function if no error, except the created site is generated
#' @import tidyverse rmarkdown brew tools servr stringr
#' @export
#'
#' @examples
#' create_site()
create_site = function(
  # load_all()
  site_title       = 'Florida Keys Infographics', 
  dir_root         = '/Users/bbest/github/info-fk',
  dir_svg          = 'svg',
  svg_elements_csv = 'svg_elements.csv',
  indicators_csv   = 'plot_indicators.csv',
  dir_rmd          = 'rmd',
  dir_web          = 'docs',
  svg_paths        = list.files(dir_svg, '.*\\.svg$', full.names=T),
  svg_names        = tools::file_path_sans_ext(list.files(dir_svg, '.*\\.svg$')),
  site_yml_brew    = system.file('site_template/_site.yml.brew', package='infographiq'),
  index_md_brew    = system.file('site_template/index.md.brew', package='infographiq'),
  readme_md_brew   = system.file('site_template/README.md.brew', package='infographiq'),
  header           = system.file('site_template/_header.html', package='infographiq'),
  footer           = system.file('site_template/_footer.html', package='infographiq'),
  styles_css       = system.file('site_template/styles.css', package='infographiq'),
  index            = system.file('site_template/index.Rmd', package='infographiq')){
  
  library(tidyverse)
  library(brew)
  library(rmarkdown)
  library(tools)
  library(servr)
  library(stringr)
  
  # assume paths defined relative to dir_root
  dir_svg          = file.path(dir_root, dir_svg)
  dir_rmd          = file.path(dir_root, dir_rmd)
  dir_web          = file.path(dir_root, dir_web)
  dir_modals       = file.path(dir_rmd, 'modals')
  indicators_csv   = file.path(dir_root, indicators_csv)
  svg_elements_csv = file.path(dir_root, svg_elements_csv)
  
  # get package templates
  scene_brew      = system.file('site_template/scene.rmd.brew', package='infographiq')
  modal_head_brew = system.file('site_template/modal_head.rmd.brew', package='infographiq')
  modal_plot_brew = system.file('site_template/modal_plot.rmd.brew', package='infographiq')
  dir_libs        = system.file('site_template/libs', package='infographiq')
  
  # check paths
  for (arg in c('dir_svg','indicators_csv')){
    val = get(arg)
    if (!file.exists(indicators_csv)) 
      stop(sprintf('The %s does not exist: %s', arg, val))
  }
  if (!dir.exists(dir_rmd)) dir.create(dir_rmd)
  if (!dir.exists(dir_web)) dir.create(dir_web)
  file.copy(dir_libs, dir_rmd, recursive=T)
  file.copy(dir_svg, dir_rmd, recursive=T)
  file.copy(svg_elements_csv, file.path(dir_rmd, basename(svg_elements_csv)))
  writeLines('', file.path(dir_rmd, '.nojekyll'))
   d
  # check svg_*
  if (!length(svg_paths) == length(svg_names)) 
    stop('Length of svg_paths not matching length of svg_names.')
  
  for (arg in c('header', 'footer', 'styles_css')){
    f = get(arg)
    if (!is.null(f)){
      if (!file.exists(f)) stop(sprintf('The %s file does not exist: %s', arg, f))
      file.copy(f, file.path(dir_rmd, basename(f)))
    }
  }
  
  # brew _site.yml into dir_rmd
  svgs  = basename(svg_paths)
  rmds  = sprintf('%s.rmd', file_path_sans_ext(svgs))
  htmls = sprintf('%s.html', file_path_sans_ext(svgs))
  if (is.null(site_yml_brew)) stop('The argument site_yml_brew can not be null.')
  for (arg in c('site_yml_brew','index_md_brew', 'readme_md_brew')){ # arg='site_yml_brew'
    f_brew = get(arg)
    if (file_ext(f_brew) != 'brew') 
      stop(sprintf('Argument %s requires a .brew file extension: %s', arg, f_brew))
    f = file_path_sans_ext(f_brew)
    if (!is.null(f_brew)){
      if (!file.exists(f_brew)) stop(sprintf('The %s file does not exist: %s', arg, f))
      brew(f_brew, file.path(dir_rmd, basename(f)))
    }  
  }

  # filter indicators to element from parameter
  d = read_csv(indicators_csv) %>%
    filter(!is.na(csv_url)) # View(d)
  
  # generate scene pages
  for (i in seq_along(svgs)){ # i = 3
    svg = svgs[i]
    svg_name = svg_names[i]
    brew(scene_brew, file.path(dir_rmd, rmds[i]))
  }
  
  # generate modal pages
  dir.create(dir_modals, showWarnings = F)
  for (id in unique(d$svg_id)){ # id = unique(d$svg_id)[3]
    d_id = filter(d, svg_id == id)
    rmd = sprintf('%s/%s.Rmd', dir_modals, id)
    
    brew(modal_head_brew, rmd)
    
    f_rmd = file(rmd, 'a') # file connection in append mode
    for (i in 1:nrow(d_id)){ # i = 1
      attach(d_id[1,], name='d_id_i')
      
      brew(modal_plot_brew, f_rmd)
      
      flush(f_rmd)
      detach('d_id_i')
    }
    close(f_rmd)
    
    # TODO: DEBUG all reasons for failing rmarkdown gen including bad CSV & warn but continue on errors
    if (id %in% 'forage-fish')
      render(rmd)
  }
  
  # render top level pages and copy all in rmd to docs
  render_site(dir_rmd)
  
  # serve site
  servr::httd(dir_web) # servr::httd()
}