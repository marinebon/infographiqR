[![Build Status](https://travis-ci.org/marinebon/infographiq.svg?branch=master)](https://travis-ci.org/marinebon/infographiq) 

# infographiq
R library for creation of interactive infographics for data-driven storytelling.
This tool will help you build your own interactive infographics website from only csv files and svg images.
Please contact us by opening an issue if you need help getting started with this tool.

## Demos
The following regional infographics were generated using the infographiq package:

* [Florida Keys Marine Sanctuary Infographics](https://marinebon.github.io/info-fk/corals.html) - [github repo](https://github.com/marinebon/info-fk/)
* [Monterey Bay Infographics](https://marinebon.github.io/info-mb/pelagic.html) - [github repo](https://github.com/marinebon/info-mb)

# Usage overview

1. Define your infographic by creating the following files:

  * `./svg_elements.csv`
  * `./plot_indicators.csv`
  * `./svg/*.svg`

  For example files see [the info-demo repository](https://github.com/marinebon/info-demo), or one of the examples cited above.

2. Use infographiq from an R console to generate the website:

  Install the infographiq R package and those it depends on. You only need to do this once.

  ```R
# install required packages
install.packages(c("tidyverse", "stringr", "rmarkdown", "dygraphs", "xts", "lubridate", "geojsonio", "RColorBrewer", "leaflet", "crosstalk", "servr", "roxygen2", "futile.logger"))

# install infographiq from Github
if (!require('devtools')) install.packages('devtools')
devtools::install_github('marinebon/infographiq')
```

  Load the library and create the site.

  ```R
# load
library(infographiq)

# run i.e.
create_info_site(site_title = "Monterey Bay Infographics", render_modals = T)
```

# Developer workflow

We developed this R package using the excellent [`devtools`](https://www.rstudio.com/products/rpackages/devtools/) package. If you are actively changing your local copy of the infographiq package, ie functions contained in it, you can reload with:

```R
library('devtools')
install_local('../infographiq')

# or
install('../infographiq")
```

To build documentation (using roxygen2, and assuming working directory is in 'infographiq')...

```R
document()
```

# More Background

We will be actively developing this package (2017-11 to 2018-04), so please check back for updates. Here is some more background material that we will more seamlessly fold into documentation here at some point:

* [https://marinebon.github.io/cr-metrics/README.html](https://marinebon.github.io/cr-metrics/README.html)
* [Help & Documentation for the Marine Biodiversity Observation Network (MBON)](https://marinebon.github.io/help/apps.html#interactive-infographics)


### Dependencies

```r
pkgs <- c(
  "tidyverse", "brew", "rmarkdown", 
  "tools", "servr", "futile.logger",
  "dygraphs", "xts")
for (p in pkgs){
  devtools::use_package(p)
}
```

### Updating website

To update the website for the R package, update documentation and regenerate the website outputs into the `docs/` folder:

```R
devtools::document()
pkgdown::build_site()
```

### Vignettes

```R
devtools::use_vignette("quick-start")
```
