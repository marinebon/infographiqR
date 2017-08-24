#' checks if columns in given csv file m
#'

check_csv_columns = function(
  filepath,
  columns
){
  cols_elements = read_csv(filepath) %>% names()
  cols_missing = setdiff(columns, cols_elements)
  if (length(cols_missing) > 0)
    stop(sprintf('Missing these columns in elements_csv: %s', paste(cols_missing, collapse=', ')))
}
