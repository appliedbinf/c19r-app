
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covid19RiskPlanner

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of covid19RiskPlanner is to …

## Installation

You can install the released version of covid19RiskPlanner from Github
with:

``` r
remotes::install_github("appliedbinf/c19r-app")
```

Or by pulling the pre-built Docker image

``` bash
docker pull appliedbioinformaticslab/c19r:latest
```

## Example

Run the application with:

``` bash
docker run -it \
    -p 80:80 \
    -e MYSQL_USERNAME="username" \
    -e MYSQL_PASSWORD="password" \
    -e MYSQL_HOST="host" \
    appliedbioinformaticslab/c19r:latest
```
