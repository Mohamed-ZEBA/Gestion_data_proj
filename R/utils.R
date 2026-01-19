# R/utils.R

# ===============================
# Modele discret avec interaction (competition)
# Ni(t_n) = Ni(t_{n-1}) * ( 1 + r * ( 1 - (Ni(t_{n-1}) + alpha * Nj(t_{n-1})) / K ) )
# ===============================

simulate_population_interaction <- function(
    Ni0,
    Nj0 = 80,
    r = 0.5,
    K = 1000,
    alpha = 0.2,
    T = 100,
    mode_Nj = c("constant", "cos"),
    Kj = 1000
) {
  Ni0 <- as.numeric(Ni0)
  Nj0 <- as.numeric(Nj0)
  r <- as.numeric(r)
  K <- as.numeric(K)
  alpha <- as.numeric(alpha)
  T <- as.integer(T)
  Kj <- as.numeric(Kj)
  
  mode_Nj <- match.arg(mode_Nj)
  
  if (!is.finite(Ni0) || Ni0 < 0) stop("Ni0 doit etre >= 0.")
  if (!is.finite(r) || r < 0 || r > 1) stop("r doit etre dans [0,1].")
  if (!is.finite(K) || K <= 0) stop("K doit etre > 0.")
  if (!is.finite(alpha) || alpha < 0) stop("alpha doit etre >= 0.")
  if (!is.finite(T) || T < 1) stop("T doit etre >= 1.")
  
  t <- 0:T
  Ni <- numeric(length(t))
  Nj <- numeric(length(t))
  
  Ni[1] <- Ni0
  
  # Nj(t)
  if (mode_Nj == "constant") {
    if (!is.finite(Nj0) || Nj0 < 0) stop("Nj0 doit etre >= 0.")
    Nj <- rep(Nj0, length(t))
  } else if (mode_Nj == "cos") {
    if (!is.finite(Kj) || Kj <= 0) stop("Kj doit etre > 0.")
    # Nj(t) = Kj * cos(t), et on tronque a 0 pour eviter des tailles negatives
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
    taux_de_competition = alpha,
    mode_Nj = mode_Nj,
    Kj = Kj
  )
}


# ===============================
# Stockage CSV (base de donnees fichier)
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
  h <- read_history()
  if (nrow(h) == 0) return(NULL)
  h[nrow(h), ]
}
