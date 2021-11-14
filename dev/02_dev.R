# Building a Prod-Ready, Robust Shiny Application.
# 
# README: each step of the dev files is optional, and you don't have to 
# fill every dev scripts before getting started. 
# 01_start.R should be filled at start. 
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
# 
# 
###################################
#### CURRENT FILE: DEV SCRIPT #####
###################################

# Engineering

## Dependencies ----
## Add one line by package you want to add as dependency
usethis::use_package( "withr" )
usethis::use_package( "ggplot2" )
usethis::use_package( "ggrepel" )
usethis::use_package( "matlab" )
usethis::use_package( "lubridate" )
usethis::use_package( "dplyr" )
usethis::use_package( "ggthemes" )
usethis::use_package( "sever" )
usethis::use_package( "DBI" )
usethis::use_package( "dbplyr" )
usethis::use_package( "glue" )
usethis::use_package( "sf" )
usethis::use_package( "leaflet" )
usethis::use_package( "shinyjs" )
usethis::use_package( "shinypanels" )
usethis::use_package( "vroom" )
usethis::use_package( "rlang" )
usethis::use_package( "shinyWidgets" )
usethis::use_package( "shinythemes" )
usethis::use_package( "tidyr" )
usethis::use_package( "utils" )
usethis::use_package( "wk" )
usethis::use_package( "s2" )
## Add modules ----
## Create a module infrastructure in R/

## Add helper functions ----
## Creates fct_* and utils_*
golem::add_fct( "map" )
golem::add_fct( "quiz" )
golem::add_fct( "feedback" )
golem::add_utils( "shiny" )
golem::add_utils( "helpers" )
golem::add_utils( "constants" )

## External resources
## Creates .js and .css files at inst/app/www
golem::add_js_file( "shiny-extras" )

## Add internal datasets ----
## If you have data in your package
usethis::use_data_raw( name = "my_dataset", open = FALSE ) 

## Tests ----
## Add one line by test you want to create
usethis::use_test( "app" )

# Documentation

## Vignette ----
usethis::use_vignette("covid19RiskPlanner")
devtools::build_vignettes()

## Code Coverage----
## Set the code coverage service ("codecov" or "coveralls")
usethis::use_coverage()

# Create a summary readme for the testthat subdirectory
covrpage::covrpage()

## CI ----
## Use this part of the script if you need to set up a CI
## service for your application
## 
## (You'll need GitHub there)
usethis::use_github()

# GitHub Actions
usethis::use_github_action() 
# Chose one of the three
# See https://usethis.r-lib.org/reference/use_github_action.html
usethis::use_github_action_check_release() 
usethis::use_github_action_check_standard() 
usethis::use_github_action_check_full() 
# Add action for PR
usethis::use_github_action_pr_commands()

# Travis CI
usethis::use_travis() 
usethis::use_travis_badge() 

# AppVeyor 
usethis::use_appveyor() 
usethis::use_appveyor_badge()

# Circle CI
usethis::use_circleci()
usethis::use_circleci_badge()

# Jenkins
usethis::use_jenkins()

# GitLab CI
usethis::use_gitlab_ci()

# You're now set! ----
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")

