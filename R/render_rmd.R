#' Generate the html for R markdown files
#'
#' Rmd files with interactive figures present a special problem in terms of rendering
#' them into html. The problem is that, if one uses the markdown library to
#' create the html, the figures will turn out fine but the glossary tooltip functionality
#' will be missing. This tooltip functionality is created by the function rmd2html,
#' described in this package. If one uses rmd2html to render a rmd file containing
#' interactive figures, the tooltips will turn out fine but the figures won't show
#' up. The problem with rmd2html is that the appropriate javascript libraries are
#' not loaded into the resulting <head> section of the final html. This function
#' solves the problem (thereby producing html with both working figures and tooltips)
#' by rendering the rmd using both the markdown and rmd2html approaches and then rewriting
#' the <head> section of the rmd2html version with the markdown version.
#'
#' @param target_rmd The R markdown file to be rendered
#' @param nms The NMS sanctuary, with only "cinms" currently doing anything.
#' @return The function outputs a html file that is the rendered version of the input rmd file.
#' @export
#' @examples \dontrun{
#' generate_html_4_rmd(here::here("modals/tar.Rmd"))
#' }
#'
generate_html_4_rmd <- function (target_rmd, nms = "cinms"){
  
  # the following mini-function where_is_head has two simple purposes. When fed in a html file, which has already been brought in
  # to R via readLines, the function will tell you the line number of the html file that contains "</html>" and
  # the total number of lines in the file
  where_is_head <-function(input_lines){
    i<-1
    while (!(input_lines[i]=="</head>")){
      i <-i + 1
    }
    output_list <- list("total_lines" = length(input_lines), "head_line" = i)
    return(output_list)
  }
  
  # Let's figure out where we are. In my local environment, I am in the directory for
  # the sanctuary. In a docker container though, I won't be. So the following section of
  # code attempts to put us in the right directory if we aren't there already.
  location <- here::here()
  start_point <- nchar(location) - nchar(nms) +1
  if (!(substr(location, start_point, nchar(location)) == nms)){
    location <- paste(location, nms, sep = "/")
  }
  modal_dir<- paste0(location,"/modals/")
  
  # for a given rmd file, let's generate the html for it in two ways. Way 1 is via
  # rmd2html which gives us the glossary tooltip working right (but where the interactive
  # figures don't work). Way 2 is via render which gives us the interactive figures working
  # right (but where the glossary tooltip doesn't work)
  rmd2html(target_rmd)
  rmarkdown::render(target_rmd, output_file = paste(modal_dir, "temp_file.html", sep ="/"))
  
  # We want both the interactive figures and the glossary tooltip working in the html. The way to do
  # that is to grab everything in the <head> section of the html produced by render and then
  # to replace the <head> section of the html produced by rmd2html with that. The first step
  # here is to read in the two html files
  target_html <- gsub("Rmd", "html", target_rmd, ignore.case = TRUE)
  target_lines  <- readLines(target_html)
  replacement_path <- paste0(modal_dir,"temp_file.html")
  replacement_lines <- readLines(replacement_path)
  
  # Next, let's figure out where the <head> section ends in each html file
  target_location <- where_is_head(target_lines)
  replacement_location <-where_is_head(replacement_lines)
  
  # Now, let's replace the <head> section and save the new version of the html
  output_file = c(replacement_lines[1:replacement_location$head_line],target_lines[(target_location$head_line+1):target_location$total_lines])
  write(output_file, file = target_html)
  
  # let's delete the temp html file that we created
  file.remove(paste(modal_dir, "temp_file.html", sep ="/"))
}

#' Generate hyperlinked gray bar above figure
#'
#' The purpose of this function is to generate the hyperlinks for the monitoring program and data
#' associated with a figure and then to insert them into a gray bar above the figure in the modal window.
#'
#' @param figure_id The name of a row in the following google sheet cinms_content::info_figure_links
#' @return The output is a set of html tags to be inserted into a html file.
#' @export
#' @examples \dontrun{
#' get_figure_info("Figure App.E.11.8.")
#' }
#'
get_figure_info <- function (figure_id){
  info_csv = "https://docs.google.com/spreadsheets/d/1yEuI7BT9fJEcGAFNPM0mCq16nFsbn0b-bNirYPU5W8c/gviz/tq?tqx=out:csv&sheet=info_figure_links"
  
  d <- readr::read_csv(info_csv)  %>%
    dplyr::filter(md_caption == figure_id)
  
  if (nrow(d) == 0){
    warning(paste("Need link in cinms_content:info_figure_links Google Sheet for", figure_id))
    return("")
  }
  
  html  <- NULL
  no_ws <- c("before","after","outside","after-begin","before-end")
  
  icons <- tibble::tribble(
    ~description_bkup   ,    ~css,            ~icon,         ~fld_url, ~fld_description,
    "Monitoring Program",  "left", "clipboard-list", "url_monitoring", "title_monitoring",
    "Data"              , "right", "database"      ,       "url_data", "title_data")
  
  for (i in 1:nrow(icons)){  # i=1
    
    h           <- icons[i,]
    url         <- d[h$fld_url]
    description <- d[h$fld_description]
    
    if(!is.na(url) & substr(url,0,4) == "http"){
      if (is.na(description)){
        description <- h$description_bkup
      } else {
        description <- substr(stringr::str_trim(description), 0, 45)
      }
      
      html <- shiny::tagList(
        html,
        htmltools::div(
          .noWS = no_ws,
          style = glue::glue("text-align:{h$css}; display:table-cell;"),
          htmltools::a(
            .noWS = no_ws,
            href = url, target = '_blank',
            shiny::icon(h$icon), description)))
    }
  }
  
  if (is.null(html))
    return("")
  
  shiny::tagList(
    htmltools::div(
      .noWS = no_ws,
      style = "background:LightGrey; width:100%; display:table; font-size:120%; padding: 10px 10px 10px 10px; margin-bottom: 10px;",
      htmltools::div(
        .noWS = no_ws,
        style = "display:table-row",
        html)))
}

#' Generate introductory info for the html of a modal window
#'
#' This function generates the html tags for the top portion of a rmd modal window,
#' containing the introductory information about that window. This function only
#' will work within a rmd file to be knitted.
#'
#' @param rmd  The name of an input file passed to knit().
#' @param info_modal_links_csv A hyperlink to the google sheet, in csv format, that contains the modal links info.
#' @return The function returns a string that is a set of html tags to be inserted into a html file.
#' @export
#' @examples \dontrun{
#' get_modal_info(info_modal_links_csv = "https://docs.google.com/spreadsheets/d/1yEuI7BT9fJEcGAFNPM0mCq16nFsbn0b-bNirYPU5W8c/gviz/tq?tqx=out:csv&sheet=info_modal_links")
#' }
#'
get_modal_info <- function(rmd = knitr::current_input(), info_modal_links_csv){
  
  modal_id <- basename(fs::path_ext_remove(rmd))
  row <- readr::read_csv(info_modal_links_csv) %>%
    dplyr::filter(modal == modal_id)
  
  if (nrow(row) == 0) stop("Need link in cinms_content:info_modal_links Google Sheet!")
  
  icons_html = NULL
  if (!is.na(row$url_info)){
    icons_html =
      htmltools::a(shiny::icon("info-circle"), href=row$url_info, target='_blank')
  }
  if (!is.na(row$url_photo)){
    icons_html = htmltools::tagList(
      icons_html,
      htmltools::a(shiny::icon("camera"), href=row$url_photo, target='_blank'))
  }
  
  htmltools::div(
    htmltools::div(htmltools::tagList(icons_html), style = "margin-top: 10px;margin-bottom: 10px; margin-right: 10px; flex: 1;"), htmltools::div(
      ifelse(!is.na(row$tagline), row$tagline, ""), style = "margin: 10px; font-style: italic; flex: 20; "), style="display: flex"
    
  )
}

#' Insert html tags for glossary tooltips into md files
#'
#' The purpose of this function is to insert the html tags required for glossary
#' tooltip functionality into a given markdown file. The function glossarize_md
#' is used by the function rmd2html described in this package.
#'
#' @param md The markdown file where the tags are to be inserted.
#' @param md_out The markdown output file.
#' @return The output of this function is html tags inserted into a markdown file.
glossarize_md <- function(md, md_out = md){
  
  # read the markdown file
  tx  <- readLines(md)
  
  # only go forward with the glossarizing if the file contains more than "data to be added soon"
  if (length(tx) > 12) {
    
    # load in the glossary that will be used to create the tooltips.  Reverse alphabetize the glossary, which will come in handy later
    glossary_csv = "https://docs.google.com/spreadsheets/d/1yEuI7BT9fJEcGAFNPM0mCq16nFsbn0b-bNirYPU5W8c/gviz/tq?tqx=out:csv&sheet=glossary"
    glossary <- readr::read_csv(glossary_csv)
    glossary <- glossary[order(glossary$term, decreasing = TRUE),]
    
    # initialize the string variable that will hold the javascript tooltip
    script_tooltip = ""
    
    # go through each row of the glossary
    for (q in 1:nrow(glossary)) {
      
      # set a variable to zero that is used to keep track of whether a particular glossary word is in the modal window
      flag = 0
      
      # load in a specific glossary term
      search_term = glossary$term[q]
      
      # the css to be wrapped around any glossary word
      span_definition = paste0('<span aria-describedby="tooltip', q, '" tabindex="0" style="border-bottom: 1px dashed #000000; font-size:100%" id="tooltip', q, '">')
      
      # let's look to see if the glossary term is a subset of a longer glossary term (that is: "aragonite" and "aragonite saturation")
      # if it is a subset, we want to identify the longer term (so that we don't put the tooltip for the
      # shorter term with the longer term). Here is why the prior alphabetizing of the glossary matters
      glossary_match = glossary$term[startsWith (glossary$term, search_term)]
      
      if (length(glossary_match)>1){
        longer_term = glossary_match[1]
      }
      
      # let's go through every line of the markdown file looking for glossary words. We are skipping the first several
      # lines in order to avoid putting any tooltips in the modal window description
      for (i in 12:length(tx)) {
        
        # We want to avoid putting in tooltips in several situations that would cause the window to break.
        # 1. No tooltips on tabs (that is what the searching for "#" takes care of)
        # 2. No tooltips in the gray bar above the image (that is what the searching for the "</i>" and "</div> tags
        # take care of)
        # 3. No tooltips on lines where there is a link for a data download
        # 4. No tooltips on lines that create interactive graphs (no line starting with "<script")
        if (substr(tx[i],1,1) != "#" && stringr::str_sub(tx[i],-4) != "</i>" && stringr::str_sub(tx[i],-5) != "</div>" && substr(tx[i], 1, 24) != "Download timeseries data" && substr(tx[i], 1, 7) != "<script"){
          # We also want to avoid inserting tooltips into the path of the image file, which is what the following
          # image_start is looking for. If a line does contain an image path, we want to separate that from the rest of
          # the line, do a glossary word replace on the image-less line, and then - later in this code - paste the image back on to the line
          image_start = regexpr(pattern = "/img/cinms_cr", text = tx[i])[1] - 4
          
          if (image_start > 1) {
            
            line_content = substr(tx[i], 1, image_start)
            image_link = stringr::str_sub(tx[i], -(nchar(tx[i])-image_start))
          }
          else {
            line_content = tx[i]
          }
          
          # here is where we keep track of whether a glossary word shows up in the modal window - this will be used later
          if (grepl(pattern = search_term, x = line_content, ignore.case = TRUE) ==TRUE){
            flag = 1
          }
          
          # If the text contains a glossary term that is a shorter subset of another glossary term, we first
          # split the text by the longer glossary term and separately save the longer glossary terms (to preserve
          # the pattern of capitalization). We then run the split text through the tooltip function to add the required
          # span tags around the glossary terms and then paste the split text back together
          if (length(glossary_match)>1){
            split_text_longer <- stringr::str_split(line_content, stringr::regex(longer_term, ignore_case = TRUE))[[1]]
            save_glossary_terms_longer <- c(stringr::str_extract_all(line_content, stringr::regex(longer_term, ignore_case = TRUE))[[1]],"")
            
            for (s in 1:length(split_text_longer)){
              split_text_longer[s] <- insert_tooltip(split_text_longer[s], search_term, span_definition)
            }
            line_content<- paste0(split_text_longer, save_glossary_terms_longer, collapse="")
          }
          
          else {
            # In the case that the glossary term is not a shorter subset, life is much easier. We just run the line of content
            # through the insert tooltip function
            line_content <- insert_tooltip(line_content, search_term, span_definition)
          }
          
          # if we separated the image path, let's paste it back on
          if (image_start > 1) {
            tx[i] = paste0(line_content, image_link)
          }
          else {
            tx[i] = line_content
          }
        }
      }
      
      #if a glossary word was found in a modal window, let's add the javascript for that tooltip in
      if (flag == 1){
        script_tooltip = paste0(script_tooltip, '<script>tippy ("#tooltip', q, '",{content: "', glossary$definition[q], '"});</script>\r\n')
      }
    }
    
    # let's replace the markdown file with the modified version of the markdown file that contains all of the tooltip stuff
    # (if any)
    writeLines(tx, con=md_out)
    
    # if any glossary words are found, let's add in the javascript needed to make this all go
    if (script_tooltip != ""){
      load_script=' <script src="https://unpkg.com/@popperjs/core@2"></script><script src="https://unpkg.com/tippy.js@6"></script>\r\n'
      write(   load_script, file=md_out, append=TRUE)
      write(script_tooltip, file=md_out, append=TRUE)
    }
  }
}

#' Insert tooltips into text.
#'
#' The purpose of the following function is, for a provided section of text, to
#' insert the required tooltip css around a provided glossary term. The function
#' preserves the pattern of capitalization of the glossary term that already exists.
#' This function is used by the function glossarize_md also described in this
#' package.
#'
#' @param text The section of text where tooltips are to be added.
#' @param glossary_term The glossary term to be looked for.
#' @param span_css The css tags to add before the glossary term.
#' @return The function outputs a string containing the text section with html tags inserted.
#
insert_tooltip<- function(text, glossary_term, span_css){
  
  # We start by splitting the text by the glossary term and then separately saving the glossary terms. This is done
  # so that we can preserve the pattern of capitalization of the glossary term
  split_text <- stringr::str_split(text, stringr::regex(glossary_term, ignore_case = TRUE))[[1]]
  save_glossary_terms <- c(stringr::str_extract_all(text, stringr::regex(glossary_term, ignore_case = TRUE))[[1]],"")
  
  # Let's go through every section of the split text and add the required css tags
  for (q in 1:length(split_text)){
    if (q>1){
      split_text[q] = paste0("</span>", split_text[q])
    }
    
    if (q<length(split_text)){
      split_text[q] = paste0(split_text[q], span_css)
    }
  }
  
  # put the split text and the glossary terms back together again and then return that as the output
  return (paste0(split_text, save_glossary_terms, collapse=""))
}

#' Generate the caption for a figure
#'
#' This function generates either a short or expanded caption for a given figure.
#'
#' @param title The name of a figure.
#' @param md The md file containing the list of captions.
#' @param get_details A Boolean variable indicating whether a short or expanded caption is required.
#' @param fig_in_report A Boolean variable indicating whether the figure described in the caption is present in the condition report.
#' @return A string containing the caption, with html tags inserted.
#' @export
#' @examples \dontrun{
#' md_caption("Figure Ux.Ocean.SST.ERD.map.", get_details = T)
#' }
#'
md_caption <- function(title, md = here::here("modals/_captions.md"), get_details = F, fig_in_report = T){
  
  stopifnot(file.exists(md))
  
  tbl <- tibble::tibble(
    # read lines of markdown in _captions.md
    ln = readLines(md) %>% stringr::str_trim()) %>%
    # detect header with title, set rest to NA
    dplyr::mutate(
      is_hdr = stringr::str_detect(
        ln,
        glue::glue('^## {stringr::str_replace_all(title, stringr::fixed("."), "\\\\.")}'))
      %>% dplyr::na_if(FALSE)) %>%
    # fill down so capturing all starting with title header
    tidyr::fill(is_hdr) %>%
    # filter for title header down, removing previous lines
    dplyr::filter(is_hdr) %>%
    # remove title header
    dplyr::slice(-1) %>%
    # detect subsequent headers
    dplyr::mutate(
      is_hdr = stringr::str_detect(ln, "^## ") %>% dplyr::na_if(F)) %>%
    # fill down
    tidyr::fill(is_hdr) %>%
    dplyr::mutate(
      is_hdr = tidyr::replace_na(is_hdr, FALSE)) %>%
    # filter for not header down, removing subsequent lines outside caption
    dplyr::filter(!is_hdr) %>%
    # replace links in markdown with html to open in new tab
    dplyr::mutate(
      ln = stringr::str_replace_all(ln, "\\[(.*?)\\]\\((.*?)\\)", "<a href='\\2' target='_blank'>\\1</a>")) %>%
    # details
    dplyr::mutate(
      is_details = stringr::str_detect(ln, "^### Details") %>% dplyr::na_if(F)) %>%
    # fill down
    tidyr::fill(is_details)
  
  simple_md <- tbl %>%
    dplyr::filter(is.na(is_details)) %>%
    dplyr::filter(ln != "") %>%
    dplyr::pull(ln) %>%
    paste0(collapse = "\n") %>%
    stringr::str_trim()
  
  # Remove spaces around figure title.
  title <- stringr::str_trim(title)
  
  # If the last character of the figure title is a period, delete it. This will
  # improve how the title looks when embedded into the text.
  if (substring(title, nchar(title))=="."){
    title<- substring(title,0,nchar(title)-1)
  }
  
  # If figure is in condition report, append figure title (like App.F.13.2) to the
  # end of expanded figure caption and add link to condition report
  
  if (fig_in_report == T) {
    expanded_caption = paste('<details>\n  <summary>Click for Details</summary>\n\\1 For more information, consult', title,
                             'in the [CINMS 2016 Condition Report](https://nmssanctuaries.blob.core.windows.net/sanctuaries-prod/media/docs/2016-condition-report-channel-islands-nms.pdf){target="_blank"}.</details>')
  } else {
    expanded_caption = '<details>\n  <summary>Click for Details</summary>\n\\1</details>'
  }
  details_md <- tbl %>%
    dplyr::filter(is_details) %>%
    dplyr::filter(ln != "") %>%
    dplyr::pull(ln) %>%
    paste0(collapse = "\n") %>%
    stringr::str_replace("### Details\n(.*)", expanded_caption) %>%
    stringr::str_trim()
  
  if (get_details == T){
    return(details_md)
  } else {
    return(simple_md)
  }
}

#' Render all rmd files in the modals folder that have been changed
#'
#' @param nms The NMS sanctuary with only "cinms" currently doing anything.
#' @param interactive_only A Boolean variable indicating whether only rmd files containing interactive figures should be rendered. NOTE: If this is set to "TRUE", the rmd files containing interactive figures with MARINe data will be omitted. These latter figures can only be rendered in a local environment as they require connection to a shared Google Drive that is accessed via Google Drive File Stream.
#' @param render_all A Boolean variable indicating whether all rmd files should be rendered, whether or not there have been changes to them.
#' @export
#' @return The function outputs a html file for every rmd file in the modals folder.
#' @examples \dontrun{
#' render_all_rmd(interactive_only = T)
#' }
#'
render_all_rmd <- function (nms = "cinms", interactive_only = F, render_all = F){
  
  # Let's figure out where we are. In my local environment, I am in the directory for
  # the sanctuary. In a docker container though, I won't be. So the following section of
  # code attempts to put us in the right directory if we aren't there already.
  location <- here::here()
  start_point <- nchar(location) - nchar(nms) +1
  if (!(substr(location, start_point, nchar(location)) == nms)){
    location <- paste(location, nms, sep = "/")
  }
  modal_dir<- paste0(location,"/modals/")
  
  # let's get a list of all rmd files in the directory
  modal_list<-list.files(path = modal_dir, pattern = ".Rmd", ignore.case = TRUE)
  
  
  # Now, let's generate a list of rmd files that need to be skipped.
  if (nms == "cinms"){
    modal_list <- modal_list[!modal_list %in% "_key-climate-ocean.Rmd"]
    interactive_rmd <- c("deep-seafloor_key-climate-ocean.Rmd",
                         "forage-assemblage.Rmd",
                         "forage-fish.Rmd",
                         "forage-inverts.Rmd",
                         "kelp-forest_key-climate-ocean.Rmd",
                         "key-climate-ocean.Rmd",
                         "pelagic_key-climate-ocean.Rmd",
                         "rocky-shore_key-climate-ocean.Rmd",
                         "sandy-beach_key-climate-ocean.Rmd",
                         "sandy-seafloor_key-climate-ocean.Rmd")
  }
  
  if (interactive_only==T) {
    modal_list <-interactive_rmd
  }
  
  modal_list<-paste0(modal_dir,modal_list)
  
  # The following section of code checks to see if there has been any change to
  # the google spreadsheet cinms_content. If there has, we'll want to render all of the modal
  # windows to account for changes to cinms_content
  
  # Let's set a flag for whether the spreadsheet has changed
  cinms_content_changed = FALSE
  
  if (interactive_only==F) { # We only want to go through this process if we are going through every rmd file
    # The sheets of the google spreadsheet
    sheet_names <- c("info_modal_links", "info_figure_links", "glossary")
    
    #The url of the google spreadsheet
    cinms_content_url = "https://docs.google.com/spreadsheets/d/1yEuI7BT9fJEcGAFNPM0mCq16nFsbn0b-bNirYPU5W8c/gviz/tq?tqx=out:csv&sheet="
    
    # Let's go through all three sheets
    for (i in 1:3){
      
      # Save the new version of the sheet
      sheet_url = paste0(cinms_content_url, sheet_names[i])
      new_sheet <- read.csv(sheet_url)
      new_filename <- paste0(here::here("data/saved_cinms_content/new_"),sheet_names[i], ".csv")
      write.csv(new_sheet, file = new_filename)
      
      # Check to see if the new version of the sheet matches the saved version, if it doesn't
      # change cinms_content_changed to TRUE
      saved_filename <- paste0(here::here("data/saved_cinms_content/saved_"),sheet_names[i], ".csv")
      
      if (tools::md5sum(new_filename) != tools::md5sum(saved_filename)){
        cinms_content_changed = TRUE
        file.copy(new_filename, saved_filename, overwrite = TRUE)
      }
      file.remove (new_filename)
    }
  }
  
  # let's go through every rmd file to be worked on
  for (i in 1:length(modal_list)){
    
    # let's check if the rmd file has changed since the last rendered version of
    # the html was created
    
    htm <- fs::path_ext_set(modal_list[i], "html")
    if (file.exists(htm)){
      rmd_newer <- fs::file_info(modal_list[i])$modification_time > fs::file_info(htm)$modification_time
    } else {
      rmd_newer <- T
    }
    
    # Render the modal window if:
    # 1. the associated google spreadsheet has changed or
    # 2. if the modal window contains interactive figures or
    # 3. if the Rmd file has been recently modified or
    # 4. if the function parameter "render_all" has been set to TRUE
    if (rmd_newer | cinms_content_changed | basename(modal_list[i]) %in% interactive_rmd | render_all){
      generate_html_4_rmd(modal_list[i])
    }
  }
}

#' Produce full html for static figures, minus tooltips.
#'
#' This is a function that generates the html to display a static figure and the
#' captions for that figure. Glossary tooltips are not created here, as that
#' occurs at a later stage of the html production process.
#'
#' @param figure_id The id of the figure.
#' @param figure_img The path of the figure image.
#' @return The output is a string containing the html tags to display the figure and figure caption.
#' @export
#' @examples \dontrun{
#' render_figure("Figure App.C.4.4.", "../img/cinms_cr/App.C.4.4.Leeworthy_landings.jpg")
#' }
#'
render_figure <- function(figure_id, figure_img){
  glue::glue(
    "
  {get_figure_info(figure_id)}

  ![{md_caption(figure_id)}]({figure_img})

  {md_caption(figure_id, get_details=T)}
  ")
}

#' Render html for rmd file, including glossary tooltips.
#'
#' This function creates all of the html for a R markdown file, inserting in the
#' glossary tooltips. Note that this function will break html that contains interactive
#' figures, as most of the required javascript won't be loaded into the html <head>.
#'
#' @param rmd The R markdown file to be rendered into html.
#' @return The output is a html file that is the rendered rmd file.
#' @examples \dontrun{
#' rmd2html(here::here("modals/ca-sheephead.Rmd"))
#' }
rmd2html <- function(rmd){
  
  md1  <- fs::path_ext_set(rmd, "md")
  md2  <- paste0(fs::path_ext_remove(rmd), ".glossarized.md")
  htm1 <- paste0(fs::path_ext_remove(rmd), ".glossarized.html")
  htm2 <- fs::path_ext_set(rmd, "html")
  
  # create the intermediary markdown file (with disposable html)
  rmarkdown::render(
    rmd, output_file = htm1,
    output_format    = "html_document",
    output_options   = list(self_contained = F, keep_md = T))
  
  # glossarize
  glossarize_md(md2, md2)
  
  # create the final html file
  rmarkdown::render(
    md2, output_file = htm2,
    output_format    = "html_document",
    output_options   = list(self_contained = F), clean = F)
  
  # final cleanup
  file.remove(htm1)
  file.remove(md2)
  file.remove(paste0(substring(md2,1,stringr::str_length(md2)-3),".utf8.md"))
}