# R/srv/service_pop.R

# Lancer l’updater UNE FOIS au démarrage du conteneur


source("/app/R/utils.R")



# ---- Security (token) ----
# Utilise une variable d'environnement API_TOKEN
# Si vide/non definie -> pas de securite (pratique en dev)
is_authorized <- function(req) {
  token <- Sys.getenv("API_TOKEN", unset = NA)
  if (is.na(token)) {
    stop("API_TOKEN must be defined")
  }
  
  auth <- req$HTTP_AUTHORIZATION %||% ""
  identical(auth, paste("Bearer", token))
}

`%||%` <- function(a, b) if (!is.null(a) && nzchar(a)) a else b

#* @filter auth
function(req, res) {
  if (!is_authorized(req)) {
    res$status <- 401
    return(list(error = "Unauthorized"))
  }
  plumber::forward()
}
##################################################


#* @apiTitle API Population - Troll (Groupe D)
#* @apiDescription Modele discret avec interaction Troll (i) depend de Orc (j). Stockage CSV dans storage/history.csv

#* Simule une trajectoire et stocke l'historique
#* @param Ni0 taille initiale Troll
#* @param Nj0 taille initiale Orc (competiteur)
#* @param r taux de croissance (defaut 0.5)
#* @param K capacite biotique (defaut 1000)
#* @param alpha taux de competition (defaut 0.2)
#* @param T nombre de pas (defaut 100)
#* @param mode_Nj "constant" ou "cos"
#* @param Kj amplitude pour Nj(t)=Kj*cos(t)
#* @post /simulate
simulate <- function(Ni0 = 50, Nj0 = 80, r = 0.5, K = 1000, alpha = 0.2, T = 100,
                     mode_Nj = "constant", Kj = 1000) {
  
  # conversions (parametres HTTP -> numeriques)
  Ni0 <- as.numeric(Ni0)
  Nj0 <- as.numeric(Nj0)
  r <- as.numeric(r)
  K <- as.numeric(K)
  alpha <- as.numeric(alpha)
  T <- as.integer(T)
  Kj <- as.numeric(Kj)
  
  df <- simulate_population_interaction(
    Ni0 = Ni0, Nj0 = Nj0,
    r = r, K = K, alpha = alpha,
    T = T,
    mode_Nj = mode_Nj, Kj = Kj
  )
  
  # stockage CSV (base de donnees fichier)
  append_history(df, population = "Troll", competitor = "Orc")
  
  last <- df[nrow(df), ]
  
  list(
    taille = as.numeric(last$taille),
    taux_de_competition = as.numeric(alpha),
    taux_de_croissance = as.numeric(r)
  )
}

#* Renvoie le dernier etat stocke
#* @get /status
status <- function() {
  s <- last_state()
  if (is.null(s)) {
    return(list(error = "no data yet - call /simulate first"))
  }
  
  list(
    taille = as.numeric(s$taille),
    taux_de_competition = as.numeric(s$taux_de_competition),
    taux_de_croissance = as.numeric(s$taux_de_croissance)
  )
}

#* Renvoie l'historique (complet ou N dernieres lignes)
#* @param n nombre de lignes recentes a renvoyer (optionnel)
#* @get /history
history <- function(n = NA) {
  h <- read_history()
  if (nrow(h) == 0) return(h)
  
  if (!is.na(n)) {
    n <- as.integer(n)
    n <- max(1, n)
    h <- tail(h, n)
  }
  h
}
