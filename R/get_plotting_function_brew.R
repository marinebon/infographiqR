#' takes a string value (assumed to be the value of the plotting_function column
#' from plot_indicators.csv) and returns the brew template we think the user
#' wants.
#'
#' @param plotting_function_call str from plot_indicators.csv$plotting_function
#         that gives us a hint at what brew to return.
#'
#' @return returns brew file object that can be passed to brew()
#' @import ...
#' @export ...
#'
#' @examples
#'  plot_brew = get_plotting_function_brew(
#     plot_indicators_data$plotting_function_call[i]
#   )

get_plotting_function_brew = function(
  plotting_function_call
){
  DEFAULT_BREW = 'site_template/plotting_functions/plot_dygraph_timeseries.rmd.brew'

  # if value is valid
  if (any(is.null(plotting_function_call)) || any(is.na(plotting_function_call))){
    # TODO: use the value of plotting_function_call like:
    # if (plotting_function_call == plot_dygraph_timeseries){
    modal_plot_brew = system.file(
      'site_template/plotting_functions/plot_dygraph_timeseries.rmd.brew',
      package='infographiq'
    )

  } else {
    # use the default plotter
    modal_plot_brew = system.file(
      DEFAULT_BREW,
      package='infographiq'
    )
  }

  return(modal_plot_brew)
}
