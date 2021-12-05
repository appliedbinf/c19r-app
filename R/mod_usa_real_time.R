#' usa_real_time UI Function
#'
#' @description Real time risk tab.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_usa_real_time_ui <- function(id) {
  ns <- NS(id)
  tabPanel(
    value = "usa-real-time",
    "Real-time US and State-level estimates ",
    fluid = TRUE,
    sidebarLayout(
      sidebarPanel(
        width = 3,
        HTML(
          "<p>The horizontal dotted lines with risk estimates are based on ",
          "real-time COVID19 surveillance data. They represent estimates ",
          "given the current reported incidence [C<sub>I</sub>] ",
          "(<span title='circle' style='color: red'>&#11044;</span>), 5 ",
          "times the current incidence (<span title='triangle' style='color: ",
          "red'>&#9650;</span>), and 10 times the current incidence ",
          "(<span title='square' style='color: red'>&#9632;</span>).",
          "These estimates help understand the effects of potential ",
          "under-testing and reporting of COVID19 incidence.</p>"
        ),
        htmlOutput(ns("dd_current_data")),
        checkboxInput(ns("use_state_dd"), label = "Limit prediction to state level?", value = TRUE),
        conditionalPanel(
          condition = "input.use_state_dd", ns = ns,
          selectizeInput(ns("states_dd"), "Select state", choices = names(regions), selected = "GA")
        ),
        textInput(ns("event_dd"),
          "Event size:",
          placeholder = 275
        ),
        downloadButton(ns("dl_dd"), "Download plot"),
        htmlOutput(ns("dd_text"))
      ),
      mainPanel(
        plotOutput(
          ns("plot_dd"),
          width = "900px", height = "900px"
        )
      )
    )
  )
}

#' usa_real_time Server Functions
#'
#' @noRd
mod_usa_real_time_server <- function(id, globals) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns


    # Reactive inputs that trigger plot generation and Ci text updates
    # input$states_dd = State selected from dropdown
    # input$event_dd = Event size to compute risk clines for
    # input$user_state_dd BOOL, whether to use the selected state or whole US
    dd_inputs <- reactive({
      list(input$states_dd, input$event_dd, input$use_state_dd)
    })


    observeEvent(dd_inputs(), {
      # Require all inputs, prevents run before init and user interaction
      req(dd_inputs)
      # Set X-axis exemplar event sizes 
      xblock <- c(10, 100, 1000, 10**4, 10**5)
      names(xblock) <- RTR_X_LABS
      # Should the selected state or whole US be usused
      use_state <- input$use_state_dd
      state <- input$states_dd
      states_dd <- state
      if (use_state) {
        #
        predictionPopSize <- as.numeric(state_pops[state_pops$state == state, "pop"])
        pcrit_label_x <- RTR_PCRIT_STATES
        C_i <- as.numeric(state_data[state_data$state == state, "C_i"])
        yblock <- c(10, 100, 1000, C_i, 5 * C_i, 10 * C_i, 10 * 10^ceiling(log10(10 * C_i)))
        names(yblock) <- format(yblock, big.mark = ",")
        ylimits <- c(10, max(yblock))
      } else {
        states_dd <<- "US"
        # Estimate of US population, small variations here has no real impact
        predictionPopSize <- 331 * 10^6
        pcrit_label_x <- RTR_PCRIT_US
        C_i <- sum(as.numeric(state_data$C_i))
        yblock <- c(10**c(1, 2, 3, 4, 5), 4 * 10**5, 10**6, 2 * 10**6, 8 * 10**6)
        names(yblock) <-
          c(
            "10",
            "100",
            "1,000",
            "10,000",
            "100,000",
            "400,000",
            "1 million",
            "2 million",
            "8 million"
          )
        ylimits <- c(10**4, 3 * 10**7)
      }
      nvec <- c(C_i, 5 * C_i, 10 * C_i)
      # Get event size from user input, strip spaces, commas and dashes
      event_size <- as.numeric(gsub("[ ,-]", "", isolate(input$event_dd)))
      # Calculate risk
      risk <- calc_risk(nvec, event_size, predictionPopSize, 1)
      risk <- dplyr::case_when(risk < .1 ~ "<0.1", risk > 99 ~ ">99", TRUE ~ as.character(risk))

      output$dd_text <- renderUI({
        HTML(paste0(
          "<p style='font-size: 18px;'><br/><strong>C<sub>I</sub> ",
          "= Current reported incidence</strong><br/>Chance someone is ",
          "COVID19 positive at C<sub>I</sub>  (",
          format(nvec[1], big.mark = ","), "): ", risk[1], "%<br/>",
          "Chance someone is COVID19 positive at 5x C<sub>I</sub> (",
          format(nvec[2], big.mark = ","), "): ", risk[2], "%<br/>",
          "Chance someone is COVID19 positive at 10x C<sub>I</sub> (",
          format(nvec[3], big.mark = ","), "): ", risk[3], "%</p>"
        ))
      })


      output$plot_dd <- renderPlot({
        req(input$states_dd)
        req(input$event_dd)
        req(predictionPopSize)
        shiny::validate(need(event_size > 9, "Please enter an event size >= 10"))
        n <- matlab::logspace(0, 6, 100)
        pcrit_val <- pcrit(n)
        numcrit <- pcrit_val * predictionPopSize
        sizevec <- c(1, 10, 100, 1000, 10000, 100000, 10**7)
        risk_vals <- c(0.01, 0.02, 0.1, 0.5, 0.9)
        pcrit_risk_list <- list()
        for (i in 1:length(risk_vals)) {
          pcrit_risk <- 1 - (1 - risk_vals[i])**(1 / n)
          pcrit_risk <- pcrit_risk * predictionPopSize
          pcrit_risk[is.infinite(pcrit_risk)] <- predictionPopSize
          pcrit_risk_list[[i]] <- data.frame("risk" = risk_vals[i], "y" = pcrit_risk, "x" = n)
        }
        ytarget <- 100000
        pcrit_label <- ytarget / predictionPopSize
        pcrit_lab_list <- list()
        for (i in 1:length(risk_vals)) {
          nlabel <- log(1 - risk_vals[i]) / log(1 - pcrit_label)
          pcrit_lab_list[[i]] <- data.frame("risk" = risk_vals[i], "x" = nlabel, y = ytarget * 1.4)
        }

        risk_vals_list <- list()
        for (i in 1:length(nvec)) {
          p_equiv <- nvec[i] / predictionPopSize
          risk_vals_I <- round(100 * (1 - (1 - p_equiv)**sizevec), 2)
          risk_vals_list[[i]] <- data.frame("nvec" = nvec[i], "svec" = sizevec, "risk" = risk_vals_I)
        }

        pcrit.df <- do.call(rbind.data.frame, pcrit_risk_list)
        pcrit_lab.df <- do.call(rbind.data.frame, pcrit_lab_list)
        risk.df <- do.call(rbind.data.frame, risk_vals_list) %>%
          dplyr::mutate(risk = dplyr::case_when(
            risk > 99 ~ ">99",
            risk <= 0.1 ~ "<0.1",
            TRUE ~ as.character(risk)
          ))

        shiny::validate(
          need(is.numeric(event_size), "Event size must be a number"),
          need(event_size >= 5, "Event size must be >=5"),
          need(event_size <= 100000, "Event size must be <= 100,000")
        )
        dd_plot <<- ggplot2::ggplot() +
          ggplot2::geom_area(data = pcrit_risk_list[[1]], ggplot2::aes(x = x, y = y), alpha = .5) +
          ggplot2::geom_hline(yintercept = risk.df$nvec, linetype = 2) +
          ggplot2::geom_path(data = pcrit.df, ggplot2::aes(x = x, y = y, group = risk, color = as.factor(risk * 100)), size = 1) +
          ggplot2::scale_color_manual(values = c("black", "#fcae91", "#fb6a4a", "#de2d26", "#a50f15")) +
          ggplot2::geom_label(data = risk.df, ggplot2::aes(x = svec, y = nvec, label = paste(risk, "% Chance")), nudge_y = .1, size = 5, fill = "blue", alpha = .5, color = "white") +
          ggplot2::geom_vline(xintercept = event_size, linetype = 3) +
          ggplot2::geom_point(ggplot2::aes(x = event_size, y = nvec), size = 4.5, shape = c(16, 17, 15), color = "red") +
          ggplot2::geom_point(data = risk.df, ggplot2::aes(x = svec, y = nvec), size = 3) +
          ggthemes::theme_clean() +
          ggplot2::scale_x_continuous(name = "Number of people at event", breaks = xblock, labels = names(xblock), trans = "log10", expand = c(.1, .1), ) +
          ggplot2::scale_y_continuous(name = paste0("Number of circulating cases in ", states_dd), breaks = yblock, labels = names(yblock), trans = "log10", expand = c(.1, .1)) +
          ggplot2::annotation_logticks(scaled = T) +
          ggplot2::coord_cartesian(ylim = ylimits, xlim = c(10, 100001)) +
          ggplot2::theme(
            axis.title.x = ggplot2::element_text(size = 20),
            axis.text = ggplot2::element_text(size = 16),
            axis.title.y = ggplot2::element_text(size = 20),
            plot.caption = ggplot2::element_text(hjust = 0, face = "italic"),
            plot.caption.position = "plot",
            plot.title = ggplot2::element_text(hjust = 0.5, size = 20),
            plot.subtitle = ggplot2::element_text(hjust = 0.5)
          ) +
          ggplot2::guides(color = ggplot2::guide_legend(title = "% Chance"), override.aes = list(size = 2)) +
          ggplot2::labs(
            caption = paste0("© CC-BY-4.0\tChande, A.T., Gussler, W., Harris, M., Lee, S., Rishishwar, L., Jordan, I.K., Andris, C.M., and Weitz, J.S. 'Interactive COVID-19 Event Risk Assessment Planning Tool'\nhttp://covid19risk.biosci.gatech.edu\nData updated on and risk estimates made:  ", lubridate::today(), "\nReal-time COVID19 data comes from the COVID Tracking Project: https://covidtracking.com/api/\nUS 2019 population estimate data comes from the US Census: https://www.census.gov/data/tables/time-series/demo/popest/2010s-state-total.html"),
            title = paste0("COVID-19 Event Risk Assessment Planner - ", states_dd, " - ", lubridate::today()),
            subtitle = "Estimated chance that one or more individuals are COVID-19 positive at an event\ngiven event size (x-axis) and current case prevalence (y-axis)"
          )
        dd_plot
      })
    })

    output$dl_dd <- downloadHandler(
      filename = function() {
        paste("Predicted-risk-", input$states_dd, "-Event_size-", input$event_dd, "-", lubridate::today(), ".png", sep = "")
      },
      content = function(file) {
        ggplot2::ggsave(file, plot = dd_plot, width = 12, height = 12, units = "in")
      }
    )
  })
}

## To be copied in the UI
# mod_usa_real_time_ui("usa_real_time_ui_1")

## To be copied in the server
# mod_usa_real_time_server("usa_real_time_ui_1")
