# R/update_every_5s.R
source("R/utils.R")


# Parametres fixes (groupe D)
Ni <- 50      # taille initiale Troll
Nj0 <- 80     # Orc
r <- 0.5
K <- 1000
alpha <- 0.3
Kj <- 1000    # pour Nj(t) = Kj*cos(t)
mode_Nj <- "cos"

t <- 0

cat("Mise a jour automatique toutes les 5 secondes...\n")

repeat {
  # simulation sur un seul pas de temps
  df <- simulate_population_interaction(
    Ni0 = Ni,
    Nj0 = Nj0,
    r = r,
    K = K,
    alpha = alpha,
    T = 1,
    mode_Nj = mode_Nj,
    Kj = Kj
  )
  
  # derniere valeur devient la nouvelle condition initiale
  Ni <- tail(df$taille, 1)
  
  # stockage CSV
  append_history(df, population = "Troll", competitor = "Orc")
  
  cat("t =", t, " | Troll =", Ni, "\n")
  t <- t + 1
  
  Sys.sleep(5)
}
