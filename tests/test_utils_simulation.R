# tests/test_utils_simulation.R

cat("Test simulate_population_interaction...\n")

# Charger les fonctions
source("R/utils.R")

# Test 1 : structure de sortie
df <- simulate_population_interaction(
  Ni0 = 50,
  Nj0 = 80,
  r = 0.5,
  K = 1000,
  alpha = 0.2,
  T = 10,
  mode_Nj = "constant"
)

stopifnot(is.data.frame(df))
stopifnot(nrow(df) == 11)  # T + 1
stopifnot(all(c(
  "t", "taille", "population_competitrice",
  "taux_de_croissance", "capacite_biotique",
  "taux_de_competition"
) %in% names(df)))

# Test 2 : population toujours positive
stopifnot(all(df$taille >= 0))

# Test 3 : convergence vers l'équilibre théorique (cas simple)
df_long <- simulate_population_interaction(
  Ni0 = 50,
  Nj0 = 80,
  r = 0.5,
  K = 1000,
  alpha = 0.2,
  T = 100,
  mode_Nj = "constant"
)

equilibre_theorique <- 1000 - 0.2 * 80
valeur_finale <- tail(df_long$taille, 1)

stopifnot(abs(valeur_finale - equilibre_theorique) < 5)

cat("OK : simulate_population_interaction\n")
