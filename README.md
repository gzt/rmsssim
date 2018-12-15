
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rmsssim

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/gzt/rmsssim.svg?branch=master)](https://travis-ci.org/gzt/rmsssim)
[![Coverage
status](https://codecov.io/gh/gzt/rmsssim/branch/master/graph/badge.svg)](https://codecov.io/github/gzt/rmsssim?branch=master)

The goal of `rmsssim` is to provide an R interface for the MS-SSIM image
comparison metric. This was not written by me, `gzt`, this was imported
from [spatialcompare](https://github.com/colinr23/spatialcompare), which
has a number of other functions I am not interested in and some
dependencies that no longer work for me. This package depends on
[raster](https://cran.r-project.org/package=raster).

## Installation

You can install this from github with:

``` r
#install.packages('devtools')
devtools::install_github('gzt/rmsssim')
```

Installing this may still be a bit frustrating, as `rgdal` is
non-trivial to get working. On Fedora, make sure to run `dnf install
proj proj-epsg proj-devel gdal gdal-devel` first. On other systems,
change the commands accordingly. This [StackOverflow
answer](https://stackoverflow.com/questions/15248815/rgdal-package-installation)
has some guidance.

Please note that the ‘rmsssim’ project is released with a [Contributor
Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.
