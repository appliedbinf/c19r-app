#' risk_quiz UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_risk_quiz_ui <- function(id) {
  ns <- NS(id)
  tabPanel(
    value = "game",
    title = "Risk Quiz",
    fluid = TRUE,
    shinyWidgets::chooseSliderSkin("Round"),
    tags$script(
      '
        $(document).ready(function () {
          navigator.geolocation.getCurrentPosition(onSuccess, onError);

          function onError (err) {
          console.log(err)
            Shiny.onInputChange("geolocation", false);
          }

          function onSuccess (position) {
            setTimeout(function () {
              Shiny.onInputChange("setGeo", true);
              var coords = position.coords;
              console.log(coords.latitude + ", " + coords.longitude);
              Shiny.onInputChange("geolocation", true);
              Shiny.onInputChange("lat", coords.latitude);
              Shiny.onInputChange("long", coords.longitude);
            }, 1100)
          }
        });
                '
    ),
    fluidRow(
      shinypanels::panel(
        title = "Risk Quiz",
        can_collapse = F,
        class = "col-sm-12 col-xs-12 col-md-3",
        body = div(
          div(
            class = "well fake-sidebar",
            HTML(
              "<p class='intro-text'>Can you guess the risk levels in your community?",
              "  Take the quiz to find out, and share your high score.</p>"
            ),
            uiOutput(ns("location_selector")),
            selectizeInput(
              ns("risk_state"),
              choices = RISK_GAME_CHOICES,
              label = "Select state"
            ),
            selectizeInput(ns("risk_county"), choices = NULL, label = "Select county")
          ),
          div(style = "height: 25px;"),
          SURVEY_ELEMENT
        )
      ),
      shinypanels::panel(
        class = "col-md-auto",
        title = "",
        can_collapse = FALSE,
        body = div(
          fluidRow(
            align = "center",
            column(
              8,
              HTML(
                "<h3>Imagine a coffee shop in your area with <b><u>20 people</u></b> inside.  What's the probability that <u>at least one</u> of the people is infected with COVID-19?</h3>"
              )
            ),
            column(
              8,
              make_resp_slider(ns("quiz20"), "")
            ),
            column(3, )
          ),
          fluidRow(
            align = "center",
            column(
              8,
              HTML(
                "<h3>Imagine a grocery store in your area with <b><u>50 people</u></b> inside.  What's the probability that <u>at least one</u> of the people is infected with COVID-19?</h3>"
              )
            ),
            column(
              8,
              make_resp_slider(ns("quiz50"), "")
            ),
            column(3, )
          ),
          fluidRow(
            align = "center",
            column(
              8,
              HTML(
                "<h3>Imagine a movie theater in your area with <b><u>100 people</u></b> inside.  What's the probability that <u>at least one</u> of the people is infected with COVID-19?</h3>"
              )
            ),
            column(
              8,
              make_resp_slider(ns("quiz100"), "")
            ),
            column(3, )
          ),
          fluidRow(
            align = "center",
            column(
              8,
              HTML(
                "<h3>Imagine a graduation ceremony in your area with <b><u>1000 people</u></b> inside.  What's the probability that <u>at least one</u> of the people is infected with COVID-19?</h3>"
              )
            ),
            column(
              8,
              make_resp_slider(ns("quiz1000"), "")
            ),
            column(3, )
          ),
          fluidRow(
            align = "center",
            column(
              8,
              shinyWidgets::actionBttn(
                ns("submit_answers"),
                label = "I'm done! Show my results",
                style = "jelly",
                color = "success",
                size = "sm"
              )
            )
          )
        )
      )
    )
  )
}

#' risk_quiz Server Functions
#'
#' @noRd
mod_risk_quiz_server <- function(id, globals) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    geo_county <- reactiveVal(NULL)

    observeEvent(input$`nav-page`, {
      if (input$`nav-page` == "game" && is.null(globals$consent())) {
        shinyWidgets::inputSweetAlert(
          session = session,
          inputId = ns("game_consent"),
          inputPlaceholder = CONSENT_POPUP_PLACEHOLDER,
          title = CONSENT_POPUP_TITLE,
          text = CONSENT_POPUP_TEXT,
          type = "question",
          reset_input = TRUE,
          btn_labels = "Confirm",
          input = "radio",
          inputOptions = c("yes" = "Yes", "no" = "No"),
          inputValue = "yes"
        )
      }
    })

    observeEvent(input$game_consent, {
      if (input$game_consent == "yes") {
        session$sendCustomMessage("cookie-set", list(name = "consent", value = "yes"))
      } else {
        session$sendCustomMessage("cookie-set", list(name = "consent", value = "no"))
      }
    })

    observeEvent(input$risk_state,
      {
        if (length(geo_county()) > 0) {
          geo_county(NULL)
        } else {
          if (input$risk_state == "USA") {
            game_counties <- "Entire US"
          } else {
            game_counties <- usa_counties %>%
              dplyr::filter(stname == !!input$risk_state) %>%
              dplyr::pull(NAME) %>%
              sort() %>%
              unique()
          }

          updateSelectizeInput("risk_county",
            choices = game_counties,
            session = session
          )
        }
      },
      ignoreNULL = T
    )

    output$location_selector <- renderUI({
      if (globals$geolocation()) {
        HTML("<p class='loc-text success'>Detected your location automatically</p>")
      } else {
        HTML("<p class='loc-text'>Please choose your location below</p>")
      }
    })

    observeEvent(globals$setGeo(),
      {
        if (globals$geolocation()) {
          api_url <- glue::glue(
            "https://geo.fcc.gov/api/census/block/find?",
            "latitude={globals$latitude()}&longitude={globals$longitude()}&format=json"
          )
          location <- jsonlite::fromJSON(api_url, )
          geo_county(location$County$name)

          if (is.null(geo_county())) {
            return(NULL)
          }
          updateSelectizeInput(
            "risk_county",
            session = session,
            choices = usa_counties %>%
              dplyr::filter(stname == location$State$code) %>%
              dplyr::pull(NAME) %>%
              sort() %>%
              unique(),
            selected = geo_county()
          )
          updateSelectizeInput("risk_state",
            session = session,
            selected = location$State$code
          )
        }
      },
      ignoreNULL = T
    )

    observeEvent(input$submit_answers, {
      if (is.null(globals$consent())) {
        shinyWidgets::inputSweetAlert(
          session = session,
          inputId = ns("game_consent"),
          input = "checkbox",
          inputPlaceholder = CONSENT_POPUP_PLACEHOLDER,
          title = CONSENT_POPUP_TITLE,
          text = CONSENT_POPUP_TEXT,
          type = "question",
          reset_input = TRUE
        )
        return(NULL)
      }
      shinyjs::show("game_interactive_elem")
      shinyjs::show("game_will")
      sel_state <- input$risk_state
      sel_county <- input$risk_county
      ans_20 <- input$quiz20
      ans_50 <- input$quiz50
      ans_100 <- input$quiz100
      ans_1000 <- input$quiz1000
      if (sel_state == "USA") {
        USpop <- 331 * 10^6
        C_i <- sum(as.numeric(state_data$C_i))
        quiz_nvec <- c(20, 50, 100, 1000)
        pred_risk <- as.data.frame(
          as.list(calc_risk(C_i, quiz_nvec, USpop)),
          col.names = c("pred_20", "pred_50", "pred_100", "pred_1000"),
          row.names = NULL
        ) %>%
          dplyr::mutate(
            GEOID = "0",
            data_ts = usa_counties %>% dplyr::pull(updated) %>% dplyr::first()
          )
      } else {
        pred_risk <- usa_counties %>%
          dplyr::filter(stname == sel_state, NAME == sel_county) %>%
          sf::st_drop_geometry() %>%
          dplyr::select(
            GEOID,
            data_ts = updated,
            pred_20 = "4_20",
            pred_50 = "4_50",
            pred_100 = "4_100",
            pred_1000 = "4_1000"
          )
      }

      pred_risk <- pred_risk %>%
        dplyr::mutate(
          g_20 = ans_20,
          g_50 = ans_50,
          g_100 = ans_100,
          g_1000 = ans_1000
        ) %>%
        dplyr::rowwise() %>%
        dplyr::mutate(
          diff_20 = pred_20 - g_20,
          diff_50 = pred_50 - g_50,
          diff_100 = pred_100 - g_100,
          diff_1000 = pred_1000 - g_1000
        )
      results_table <- data.table::data.table(
        "Event size" = as.integer(c(20, 50, 100, 1000)),
        "Predicted risk" = riskParams(trunc(
          c(
            pred_risk$pred_20,
            pred_risk$pred_50,
            pred_risk$pred_100,
            pred_risk$pred_1000
          )
        )),
        "Your guess" = paste0(round(c(
          ans_20, ans_50, ans_100, ans_1000
        )), "%")
      )
      if (any(dplyr::select(pred_risk, dplyr::starts_with("pred_")) < 1)) {
        overall_acc <- "Overall accuracy: Not available"
        acc_text <- "Overall accuracy not available due to data limitations"
        tweet_msg <- glue::glue(
          "I just took the @covid19riskusa Risk Quiz. Try it out and guess the risk in your own community!"
        )
      } else {
        overall_acc_perc <- round(100 - (sum(abs(
          dplyr::select(pred_risk, starts_with("diff"))
        )) / 4))
        overall_acc <- glue::glue("Overall Accuracy: {overall_acc_perc}%")
        tweet_msg <- glue::glue(
          "I scored {overall_acc_perc}% on the @covid19riskusa Risk Quiz. Try it out and guess the risk in your own community!"
        )
        signed_err <- (sum(dplyr::select(pred_risk, starts_with("diff"))) / 4)
        acc_text <- dplyr::case_when(
          signed_err >= 25 ~ "Our risk estimates were higher than your guesses.",
          signed_err >= 10 ~ "Our risk estimates were slightly higher than your guesses.",
          signed_err > -10 ~ "Our risk estimates were close to your guesses!",
          signed_err >= -25 ~ "Our risk estimates were slightly lower than your guesses.",
          signed_err <= 25 ~ "Our risk estimates were lower than your guesses."
        )
      }

      if (globals$consent() == "yes") {
        sql <-
          "INSERT INTO risk_game_results
        (
          GEOID, data_ts, pred_20, pred_50,
          pred_100, pred_1000, g_20, g_50,
          g_100, g_1000, ip, latitude,
          longitude, utm_source, utm_medium,
          utm_content, utm_campaign
        )
        VALUES (?geoid, ?data_ts, ?p20,
                ?p50, ?p100, ?p1000, ?g20,
                ?g50, ?g100, ?g1000, ?ip,
                ?lat, ?long, NULLIF(?utm_source, 'NULL'),
                NULLIF(?utm_medium, 'NULL'),
                NULLIF(?utm_content, 'NULL'),
                NULLIF(?utm_campaign, 'NULL')
        )"

        query <-
          DBI::sqlInterpolate(
            DBI::ANSI(),
            gsub("\\n\\w+", " ", sql),
            geoid = pred_risk$GEOID,
            data_ts = pred_risk$data_ts,
            p20 = pred_risk$pred_20,
            p50 = pred_risk$pred_50,
            p100 = pred_risk$pred_100,
            p1000 = pred_risk$pred_1000,
            g20 = pred_risk$g_20,
            g50 = pred_risk$g_50,
            g100 = pred_risk$g_100,
            g1000 = pred_risk$g_1000,
            ip = globals$ip(),
            lat = globals$latitude(),
            long = globals$longitude(),
            utm_source = globals$ref_content()$utm_source,
            utm_medium = globals$ref_content()$utm_medium,
            utm_content = globals$ref_content()$utm_content,
            utm_campaign = globals$ref_content()$utm_campaign
          )
        conn <- pool::poolCheckout(db)
        DBI::dbSendQuery(conn, query)
        pool::poolReturn(conn)
      }

      tweet_url <- glue::glue(
        "https://twitter.com/intent/tweet?text={tweet_msg}&url=https://covid19risk.biosci.gatech.edu/?quiz"
      )
      shinyWidgets::show_alert(
        title = "Your quiz results",
        text = div(
          h4(overall_acc),
          p(acc_text),
          renderTable(results_table, align = "c", width = "100%", ),
          tags$a(
            href = URLencode(tweet_url),
            tags$i("Tweet your score", class = "fab fa-twitter"),
            class = "twitter-share-button twitter-hashtag-button",
            target = "_blank"
          ),
          br(),
          if (globals$consent() == "yes") {
            tagList(
              fluidRow(
                id = ns("game_interactive_elem"),
                align = "center",
                column(
                  width = 12,
                  div(
                    "After taking this quiz, are you MORE or LESS willing to participate in an events in your area?",
                  ),
                  shinyWidgets::sliderTextInput(
                    ns("quiz_followup"),
                    "",
                    choices = c(
                      "1" = "Much less willing",
                      "2" = "A little less willing",
                      "3" = "Same as before",
                      "4" = "A little more willing",
                      "5" = "Much more willing"
                    ),
                    selected = "Same as before",
                    grid = T,
                    width = "85%",
                    hide_min_max = T
                  )
                )
              ),
              shinyWidgets::actionBttn(
                ns("game_will"),
                label = "Submit",
                style = "jelly",
                color = "success",
                size = "sm"
              )
            )
          }
        ),
        html = TRUE,
        closeOnClickOutside = FALSE,
        width = "400px%",
        showCloseButton = T,
        btn_labels = NA
      )
    })


    observeEvent(input$game_will, {
      save_willingness(
        db = globals$db,
        source = "game",
        asc_bias = -1,
        event_size = -1,
        answer = input$quiz_followup,
        ip = globals$ip(),
        vacc_imm = -1,
        latitude = globals$latitude(),
        longitude = globals$longitude(),
        utm_source = globals$ref_content()$utm_source,
        utm_medium = globals$ref_content()$utm_medium,
        utm_content = globals$ref_content()$utm_content,
        utm_campaign = globals$ref_content()$utm_campaign
      )
      shinyjs::hide("game_interactive_elem")
      shinyjs::hide("game_will")
    })
  })
}

## To be copied in the UI
# mod_risk_quiz_ui("risk_quiz_ui_1")

## To be copied in the server
# mod_risk_quiz_server("risk_quiz_ui_1")
