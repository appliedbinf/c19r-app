# covid19RiskPlanner 1.2.1
* Add social media icons to header


# covid19RiskPlanner 1.2.0
* Documentation updates  
* Update Footer text to include new funding  
* Catch DB connection errors earlier and emit a useful error message


# covid19RiskPlanner 1.1.4
* Catch 502s from FCC's geolocation API

# covid19RiskPlanner 1.1.3 (Unreleased)

* Force allow session reconnects to hopefully cut down on websocket errors
* Temporarily preserve shiny logs on prod to help debug abrust session ending

# covid19RiskPlanner 1.1.2

* Fix to quiz buttons

# covid19RiskPlanner 1.1.1

*  Update About text

# covid19RiskPlanner 1.1.0

* Integrate Global map as leaflet
* Fix quiz consent not catching "yes" on all tabs

# covid19RiskPlanner 1.0.5

* Update authors

# covid19RiskPlanner 1.0.4

* Map sidebar text is now generated 
* Small grammar fixes


# covid19RiskPlanner 1.0.3

* Documentation updates and pkgdown site
* Add action icons to replace text on US map tab
* Expand EU ascertainment bias to 2, 3, and 5
* Fix for NYT data loading when folder is empty
* Update imports
* Start using c19rdata library to init risk info


# covid19RiskPlanner 1.0.2

* Support for per-county vaccine overlays
* Add Kansas City and Joplin as distinct regions
* Fix downloads of real time images
* Use custom data paths
* Use externally updated data


# covid19RiskPlanner 1.0

* App fully ported over to `{golem}`
* Now uses `{shiny}` modules and `reactive()` liberally
* Database secrets passed via ENV to docker or saved in the currently scoped `.Renviron`
