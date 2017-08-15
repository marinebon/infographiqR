#' plot timeseries given a path (or URL) to csv
#'
#' @param csv_tv csv path or URL with time and value
#' @param title title of plot
#' @param y_label label (eg units) for values on y axis
#' @param x_label label for date/time on x axis
#' @param v_label label for legend, defaults to y_label
#' @param filter filter expression to limit rows
#' @param col_t column name for time
#' @param col_y column name for y
#' @param skip rows to skip in csv header
#'
#' @return returns dygraph htmlwidget for populating modal window
#' @import tidyverse dygraphs xts lubridate
#' @export
#'
#' @examples
#' plot_timeseries(
#   csv_tv  = 'http://oceanview.pfeg.noaa.gov/erddap/tabledap/cciea_MM_pup_count.csv?time,mean_growth_rate',
#   title   = 'Female sea lion pup growth rate',
#   y_label = 'Mean growth rate')
plot_timeseries = function(
  csv_tv, 
  title,
  y_label,
  x_label = 'Year',
  v_label = y_label,
  filter  = NULL,
  col_t   = NULL,
  col_y   = NULL,
  skip    = 2){

  # debug  
  # csv_tv = 'http://oceanview.pfeg.noaa.gov/erddap/tabledap/cciea_MM_pup_count.csv?time,mean_growth_rate'
  # title  = 'Female sea lion pup growth rate'
  # y_label = 'Mean growth rate'
  # x_label = 'Year'
  # v_label = y_label
  # skip = 2
  #
  # plot_timeseries(
  #   csv_tv  = 'http://oceanview.pfeg.noaa.gov/erddap/tabledap/cciea_MM_pup_count.csv?time,mean_growth_rate',
  #   title   = 'Female sea lion pup growth rate',
  #   y_label = 'Mean growth rate')
  #
  # csv_tv  = "/Users/bbest/github/analysis/data/rvc_grp_years.csv"
  # title   = "Algal Farmers"
  # y_label = "Average count"
  # skip    = 0
  # filter  = "group == Algal farmer"
  # col_t   = "year"
  # col_y   = "q_mean"
  # 
  # x_label = 'Year'
  # v_label = y_label


  library(tidyverse)
  library(dygraphs) # devtools::install_github("rstudio/dygraphs")
  library(xts)
  library(lubridate)

  d = read_csv(csv_tv, skip=skip)

  if (!is.null(filter)){
    d = eval(parse(text=sprintf('filter(d, %s)', filter)))
  }
  
  stopifnot(is.null(col_t) == is.null(col_y))
  
  if(!is.null(col_t)){
    d = d[,c(col_t, col_y)]
  }
  
  #stopifnot(ncol(d) == 2)
  
  colnames(d) = c('t','v')

  if (all(nchar(as.character(d$t))==4)){
    d$t = as.Date(sprintf('%d-01-01', d$t))
  }

  m = d %>%
    summarize(
      mean    = mean(v),
      sd      = sd(v),
      se      = sd(v)/sqrt(length(v)),
      se_hi   = mean(v)+se,
      se_lo   = mean(v)-se,
      sd_hi   = mean(v)+sd,
      sd_lo   = mean(v)-sd,
      ci95_hi = mean(v)+2*se,
      ci95_lo = mean(v)-2*se)
  
  w = d %>%
    select(-t) %>%
    as.xts(., order.by=d$t) %>%
    dygraph(
      main=title) %>%
      #width=488, height=480) %>%
    dySeries('v', color='red', strokeWidth=2, label=v_label) %>%
    dyAxis('x', label=x_label, valueRange=c(as.Date(min(d$t)), today())) %>%
    dyAxis('y', label=y_label) %>%
    dyShading(from=max(d$t) - years(5), to=max(d$t), color='#CCEBD6') %>%
    dyLimit(m$sd_hi, color='green', label='+1sd', strokePattern='solid') %>%
    dyLimit(m$mean,  color='green', label='mean', strokePattern='dashed') %>%
    dyLimit(m$sd_lo, color='green', label='-1sd', strokePattern='solid')
    #dyRangeSelector()
  #w
  #htmlwidgets::saveWidget(w, file = "w.html", selfcontained = FALSE)
  
  return(w)
}