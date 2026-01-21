# R/utils.R

STORAGE_DIR  <- "/app/storage"
HISTORY_FILE <- file.path(STORAGE_DIR, "history.csv")

# ===============================
# Modèle discret avec interaction
# ===============================

simulate_population_interaction <- function(
    Ni0,
    Nj0 = 80,
    r = 0.5,
    K = 1000,
    alpha = 0.2,
    T = 1,
    mode_Nj = c("constant", "cos"),
    Kj = 1000
) {
  mode_Nj <- match.arg(mode_Nj)
  
  t  <- 0:T
  Ni <- numeric(length(t))
  Nj <- numeric(length(t))
  
  Ni[1] <- Ni0
  
  if (mode_Nj == "constant") {
    Nj <- rep(Nj0, length(t))
  } else {
    Nj <- pmax(0, Kj * cos(t))
  }
  
  for (k in 2:length(t)) {
    Ni[k] <- Ni[k - 1] * (1 + r * (1 - (Ni[k - 1] + alpha * Nj[k - 1]) / K))
    Ni[k] <- max(0, Ni[k])
  }
  
  data.frame(
    t = t,
    taille = Ni,
    population_competitrice = Nj,
    taux_de_croissance = r,
    capacite_biotique = K,
    taux_de_competition = alpha
  )
}

# ===============================
# Stockage CSV
# ===============================

ensure_storage <- function() {
  dir.create("/app/storage", showWarnings = FALSE, recursive = TRUE)
}

append_history <- function(df, population = "Troll", competitor = "Orc") {
  ensure_storage()
  
  out <- transform(
    df,
    population = population,
    competitor = competitor,
    timestamp = as.character(Sys.time())
  )
  
  file <- "/app/storage/history.csv"
  
  if (!file.exists(file)) {
    write.csv(out, file, row.names = FALSE)
  } else {
    write.table(out, file, sep = ",",
                row.names = FALSE,
                col.names = FALSE,
                append = TRUE)
  }
}

read_history <- function() {
  file <- "/app/storage/history.csv"
  if (!file.exists(file)) return(data.frame())
  read.csv(file)
}

last_state <- function() {
  file <- "/app/storage/history.csv"
  if (!file.exists(file)) return(NULL)
  
  h <- read.csv(file)
  if (nrow(h) == 0) return(NULL)
  
  h[nrow(h), ]
}
