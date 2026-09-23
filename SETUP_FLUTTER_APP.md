# Guide Technique d'Intégration & Déploiement - SAP B1 Service Layer Demo

Documentation technique destinée aux ingénieurs et développeurs pour le déploiement, la configuration et la compréhension des flux de communication avec le **Service Layer de SAP Business One**.

---

## 1. Architecture & Protocoles de Communication

L'application implémente les flux standards de l'API OData / Service Layer de SAP Business One :

```
[Flutter Client] 
       │
       ├─── 1. POST /b1s/v1/Login ──────────────────────► [SAP Service Layer]
       │    (CompanyDB, UserName, Password)
       │
       │◄── 2. Response 200 OK + Set-Cookie ────────────┤
       │    (SessionId, B1SESSION=..., ROUTEID=...)
       │
       ├─── 3. GET /b1s/v1/Items?$top=20&$skip=0 ────────►
       │    (Header: Cookie: B1SESSION=...; ROUTEID=...)
       │
       │◄── 4. JSON Payload (OData Collection) ─────────┤
       │
       └─── 5. POST /b1s/v1/Logout (Session Release) ───►
```

### Spécifications d'implémentation :

- **Gestion TLS / Certificats auto-signés (`HttpOverrides`)** :
  - Sur les environnements hors production (dev, staging, sandbox), le Service Layer SAP utilise fréquemment des certificats SSL auto-signés.
  - La classe [`lib/core/sap_http_overrides.dart`](file:///c:/zalar/zrecolte/sap_b1_service_layer_demo/lib/core/sap_http_overrides.dart) implémente `badCertificateCallback` pour autoriser la négociation TLS.
- **Gestion de Session State** :
  - Persistance en mémoire via [`lib/core/sap_session_manager.dart`](file:///c:/zalar/zrecolte/sap_b1_service_layer_demo/lib/core/sap_session_manager.dart).
  - Injection automatique des cookies `B1SESSION` et `ROUTEID` dans les en-têtes HTTP de chaque requête.
  - Clôture explicite via `POST /b1s/v1/Logout` pour libérer la licence Service Layer.
- **Pagination OData & Lazy Loading** :
  - Flux paginés via les query params OData : `$top=20`, `$skip=N`, `$select=...`, `$filter=...`.
  - Écoute du seuil de défilement (200px avant le bas du viewport) pour le déclenchement non-bloquant de la page suivante.

---

## 2. Prérequis d'Environnement

- **Flutter SDK** : `>= 3.5.0`
- **Dart SDK** : `>= 3.5.0`
- **Build Tools Desktop (si target Windows)** : Visual Studio 2022 avec charge "Desktop development with C++".
- **Navigateur Chromium** (Chrome / Edge) pour l'exécution Web.
- **Connectivité Réseau** : Accès HTTPS au port Service Layer (généralement port `50000`).

---

## 3. Déploiement & Démarrage

### A. Récupération des sources

```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
cd sap_b1_service_layer_demo
```

Pour mettre à jour un dépôt existant :
```bash
git pull origin main
```

### B. Installation des dépendances

```bash
flutter pub get
```

Contrôle de l'environnement :
```bash
flutter doctor
```

### C. Exécution selon la cible

```bash
# Cible Windows Desktop native (x64)
flutter run -d windows

# Cible Web (Google Chrome)
flutter run -d chrome

# Cible Web (Microsoft Edge)
flutter run -d edge

# Cible Android (device connecté ou émulateur)
flutter run
```

---

## 4. Paramètres de Connexion SAP B1

Renseigner les coordonnées du serveur Service Layer sur l'écran d'authentification :

| Paramètre | Format attendu | Exemple |
|---|---|---|
| **Service Layer URL** | `https://<HOST>:<PORT>/b1s/v1` | `https://192.168.10.41:50000/b1s/v1` |
| **Base (CompanyDB)** | Nom exact du schéma SAP | `GROUPE_PRODUCTION` |
| **Utilisateur (UserName)** | Utilisateur SAP B1 habilité | `manager` |
| **Mot de passe** | Mot de passe du compte SAP | `********` |

> *Note : Les paramètres sont enregistrés localement via `SharedPreferences` pour éviter les ressaisies.*

---

## 5. Structure Technique du Code Source

```text
lib/
├── main.dart                      # Bootstrap de l'application, bypass SSL, providers racine
├── core/
│   ├── sap_http_overrides.dart    # Implémentation HttpOverrides (TLS custom)
│   ├── sap_config.dart            # Gestionnaire de configuration & SharedPreferences
│   └── sap_session_manager.dart   # Singleton de gestion des sessions et cookies HTTP
├── models/
│   ├── sap_item_model.dart        # DTO Article (Items + UDFs)
│   ├── sap_client_model.dart      # DTO BusinessPartners & sous-adresses (BPAddresses)
│   └── sap_page_response.dart     # Wrapper générique de réponse paginée OData
├── services/
│   └── sap_service_layer_client.dart # Client HTTP Service Layer (Login, Logout, Items, BusinessPartners)
├── providers/
│   ├── sap_auth_provider.dart     # State Management Authentification & session
│   ├── sap_items_provider.dart    # State Management Items & flux de pagination
│   └── sap_clients_provider.dart  # State Management BusinessPartners & flux de pagination
└── ui/
    ├── screens/                   # Vues principales (Login, Dashboard, Items, Clients)
    └── widgets/                   # Composants visuels, inspecteur OData et inspecteur JSON brut
```
