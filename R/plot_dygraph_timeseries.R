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
#' plot_dygraph_timeseries(
#   csv_tv  = 'http://oceanview.pfeg.noaa.gov/erddap/tabledap/cciea_MM_pup_count.csv?time,mean_growth_rate',
#   title   = 'Female sea lion pup growth rate',
#   y_label = 'Mean growth rate')
plot_dygraph_timeseries = function(
  csv_tv,
  title,
  y_label,
  x_label = 'Year',
  v_label = y_label,
  filter  = NULL,
  col_t   = NULL,
  col_y   = NULL,
  skip    = 0,
  use_kmb = T,
  group_by= NULL,
  std_err= NULL
){

  # debug
  # csv_tv = 'http://oceanview.pfeg.noaa.gov/erddap/tabledap/cciea_MM_pup_count.csv?time,mean_growth_rate'
  # title  = 'Female sea lion pup growth rate'
  # y_label = 'Mean growth rate'
  # x_label = 'Year'
  # v_label = y_label
  # skip = 2
  #
  # plot_dygraph_timeseries(
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
  library(futile.logger)
  flog.threshold(WARN)

  d = read_csv(csv_tv, skip=skip)

  if (!is.null(filter)){
    d = eval(parse(text=sprintf('filter(d, %s)', filter)))
  }

  stopifnot(is.null(col_t) == is.null(col_y))

  if (is.null(group_by)){  # single series w/ mean & +/- std dev
    flog.debug("single series")
    if(!is.null(col_t)){
      d_s = d[,c(col_t, col_y)] # d_subset
    }

    #stopifnot(ncol(d) == 2)

    colnames(d_s) = c('t','v')

    if (all(nchar(as.character(d_s$t))==4)){
      d_s$t = as.Date(sprintf('%d-01-01', d_s$t))
    }

    m = d_s %>%
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

    if (is.null(std_err)){
      y_arg = "v"
    } else {
      d_s = add_column(d_s, v_upper = (d[,col_y] + d[,std_err])[,col_y]) %>%
            add_column(     v_lower = (d[,col_y] - d[,std_err])[,col_y])
      y_arg = c("v_lower", "v", "v_upper")
    }

    # TODO: change format to more colorblind-friendly color scheme (#19)
    w = d_s %>%
      select(-t) %>%
      as.xts(., order.by=d_s$t) %>%
      dygraph(main=title) %>% #width=488, height=480)
      dySeries(y_arg, color='red', strokeWidth=2, label=v_label) %>%
      dyLimit(m$sd_hi, color='green', label='+1sd', strokePattern='solid') %>%
      dyLimit(m$mean,  color='green', label='mean', strokePattern='dashed') %>%
      dyLimit(m$sd_lo, color='green', label='-1sd', strokePattern='solid')

  } else {  # multiple series
    flog.debug("multi-series")
    if(!is.null(col_t)){
      d_s = d[,c(col_t, col_y, group_by)]
    }

    #stopifnot(ncol(d_s) == 3)

    colnames(d_s) = c('t','v', 'group_by')

    if (all(nchar(as.character(d_s$t))==4)){
      d_s$t = as.Date(sprintf('%d-01-01', d_s$t))
    }

    dd = spread(d_s, group_by, v, fill=0)
    o_by = dd$t #rep(d$t, nrow(dd))

    flog.trace("dd  is %sx%s", nrow(dd),   ncol(dd))
    flog.trace("oby is %sx%s", nrow(o_by), ncol(o_by))

    w = select(dd, -t) %>%
      as.xts( order.by=o_by) %>%
      dygraph(main=title) #width=488, height=480)
  }

  w = dyAxis(
    w, 'x', label=x_label, valueRange=c(as.Date(min(d_s$t)), today()),
    pixelsPerLabel=35,
    axisLabelFormatter="function(d) { return d.getFullYear() }"
  ) %>%
    dyAxis('y', label=y_label) #%>%
    # dyShading(from=max(d$t) - years(5), to=max(d$t), color='#CCEBD6')

  # This next piece is a goofy workaround to avoid label/axis-title overlap
  # https://github.com/marinebon/infographiq/issues/7
  # by limiting the size of the y-axis tickmark label. We do this
  # because I can't find the option to resize y-axis tickmark padding in
  # ?dyOptions or ?dyAxis.
  if (use_kmb){  # we if-else this b/c sigFigs overrides labelsKMB if set
    w = dyOptions(w, labelsKMB=T)
  } else {
    w = dyOptions(w, sigFigs=2)
  }

  #dyRangeSelector()
  #w
  #htmlwidgets::saveWidget(w, file = "w.html", selfcontained = FALSE)

  return(w)
}
