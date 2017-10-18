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
  # print("plotting_function_call:")
  # print(sprintf("    %s", plotting_function_call))

  BASE_PATH = 'site_template/plotting_functions/'
  DEFAULT_BREW = paste(BASE_PATH, 'plot_dygraph_timeseries.rmd.brew', sep='')
  CELL_EVAL_BREW = paste(BASE_PATH, 'cell_eval.rmd.brew', sep='')

  # if value is not valid
  if (any(is.null(plotting_function_call)) || any(is.na(plotting_function_call))){
    print(sprintf("using default plotter '%s'", DEFAULT_BREW))
    # use the default plotter
    return(system.file(
      DEFAULT_BREW,
      package='infographiq'
    ))
  } else { # figure out what the user is asking for
    # built-in plotting function brew file names
    built_in_plotters = list.files(
      system.file('site_template/plotting_functions', package='infographiq')
    )

    # also support plotter base names (everything before the first '.')
    # ie: `plot_dygraph_timeseries` instead of `plot_dygraph_timeseries.rmd.brew`
    built_in_plotter_bases = sapply(
      strsplit(built_in_plotters, ".", fixed=TRUE),
      FUN=function(d){ paste(d[1]) }
    )

    # for debugging built-in options:
    # print(sprintf("brew-opt: %s || %s", built_in_plotters, built_in_plotter_bases))

    if (plotting_function_call %in% built_in_plotters){
      # checks for full plotter template file names
      return(system.file(
        paste(BASE_PATH, plotting_function_call, sep=''),
        package='infographiq'
      ))

    } else if (plotting_function_call %in% built_in_plotter_bases){
      # checks for plotter function base names
      # NOTE: this assumes that all brew templates end in ".rmd.brew"
      return(system.file(
        paste(BASE_PATH, plotting_function_call, ".rmd.brew", sep=''),
        package='infographiq'
      ))

    } else if( file.exists(plotting_function_call) && !dir.exists(plotting_function_call) ){
      # custom plotter in a brew template
      print(sprintf("using custom template: %s", plotting_function_call))
      return(plotting_function_call)

    } else {
      # shove cell contents into brew wrapper file and eval it
      print(sprintf(
        "\n\nWARN: Using eval on plotting_function_call directly for cell content:\n\n%s\n\n",
        plotting_function_call
      ))
      return(system.file(
        CELL_EVAL_BREW,
        package='infographiq'
      ))
    }
  }
}
