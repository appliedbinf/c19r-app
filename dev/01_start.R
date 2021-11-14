# Building a Prod-Ready, Robust Shiny Application.
# 
# README: each step of the dev files is optional, and you don't have to 
# fill every dev scripts before getting started. 
# 01_start.R should be filled at start. 
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
# 
# 
########################################
#### CURRENT FILE: ON START SCRIPT #####
########################################

## Fill the DESCRIPTION ----
## Add meta data about your application
## 
## /!\ Note: if you want to change the name of your app during development, 
## either re-run this function, call golem::set_golem_name(), or don't forget
## to change the name in the app_sys() function in app_config.R /!\
## 
golem::fill_desc(
  pkg_name = "covid19RiskPlanner", # The Name of the package containing the App 
  pkg_title = "COVID-19 Event Risk Assessment Planning Tool", # The Title of the package containing the App 
  pkg_description = "Visualize the risk stimated chance (0-100%) that at least 1 COVID-19 positive individual will be present at an event in a county, given the size of the event.", # The Description of the package containing the App 
  author_first_name = "Aroon", # Your First Name
  author_last_name = "Chande", # Your Last Name
  author_email = "achande@ihrc.com", # Your Email
  repo_url = "https://github.com/ar0ch/c19r-app" # The URL of the GitHub Repo (optional) 
)     

## Set {golem} options ----
golem::set_golem_options()

## Create Common Files ----
## See ?usethis for more information
rights_holders = paste("2020-2021 Aroon T. Chande <achande@ihrc.com>",
    "2020-2021 Joshua S. Weitz <jsweitz@gatech.edu>",
    "2020-2021 Stephen J. Beckett <stephen.beckett@biology.gatech.edu>",
    "2020-2021 Clio Andris <clio@gatech.edu>",
    "2020-2021 Lavanya Rishishwar <LRishishwar@ihrc.com>",
    "2021 Freyja A. Brandel-Tanis <freyja.alice@gatech.edu>",
    "2020 Seohla Lee <seolha.lee@gatech.edu>",
    "2020 Quan Nguyen <qnguyen83@gatech.edu>",
    "2020 Mallory Harris <Mharris9@stanford.edu>", sep = "\n  ")
usethis::use_mit_license(copyright_holder =  rights_holders)  # You can set another license here
usethis::use_readme_rmd( open = FALSE )
usethis::use_code_of_conduct()
usethis::use_lifecycle_badge( "Experimental" )
usethis::use_news_md( open = FALSE )

## Use git ----
usethis::use_git()

## Init Testing Infrastructure ----
## Create a template for tests
golem::use_recommended_tests()

## Use Recommended Packages ----
golem::use_recommended_deps()

## Favicon ----
# If you want to change the favicon (default is golem's one)
golem::use_favicon() # path = "path/to/ico". Can be an online file. 
golem::remove_favicon()

## Add helper functions ----
golem::use_utils_ui()
golem::use_utils_server()

# You're now set! ----

# go to dev/02_dev.R
rstudioapi::navigateToFile( "dev/02_dev.R" )

