#' Create infographics web site
#'
#' @param indicators_csv csv table containing pointers going from svg_id to csv_url with data for plot of indicator... 
#' @param site_title 
#' @param path_root 
#' @param dir_svg 
#' @param elements_csv 
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
#' @return nothing returned from the function if no error, except the created site is generated. http://rmarkdown.rstudio.com/rmarkdown_websites.html
#' @import tidyverse rmarkdown brew tools servr stringr
#' @export
#'
#' @examples
#' library(infographiq)
#' create_info_site()
create_info_site = function(
  # load_all()
  site_title       = 'Florida Keys Infographics', 
  path_root        =  '/Users/bbest/github/info-fk',
  dir_svg          = 'svg',
  elements_csv     = 'svg_elements.csv',
  indicators_csv   = 'plot_indicators.csv',
  dir_rmd          = 'rmd',
  dir_web          = 'docs',
  svg_paths        = list.files(file.path(path_root, dir_svg), '.*\\.svg$', full.names=T),
  svg_names        = tools::file_path_sans_ext(basename(svg_paths)),
  site_yml_brew    = system.file('site_template/_site.yml.brew', package='infographiq'),
  index_md_brew    = system.file('site_template/index.md.brew', package='infographiq'),
  readme_md_brew   = system.file('site_template/README.md.brew', package='infographiq'),
  header           = system.file('site_template/_header.html', package='infographiq'),
  footer           = system.file('site_template/_footer.html', package='infographiq'),
  styles_css       = system.file('site_template/styles.css', package='infographiq'),
  index            = system.file('site_template/index.Rmd', package='infographiq'),
  render_modals    = T){
  
  #devtools::load_all(); create_info_site()
  #browser()
  
  library(tidyverse)
  library(brew)
  library(rmarkdown)
  library(tools)
  library(servr)
  library(stringr)
  
  # assume paths defined relative to path_root
  path_svg         = file.path(path_root, dir_svg)
  path_rmd         = file.path(path_root, dir_rmd)
  path_web         = file.path(path_root, dir_web)
  path_modals      = file.path(path_rmd, 'modals')
  path_indicators  = file.path(path_root, indicators_csv)
  path_elements    = file.path(path_root, elements_csv)
  
  # get package templates
  scene_brew      = system.file('site_template/scene.rmd.brew', package='infographiq')
  modal_head_brew = system.file('site_template/modal_head.rmd.brew', package='infographiq')
  modal_plot_brew = system.file('site_template/modal_plot.rmd.brew', package='infographiq')
  path_libs        = system.file('site_template/libs', package='infographiq')
  
  # check paths
  for (arg in c('path_svg','path_indicators','path_elements')){
    val = get(arg)
    if (!file.exists(val)) 
      stop(sprintf('The %s does not exist: %s', arg, val))
  }
  if (!dir.exists(path_rmd)) dir.create(path_rmd)
  if (!dir.exists(path_web)) dir.create(path_web)
  file.copy(path_libs, path_rmd, recursive=T)
  file.copy(path_svg, path_rmd, recursive=T)
  file.copy(path_elements, file.path(path_rmd, elements_csv))
  writeLines('', file.path(path_rmd, '.nojekyll'))
  
  # check svg_*
  if (!length(svg_paths) == length(svg_names)) 
    stop('Length of svg_paths not matching length of svg_names.')
  
  for (arg in c('header', 'footer', 'styles_css')){
    f = get(arg)
    if (!is.null(f)){
      if (!file.exists(f)) stop(sprintf('The %s file does not exist: %s', arg, f))
      file.copy(f, file.path(path_rmd, basename(f)))
    }
  }
  
  # brew _site.yml into path_rmd
  svgs  = basename(svg_paths)
  rmds  = sprintf( '%s.rmd', file_path_sans_ext(svgs))
  htmls = sprintf('%s.html', file_path_sans_ext(svgs))
  if (is.null(site_yml_brew)) stop('The argument site_yml_brew can not be null.')
  for (arg in c('site_yml_brew','index_md_brew', 'readme_md_brew')){ # arg='site_yml_brew'
    f_brew = get(arg)
    if (!is.null(f_brew)){
      f = file_path_sans_ext(f_brew)
      if (file_ext(f_brew) != 'brew') 
        stop(sprintf('Argument %s requires a .brew file extension: %s', arg, f_brew))
      if (!file.exists(f_brew)) 
        stop(sprintf('The %s file does not exist: %s', arg, f))
      brew(f_brew, file.path(path_rmd, basename(f)))
    }  
  }

  # generate scene pages
  #browser()
  for (i in seq_along(svgs)){ # i = 3
    svg = svgs[i]
    svg_name = svg_names[i]
    brew(scene_brew, file.path(path_rmd, rmds[i]))
  }
  
  # generate modal pages
  dir.create(path_modals, showWarnings = F)
  d = read_csv(path_indicators) %>%
    filter(!is.na(csv_url)) # View(d)
  for (id in unique(d$svg_id)){ # id = unique(d$svg_id)[3]
    d_id = filter(d, svg_id == id)
    rmd = sprintf('%s/%s.Rmd', path_modals, id)
    
    brew(modal_head_brew, rmd)
    
    f_rmd = file(rmd, 'a') # file connection in append mode
    for (i in 1:nrow(d_id)){ # i = 1
      attach(d_id[1,], name='d_id_i')
      
      brew(modal_plot_brew, f_rmd)
      
      flush(f_rmd)
      detach('d_id_i')
    }
    close(f_rmd)
    
    if (render_modals)
      render(rmd, output_file = sprintf('%s.html', file_path_sans_ext(rmd)))
  }
  
  # render top level pages and copy all in rmd to docs
  # NOTE: wipes out dir_web first
  render_site(path_rmd)
  
  # cd svg; gzip -S .svgz *.svg
  
  # modals: delete rmd from docs, keep html from rmd so use cached copy when render_modals = F
  file.remove(list.files(file.path(path_web, 'modals'),  '.*\\.Rmd$', full.names=T))
  
  # serve site
  servr::httd(path_web) # servr::httd('/Users/bbest/github/info-fk/docs')
}