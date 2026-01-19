# R/monitor/app.R
library(shiny)
library(ggplot2)
library(here)

source(here::here("R", "utils.R"))

ui <- fluidPage(
  titlePanel("Monitoring - Population Troll (Groupe D)"),
  sidebarLayout(
    sidebarPanel(
      numericInput(
        "n",
        "Nombre de points affichés (dernières itérations)",
        value = 200,
        min = 10,
        step = 10
      ),
      checkboxInput(
        "auto",
        "Auto-refresh (toutes les 5 secondes)",
        value = TRUE
      ),
      helpText("Les données proviennent de storage/history.csv")
    ),
    mainPanel(
      plotOutput("popPlot", height = 350),
      hr(),
      tableOutput("lastRows")
    )
  )
)

server <- function(input, output, session) {
  
  data_reactive <- reactive({
    if (isTRUE(input$auto)) {
      invalidateLater(5000, session)
    }
    
    h <- read_history()
    if (nrow(h) == 0) return(h)
    
    # Temps global = ordre d'enregistrement
    h$time_global <- seq_len(nrow(h))
    
    n <- max(1, as.integer(input$n))
    tail(h, n)
  })
  
  output$popPlot <- renderPlot({
    h <- data_reactive()
    validate(need(nrow(h) > 0, "Aucune donnée disponible"))
    
    K <- unique(h$capacite_biotique)[1]
    
    ggplot(h, aes(x = time_global, y = taille)) +
      geom_line(color = "steelblue") +
      geom_point(size = 1, color = "steelblue") +
      scale_y_continuous(limits = c(0, K)) +
      labs(
        x = "Temps (itérations)",
        y = "Taille de la population Troll (Ni)",
        title = "Évolution de la population Troll"
      ) +
      theme_minimal()
  })
  
  output$lastRows <- renderTable({
    h <- data_reactive()
    if (nrow(h) == 0) return(h)
    
    h_affiche <- h[, c(
      "time_global",
      "taille",
      "population_competitrice",
      "taux_de_croissance",
      "taux_de_competition",
      "timestamp"
    )]
    
    tail(h_affiche, 10)
  })
}

shinyApp(ui, server)
