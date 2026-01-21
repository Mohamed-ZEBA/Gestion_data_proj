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

L’ensemble de l’application (API, calcul automatique et monitoring) est entièrement **conteneurisé avec Docker**, garantissant la reproductibilité de l’environnement d’exécution.


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
│   │   └── run_monitor.R     # Lancement du monitoring (dans Docker)
│   └── srv/
│       ├── service_pop.R     # API REST (plumber)
│       └── run_api.R         # Lancement de l’API
│
├── storage/                  # Volume Docker (CSV persisté)
├── Dockerfile                # Image Docker unique (API + Shiny + updater)
├── start.sh                  # Script de démarrage du conteneur
├── README.md
└── .gitignore
```
---


## Prérequis

- **Docker ≥ 20.x**
- **Docker Desktop** (Windows / macOS / Linux)

Aucune installation locale de R ou de packages n’est requise.

##  Exécution du projet


### 1. Déploiement avec Docker 

L’ensemble de l’application (API REST, calcul automatique et monitoring Shiny)
est déployé dans **un conteneur Docker unique**.

#### Construction de l’image (à effectuer une seule fois ou après modification du code)

```bash
docker build -t troll-pop .
```
#### Lancement du conteneur
```bash
docker run -d \
  --name troll-pop-app \
  -p 16030:16030 \
  -p 16031:16031 \
  -v "$(pwd -W)/storage:/app/storage" \
  troll-pop
```


- Documentation Swagger : http://localhost:16030/__docs__/

- Monitoring Shiny : http://localhost:16031

Les données sont mises à jour automatiquement toutes les 5 secondes.



### 2. Gestion du conteneur

```bash
# Arrêter l’application
docker stop troll-pop-app

# Redémarrer le conteneur existant
docker start troll-pop-app

# Afficher les logs (API, calcul et Shiny)
docker logs -f troll-pop-app
``` 

### 3. Reconstruction complète (si nécessaire)

En cas de modification du code R ou du Dockerfile :

```bash
docker stop troll-pop-app
docker rm troll-pop-app
docker build -t troll-pop .
docker run -d \
  --name troll-pop-app \
  -p 16030:16030 \
  -p 16031:16031 \
  -v "$(pwd -W)/storage:/app/storage" \
  troll-pop
``` 

---
## Monitoring (Shiny)

L’application Shiny est exécutée **dans le conteneur Docker**.

Elle est accessible via un navigateur web :

http://localhost:16031

Le monitoring lit directement les données stockées dans le volume Docker (storage/history.csv).

---
## Test de l’API

Simulation ponctuelle via l’API REST :
```bash
curl -X POST "http://localhost:16030/simulate?Ni0=50&Nj0=80&alpha=0.3&T=1"
```
