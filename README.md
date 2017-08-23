# infographiq
R library for creation of interactive infographics for data-driven storytelling

# usage overview

1. Define your infographic by creating the following files:

* `./svg_elements.csv`
* `./plot_indicators.csv`
* `./svg/*.svg`

See `./inst/example_fk` for example files.

2. Use infographiq from an R console to generate the website:

```R
# install
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
