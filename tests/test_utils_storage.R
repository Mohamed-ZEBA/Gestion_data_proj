# tests/test_utils_storage.R

cat("Test des fonctions de stockage...\n")

# Charger les fonctions
source("R/utils.R")

# Nettoyage préalable
if (dir.exists("/app/storage")) {
  unlink("/app/storage", recursive = TRUE)
}

# Création de données factices
df <- simulate_population_interaction(
  Ni0 = 10,
  Nj0 = 5,
  r = 0.5,
  K = 100,
  alpha = 0.1,
  T = 2,
  mode_Nj = "constant"
)

# Test append_history
append_history(df, population = "TestPop", competitor = "TestComp")

stopifnot(file.exists("/app/storage/history.csv"))

# Test read_history
h <- read_history()
stopifnot(is.data.frame(h))
stopifnot(nrow(h) == nrow(df))

# Test last_state
s <- last_state()
stopifnot(!is.null(s))
stopifnot(s$population == "TestPop")
stopifnot(s$competitor == "TestComp")

cat("OK : fonctions de stockage\n")
