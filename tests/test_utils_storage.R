cat("Test des fonctions de stockage...\n")

# Charger les fonctions
source("R/utils.R")

# Créer un dossier temporaire pour les tests
tmp_dir <- tempdir()
tmp_file <- file.path(tmp_dir, "history.csv")

# Redéfinir les variables globales POUR LE TEST
STORAGE_DIR  <- tmp_dir
HISTORY_FILE <- tmp_file

# Surcharger les fonctions qui utilisent /app/storage
ensure_storage <- function() {
  dir.create(tmp_dir, showWarnings = FALSE, recursive = TRUE)
}

append_history <- function(df, population = "Troll", competitor = "Orc") {
  ensure_storage()
  
  out <- transform(
    df,
    population = population,
    competitor = competitor,
    timestamp = as.character(Sys.time())
  )
  
  if (!file.exists(tmp_file)) {
    write.csv(out, tmp_file, row.names = FALSE)
  } else {
    write.table(out, tmp_file, sep = ",",
                row.names = FALSE,
                col.names = FALSE,
                append = TRUE)
  }
}

read_history <- function() {
  if (!file.exists(tmp_file)) return(data.frame())
  read.csv(tmp_file)
}

last_state <- function() {
  if (!file.exists(tmp_file)) return(NULL)
  h <- read.csv(tmp_file)
  if (nrow(h) == 0) return(NULL)
  h[nrow(h), ]
}

# ---- Test ----

df <- simulate_population_interaction(Ni0 = 50, T = 2)
append_history(df)

h <- read_history()
stopifnot(nrow(h) > 0)

s <- last_state()
stopifnot(!is.null(s))

cat("OK : fonctions de stockage\n")
