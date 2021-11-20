event_size <- c(10, 15, 20, 25, 50, 100, 500, 1000, 5000)

risk_text <- c(
  "10" = paste0("<b>A dinner party</b>", '<img src="www/example_images/10_1.svg" alt="dinner party">', '<b style="float: right">...or a convenience store</b>', '<img src="www/example_images/10_2.svg" alt="Store" width="500" height="600">'),
  "15" = HTML("<b>A boutique</b>", '<img src="www/example_images/15_1.svg" alt=" boutique">', '<b style="float: right">...or a fitness class</b>', '<img src="www/example_images/15_2.svg" alt="fitness class">'),
  "20" = HTML("<b>A coffee shop</b>", '<img src="www/example_images/20_1.svg" alt="coffee shop">', '<b style="float: right">...or a neighborhood BBQ</b>', '<img src="www/example_images/20_2.svg" alt="neighborhood BBQ">'),
  "25" = HTML("<b>A classroom</b>", '<img src="www/example_images/25_1.svg" alt="classroom">', '<b style="float: right">...or small bar</b>', '<img src="www/example_images/25_2.svg" alt="small bar">'),
  "50" = HTML("<b>A supermarket</b>", '<img src="www/example_images/50_1.svg" alt="supermarket">', '<b style="float: right">...or a restaurant</b>', '<img src="www/example_images/50_2.svg" alt="house party">'),
  "100" = HTML("<b>A wedding</b>", '<img src="www/example_images/100_1.svg" alt="wedding">', '<b style="float: right">...or a movie theater</b>', '<img src="www/example_images/100_2.svg" alt="movie theater">'),
  "500" = HTML("<b>A large airplane</b>", '<img src="www/example_images/500_1.svg" alt="large airplane">', '<b style="float: right">...or a high school basketball game</b>', '<img src="www/example_images/500_2.svg" alt="basketball game">'),
  "1000" = HTML("<b>A performing arts theater</b>", '<img src="www/example_images/1000_1.svg" alt="performing arts theater">', '<b style="float: right">...or a graduation ceremony</b>', '<img src="www/example_images/1000_2.svg" alt="graduation ceremony">'),
  "5000" = HTML("<b>A large concert</b>", '<img src="www/example_images/5000_1.svg" alt="large concert">', '<b style="float: right">...or a college basketball game</b>', '<img src="www/example_images/5000_2.svg" alt="basketball game">')
)

regions <- c(
  "USA, Alphabetical" = "states-alpha.png",
  "USA, By Rank" = "states-rank.png",
  "AK" = "AK.png", "AL" = "AL.png", "AR" = "AR.png", "AZ" = "AZ.png",
  "CA" = "CA.png", "CO" = "CO.png", "CT" = "CT.png", "DC" = "DC.png",
  "DE" = "DE.png", "FL" = "FL.png", "GA" = "GA.png", "HI" = "HI.png",
  "IA" = "IA.png", "ID" = "ID.png", "IL" = "IL.png", "IN" = "IN.png",
  "KS" = "KS.png", "KY" = "KY.png", "LA" = "LA.png", "MA" = "MA.png",
  "MD" = "MD.png", "ME" = "ME.png", "MI" = "MI.png", "MN" = "MN.png",
  "MO" = "MO.png", "MS" = "MS.png", "MT" = "MT.png", "NC" = "NC.png",
  "ND" = "ND.png", "NE" = "NE.png", "NH" = "NH.png", "NJ" = "NJ.png",
  "NM" = "NM.png", "NV" = "NV.png", "NY" = "NY.png", "OH" = "OH.png",
  "OK" = "OK.png", "OR" = "OR.png", "PA" = "PA.png", "PR" = "PR.png",
  "RI" = "RI.png", "SC" = "SC.png", "SD" = "SD.png", "TN" = "TN.png",
  "TX" = "TX.png", "UT" = "UT.png", "VA" = "VA.png", "VT" = "VT.png",
  "WA" = "WA.png", "WI" = "WI.png", "WV" = "WV.png", "WY" = "WY.png"
)


name2abbr <- setNames(state.abb, state.name)
abbr2name <- setNames(state.name, state.abb)

RISK_GAME_CHOICES <- c("USA" = "USA", sort(
  c(
    setNames(state.abb, state.name),
    "Puerto Rico" = "PR",
    "District of Columbia" = "DC"
  )
))

pal <- leaflet::colorBin("YlOrRd", bins = c(0.001, 1, 25, 50, 75, 99, 100))
legendlabs <- c("< 1", " 1-25", "25-50", "50-75", "75-99", "> 99", "No or missing data")

NAVBAR_CUSTOM_CSS <- "
    .intro-text {
        font-size: large;
    }
    .loc-text {
        font-style: italic;
        font-weight: 200;
    }

    .loc-text.success {
        color: #28b78d;
    }
    .footer {
        left: 30px;
    }
    .app-container {
        overflow: hidden;
    }
    .panel-header-title {
        font-size: 2rem;
    }
    .fake-sidebar {
        font-family: 'Helvetica Neue',Helvetica,Arial,sans-serif;
        font-size: 14px;
        line-height: 1.42857143;
        color: #333;
    }
    .context-header {
        font-size: 2rem;
    }
    @media (max-width: 1200px) {
        .navbar-header {
            float: none;
        }
        .navbar-left,.navbar-right {
            float: none !important;
        }
        .navbar-toggle {
            display: block;
        }
        .navbar-collapse {
            border-top: 1px solid transparent;
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.1);
        }
        .navbar-fixed-top {
            top: 0;
            border-width: 0 0 1px;
        }
        .navbar-collapse.collapse {
            display: none!important;
        }
        .navbar-nav {
            float: none!important;
            margin-top: 7.5px;
        }
        .navbar-nav>li {
            float: none;
        }
        .navbar-nav>li>a {
            padding-top: 10px;
            padding-bottom: 10px;
        }
        .collapse.in{
            display:block !important;
        }
    }
"

META_OGTITLE <- '<meta property="og:title" content="COVID-19 Event Risk Assessment Planning Tool" />'
META_OGTYPE <- '<meta property="og:type" content="website" />'
META_OGURL <- '<meta property="og:url" content="https://covid19risk.biosci.gatech.edu/" />'
META_OGIMG <- '<meta property="og:image" content="https://covid19risk.biosci.gatech.edu/og.png" />'

NAVPAGE_HEADER_GA <- htmltools::HTML(
  '<script async src="https://www.googletagmanager.com/gtag/js?id=UA-45174995-12"></script>
        <script>
        window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag("js", new Date());

    gtag("config", "UA-45174995-12");
    </script>
        '
)

NAVPAGE_GET_IP <- htmltools::tags$script(
  # Script to get user IP
    '
        $(document).on("shiny:sessioninitialized", function() {
          $.ajaxSetup({
              timeout: 1000
          });
          $.get("https://ipinfo.io?token=15dd4534f98729", function(response) {
              Shiny.setInputValue("ip_data", response.ip, {
                  priority: "event"
              });
          }, "json").fail(function() {
              Shiny.setInputValue("ip_data", "Unknown", {
                  priority: "event"
              });
          });
         });
      '
)

NAVPAGE_HEADER <- tags$head(
  NAVPAGE_HEADER_GA,
  NAVPAGE_GET_IP,
  shinyjs::useShinyjs(),
  sever::use_sever(),
  waiter::use_waiter(),
  # when the image panel is toggled, trigger an invalidate() on the leaflet map
  tags$script(
    '$(".panel-header-dismiss").on("click", function() { $(this).trigger("shown"); });'
  ),
  tags$script(
    src = glue::glue(
      "https://cdn.jsdelivr.net/npm/js-cookie@rc/",
      "dist/js.cookie.min.js"
    )
  ),
  tags$script(src = "www/shiny-extras.js"),
  tags$style(HTML(NAVBAR_CUSTOM_CSS)),
  HTML(META_OGTITLE, META_OGTYPE, META_OGURL, META_OGIMG)
)

NAVPAGE_FOOTER <- HTML(
  '<div class="d-none d-md-block col-md-2"></div>',
  '<div class="col-xs-12 col-sm-12 col-md-8 offset-md-2">',
  "<p>The COVID-19 Event Risk Assessment Planning Tool is a collaborative",
  'project led by <a href="https://ecotheory.biosci.gatech.edu/" ',
  'rel="noopener" target="_blank">Prof. Joshua Weitz</a> and ',
  '<a href="http://friendlycities.gatech.edu/" rel="noopener" ',
  'target="_blank">Prof. Clio Andris</a> at the Georgia Institute of ',
  "Technology, along with researchers at the ",
  '<a href="https://www.abil.ihrc.com/" rel="noopener" target="_blank">',
  "Applied Bioinformatics Laboratory</a>, Duke University, and ",
  'Stanford University, and powered by <a href="https://rstudio.com/" ',
  'rel="noopener" target="_blank">RStudio</a>.  Description of the method ',
  "and analyses available at ",
  '<a href="https://www.nature.com/articles/s41562-020-01000-9/" ',
  'rel="noopener" target="_blank">Nature Human Behaviour</a>.</p>',
  "<p>Ongoing support for the project is via the Centers for Disease ",
  "Control and Prevention (75D30121P10600), Charities in Aid Foundation, ",
  "and The Marier Cunningham Foundation.</p></div>"
)

SURVEY_ELEMENT <- div(
  class = "well fake-sidebar",
  HTML(
    "<p class='intro-text'>",
    "<a href='https://duke.qualtrics.com/jfe/form/SV_0SZR4fPxyUAg9Ke', ",
    "rel='noopener' target='_blank'>Fill out this 5-minute survey</a>",
    "for a chance to win a $50 Amazon gift card!</p>"
  )
)


CONSENT_POPUP_PLACEHOLDER <- "I am over 18 and in the US"
CONSENT_POPUP_TITLE <- "Are you over 18 and in the US?"
CONSENT_POPUP_TEXT <- paste0(
  "Users under 18 and/or those who reside outside the US",
  " are encouraged to use the risk prediction tools, ",
  "but unfortunately we cannot save your survey feedback.  ",
  "Select 'No' if you are not eligible or would like to ",
  "opt out of having your responses saved for research purposes.  ",
  "Please see the About page for more details"
)


RTR_X_LABS <- c(
  "10\nDinner party",
  "100\nWedding reception",
  "1,000\nSmall concert",
  "10,000\nSoccer match",
  "100,000\nNFL game"
)

RTR_PCRIT_STATES <- c(-9, -20, -200, -2000, -7000)

RTR_PCRIT_US <- c(9, 20, 200, 2000, 7000)
