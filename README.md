# infographiq
R library for creation of interactive infographics for data-driven storytelling

# usage overview

1. Define your infographic by creating the following files:

* `./svg_elements.csv`
* `./plot_indicators.csv`
* `./svg/*.svg`

For example files see [the info-demo repository](https://github.com/marinebon/info-demo), or one of the following regional infographics that have been generated using the infographiq package:

* [Florida Keys infographics](https://github.com/marinebon/info-fk/)
* [Monterray Bay Infographics](https://github.com/marinebon/info-mb)

2. Use infographiq from an R console to generate the website:

```R
# install
install.packages(c("tidyverse", "stringr", "rmarkdown", "dygraphs", "xts", "lubridate", "geojsonio", "RColorBrewer", "leaflet", "crosstalk", "servr", "roxygen2", "futile.logger"))

if (!require('devtools')) install.packages('devtools')
devtools::install_github('marinebon/infographiq')

# load
library(infographiq)

# run
create_info_site()
```

# dev workflow

```R
# to test your infographic generation with a local copy of infographiq
# you must install from local source
require('devtools')
install_local('../infographiq')
```
