# Modélisation des populations 

**Groupe D – Troll | SEP092 – Écosystèmes des données massives**

---

## Présentation générale

Ce projet implémente une application **R** simulant l’évolution d’une population (**Troll**) en interaction compétitive avec une autre espèce (**Orc**), selon un **modèle discret de type Lotka–Volterra**.

L’application fournit :
- un modèle mathématique de dynamique des populations,
- une API REST sécurisée (package `plumber`),
- une base de données fichier (CSV) mise à jour automatiquement toutes les 5 secondes,
- un monitoring graphique de l’évolution de la population.

Projet réalisé dans le cadre du cours :  
**SEP092 – Écosystèmes des données massives – Sécurisation des procédés**  
Université de Reims Champagne-Ardenne.

---

## Modèle mathématique

La population étudiée est la population **Troll** (groupe D), en interaction avec la population **Orc**.

Le modèle discret utilisé est :

\[
N_i(t+1) = N_i(t) \left[ 1 + r \left( 1 - \frac{N_i(t) + \alpha N_j(t)}{K} \right) \right]
\]

avec :
- \(N_i(t)\) : taille de la population Troll  
- \(N_j(t)\) : taille de la population Orc (population compétitrice)  
- \(r\) : taux de croissance  
- \(K\) : capacité biotique  
- \(\alpha\) : taux de compétition  

Pour les tests, la population compétitrice est simulée par :
\[
N_j(t) = K_j \cos(t)
\]

Le modèle est utilisé avec un **pas de temps discret unitaire** (\(t = 0, 1\)) à chaque mise à jour.

---

## Structure du projet

```text
gestion_data_proj/
├── R/
│   ├── utils.R               # Modèle + fonctions de stockage CSV
│   ├── update_every_5s.R     # Mise à jour automatique toutes les 5 secondes
│   ├── monitor/
│   │   ├── app.R             # Application Shiny (monitoring)
│   │   └── run_monitor.R     # Lancement du monitoring
│   └── srv/
│       ├── service_pop.R     # API REST (plumber)
│       └── run_api.R         # Lancement de l’API
│
├── storage/                  # Base de données fichier (CSV, non versionnée)
├── gestion_data_proj.Rproj
├── README.md
└── .gitignore
```



##  Prérequis

- **R ≥ 4.2**
- Packages R nécessaires :
  - `plumber`
  - `here`

Installation des dépendances :

```bash
Rscript -e 'install.packages(c("plumber","here","shiny","ggplot2"), repos="https://cloud.r-project.org")'
```
##  Exécution du projet

### 1️ Création du dossier de stockage

```bash
mkdir -p storage
```

### 2. Authentification (token)

L’API est protégée par un token HTTP.

Lancer l’API avec un token :

```bash
export API_TOKEN=devtoken
Rscript R/srv/run_api.R 
``` 

Tester l’accès à l’API :

```bash
curl -H "Authorization: Bearer devtoken" \
     http://127.0.0.1:16030/status
```


### 3️ Lancement de la mise à jour automatique

Lancement du calcul et du stockage toutes les 5 secondes : 


```bash
Rscript R/update_every_5s.R
``` 

### 4. Monitoring (Shiny)

Lancer l’application de monitoring :

```bash
Rscript R/monitor/run_monitor.R
``` 

### 5. Test de l’API 

Simulation ponctuelle via l’API : 

```bash
curl -X POST "http://127.0.0.1:16030/simulate?Ni0=50&Nj0=80&alpha=0.3&T=1" \
  -H "Authorization: Bearer devtoken"
```
