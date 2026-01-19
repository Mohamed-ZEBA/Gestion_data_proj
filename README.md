# 📊 Modelisation des populations (une espèse)
  
**Groupe D – Troll | SEP092 – Écosystèmes des données massives**

---

## Présentation générale

Ce projet implémente une application **R** simulant l’évolution d’une population (**Troll**) en interaction compétitive avec une autre espèce (**Orc**), selon un **modèle discret de type Lotka–Volterra**.

L’application fournit :
- un **modèle mathématique** de dynamique des populations,
- une **API REST** interrogeable via HTTP (package `plumber`),
- une **base de données fichier (CSV)** mise à jour automatiquement toutes les **5 secondes**,
- un historique exploitable pour le **monitoring**.

Projet réalisé dans le cadre du projet :  
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
- \(N_j(t)\) : taille de la population Orc
- \(r\) : taux de croissance
- \(K\) : capacité biotique
- \(\alpha\) : taux de compétition

Pour les tests demandés dans l’énoncé, on peut utiliser :
\[
N_j(t) = K_j \cos(t)
\]



##  Structure du projet

```text
gestion_data_proj/
├── R/
│   ├── utils.R               # Modèle + fonctions de stockage CSV
│   ├── update_every_5s.R     # Mise à jour automatique toutes les 5 secondes
│   └── srv/
│       ├── service_pop.R     # API REST (plumber)
│       └── run_api.R         # Lancement de l’API
│
├── storage/                  # Base de données fichier (CSV, non versionnée)
├── gestion_data_proj.Rproj   # Projet RStudio
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
Rscript -e 'install.packages(c("plumber","here"), repos="https://cloud.r-project.org")'
```
##  Exécution du projet

### 1️ Création du dossier de stockage

```bash
mkdir -p storage
```

### 2️ Lancement de l’API REST

```bash
Rscript R/srv/run_api.R
```

### 3️ Lancement de la mise à jour automatique

```bash
Rscript R/update_every_5s.R
```

### Simulation d'une population
```bash
curl -X POST "http://127.0.0.1:16030/simulate?Ni0=50&Nj0=80&alpha=0.3&T=50"
```
