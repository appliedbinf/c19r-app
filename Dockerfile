FROM rocker/r-ver:4.0.2
RUN apt-get update && apt-get install -y  gdal-bin git-core libcurl4-openssl-dev libgdal-dev libgeos-dev libgeos++-dev libgit2-dev libicu-dev libpng-dev libproj-dev libssl-dev libudunits2-dev libxml2-dev make pandoc pandoc-citeproc && rm -rf /var/lib/apt/lists/*
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("magrittr",upgrade="never", version = "2.0.1")'
RUN Rscript -e 'remotes::install_version("rlang",upgrade="never", version = "0.4.11")'
RUN Rscript -e 'remotes::install_version("glue",upgrade="never", version = "1.4.2")'
RUN Rscript -e 'remotes::install_version("processx",upgrade="never", version = "3.5.2")'
RUN Rscript -e 'remotes::install_version("htmltools",upgrade="never", version = "0.5.1.1")'
RUN Rscript -e 'remotes::install_version("withr",upgrade="never", version = "2.4.2")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.6.0")'
RUN Rscript -e 'remotes::install_version("ggplot2",upgrade="never", version = "3.3.3")'
RUN Rscript -e 'remotes::install_version("attempt",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("dplyr",upgrade="never", version = "1.0.6")'
RUN Rscript -e 'remotes::install_version("shinyjs",upgrade="never", version = "2.0.0")'
RUN Rscript -e 'remotes::install_version("DBI",upgrade="never", version = "1.1.1")'
RUN Rscript -e 'remotes::install_version("testthat",upgrade="never", version = "3.0.1")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("tidyr",upgrade="never", version = "1.1.3")'
RUN Rscript -e 'remotes::install_version("shinythemes",upgrade="never", version = "1.2.0")'
RUN Rscript -e 'remotes::install_version("shinyWidgets",upgrade="never", version = "0.5.6")'
RUN Rscript -e 'remotes::install_version("vroom",upgrade="never", version = "1.5.5")'
RUN Rscript -e 'remotes::install_version("leaflet",upgrade="never", version = "2.0.4.1")'
RUN Rscript -e 'remotes::install_version("sf",upgrade="never", version = "0.9-7")'
RUN Rscript -e 'remotes::install_version("dbplyr",upgrade="never", version = "2.1.1")'
RUN Rscript -e 'remotes::install_version("ggthemes",upgrade="never", version = "4.2.4")'
RUN Rscript -e 'remotes::install_version("lubridate",upgrade="never", version = "1.7.10")'
RUN Rscript -e 'remotes::install_version("matlab",upgrade="never", version = "1.0.2")'
RUN Rscript -e 'remotes::install_version("ggrepel",upgrade="never", version = "0.9.1")'
RUN Rscript -e 'remotes::install_version("DT",upgrade="never", version = "0.17")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_github("ar0ch/shinypanels@06483856c76a7e879b39976739b20527fc965616")'
RUN Rscript -e 'remotes::install_github("ar0ch/sever@97ca2388481c4dd3ba51fc95992088f143599678")'
RUN Rscript -e 'remotes::install_version("wk",upgrade="never", version = "0.5.0")'
RUN Rscript -e 'remotes::install_version("s2",upgrade="never", version = "1.0.7")'
RUN Rscript -e 'remotes::install_version("jsonlite",upgrade="never", version = "1.7.2")'
RUN Rscript -e 'remotes::install_version("RMySQL",upgrade="never", version = "0.10.22")'
RUN Rscript -e 'remotes::install_version("data.table",upgrade="never", version = "1.13.6")'
RUN Rscript -e 'remotes::install_version("pool",upgrade="never", version = "0.1.6")'
RUN Rscript -e 'remotes::install_version("waiter",upgrade="never", version = "0.2.4")'
RUN Rscript -e 'remotes::install_version("vctrs",upgrade="never", version = "0.3.8")'
RUN Rscript -e 'remotes::install_github("JohnCoene/sever@4accf448140f1de0d8b634b2aa1e5c4b7fd52059")

RUN mkdir /build_zone
RUN apt-get update && apt-get install wget gdebi-core -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.17.973-amd64.deb \
	&& gdebi -n shiny-server-1.5.17.973-amd64.deb
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf /build_zone
EXPOSE 80
RUN rm -rf /srv/shiny-server/* \
	&& chown shiny:shiny /var/lib/shiny-server \
	&& chmod 777 -R /usr/local/lib/R/site-library/covid19RiskPlanner/ \
	&& echo "covid19RiskPlanner::run_app()" > /srv/shiny-server/app.R

COPY run-shiny-server /run-shiny-server

RUN chmod +x /run-shiny-server

CMD /run-shiny-server
