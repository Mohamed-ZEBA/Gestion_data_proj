#R/monitor/app.R
library(shiny)
library(ggplot2)

# Chemin ABSOLU dans Docker
history_file <- "/app/storage/history.csv"

# Charger les fonctions utilitaires
# app.R est exécuté depuis /app/R/monitor
source("../utils.R")

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
      helpText("Données : /app/storage/history.csv"),
      helpText("Actualisation automatique toutes les 5 secondes")
    ),
    
    mainPanel(
      plotOutput("popPlot", height = 350),
      hr(),
      tableOutput("lastRows")
    )
  )
)

server <- function(input, output, session) {
  
  data_reactive <- reactiveFileReader(
    intervalMillis = 5000,
    session = session,
    filePath = history_file,
    readFunc = function(path) {
      if (!file.exists(path)) return(data.frame())
      
      h <- read.csv(path)
      if (nrow(h) == 0) return(h)
      
      h$time_global <- seq_len(nrow(h))
      h
    }
  )
  
  output$popPlot <- renderPlot({
    h <- data_reactive()
    validate(need(nrow(h) > 0, "Aucune donnée disponible"))
    
    n <- max(1, as.integer(input$n))
    h <- tail(h, n)
    
    K <- unique(h$capacite_biotique)[1]
    
    ggplot(h, aes(x = time_global, y = taille)) +
      geom_line(color = "steelblue", linewidth = 1) +
      geom_point(color = "steelblue", size = 1) +
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
