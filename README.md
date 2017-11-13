# infographiq
R library for creation of interactive infographics for data-driven storytelling.
This tool will help you build your own interactive infographics website from only csv files and svg images.
Please contact us by opening an issue if you need help getting started with this tool.

## Demos
The following regional infographics were generated using the infographiq package:

* [Florida Keys Marine Sanctuary Infographics](https://marinebon.github.io/info-fk/corals.html) - [github repo](https://github.com/marinebon/info-fk/)
* [Monterey Bay Infographics](https://marinebon.github.io/info-mb/pelagic.html) - [github repo](https://github.com/marinebon/info-mb)

# usage overview

1. Define your infographic by creating the following files:

* `./svg_elements.csv`
* `./plot_indicators.csv`
* `./svg/*.svg`

For example files see [the info-demo repository](https://github.com/marinebon/info-demo), or one of the examples cited above.

2. Use infographiq from an R console to generate the website:

```R
# install
install.packages(c("tidyverse", "stringr", "rmarkdown", "dygraphs", "xts", "lubridate", "geojsonio", "RColorBrewer", "leaflet", "crosstalk", "servr", "roxygen2", "futile.logger"))

if (!require('devtools')) install.packages('devtools')
devtools::install_github('marinebon/infographiq')

# load
library(infographiq)

# run i.e.
create_info_site(site_title = "Monterey Bay Infographics", render_modals = T)
```

# dev workflow

```R
# to test your infographic generation with a local copy of infographiq
# you must install from local source
require('devtools')
install_local('../infographiq')

# or
devtools::install("~/infographiq")
```

## building documentation
documentation is generated using roxygen2...
