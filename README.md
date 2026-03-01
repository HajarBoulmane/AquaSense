# 💧 AquaSense - IoT Smart Water Monitoring

[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**AquaSense** est une solution intelligente conçue pour aider les communautés rurales à gérer durablement leurs ressources en eau. Grâce à l'intégration de capteurs IoT et d'une application mobile, nous permettons un suivi en temps réel et une prédiction des pénuries.

## 🌟 Fonctionnalités
- **Dashboard Temps Réel :** Visualisation précise des niveaux d'eau via des graphiques.
- **Alertes Intelligentes :** Notifications instantanées en cas de seuil critique.
- **Prédictions IA :** Analyse des données météo pour anticiper les périodes sèches.
- **Architecture Propre :** Code structuré pour une scalabilité maximale.

## 🏗️ Structure du Projet
```text
lib/
├── models/      # Modèles de données (water_model.dart)
├── screens/     # Interface utilisateur (Dashboard, Alerts, Stats)
├── services/    # Logique métier et API (Firebase, IoT)
└── main.dart    # Point d'entrée de l'application