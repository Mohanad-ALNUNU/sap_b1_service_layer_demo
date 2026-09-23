# 🎓 SAP Business One Service Layer - Démo Éducative Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.5%2B-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5%2B-blue.svg)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Pattern-Clean_Architecture_%2B_Provider-green.svg)]()
[![SAP B1](https://img.shields.io/badge/SAP_B1-Service_Layer_OData-orange.svg)]()

Application de démonstration et support pédagogique démontrant **les meilleures pratiques** pour connecter une application mobile Flutter à l'API **Service Layer de SAP Business One** (protocole standard OData).

---

## 🌟 Fonctionnalités Incluses

- 🛡️ **Bypass du Certificat SSL/TLS (`HttpOverrides`)** : Permet la communication avec les serveurs de test/formation SAP utilisant des certificats auto-signés.
- 🔐 **Authentification & Session SAP (`/b1s/v1/Login`)** : Gestion des cookies de session `B1SESSION` et `ROUTEID` pour maintenir l'état d'authentification.
- 📦 **Consultation des Articles (`Items`)** : Pagination OData (`$top`, `$skip`), recherche dynamique (`$filter=contains(...)`) et défilement infini (*infinite scroll*).
- 👥 **Consultation des Clients (`BusinessPartners`)** : Filtrage sur `CardType eq 'cCustomer'`, affichage des adresses de livraison (`BPAddresses`).
- 💡 **Inspecteur OData Éducatif** : Bannières interactives affichant les URLs exactes envoyées à SAP et boîtes de dialogue affichant le JSON brut.
- 💾 **Persistance des paramètres** : Mémorisation locale de l'URL du Service Layer, du CompanyDB et des identifiants via `SharedPreferences`.

---

## 🚀 Démarrage Rapide

### 1. Cloner ou ouvrir le projet

```bash
cd sap_b1_service_layer_demo
```

### 2. Récupérer les dépendances

```bash
flutter pub get
```

### 3. Lancer l'application

```bash
flutter run
```

---

## 📤 Comment Pousser cette Application sur GitHub / GitLab

Pour publier cette application comme un **dépôt Git indépendant** afin que d'autres personnes puissent apprendre :

```bash
# 1. Se positionner dans le dossier de l'application
cd sap_b1_service_layer_demo

# 2. Initialiser un nouveau dépôt Git
git init

# 3. Ajouter tous les fichiers
git add .

# 4. Effectuer le premier commit
git commit -m "feat: initial commit - SAP Business One Service Layer Flutter demo"

# 5. Lier votre dépôt distant (remplacez par votre URL de repo GitHub/GitLab)
git branch -M main
git remote add origin https://github.com/VOTRE_COMPTE/sap_b1_service_layer_demo.git

# 6. Pousser vers GitHub
git push -u origin main
```

---

## 🧠 Principes Clés Expliqués

### 1. Contournement du Certificat SSL Auto-Signé
Sur les serveurs internes SAP B1, les certificats SSL sont fréquemment auto-signés. Dart rejetant ces connexions par défaut (`CERTIFICATE_VERIFY_FAILED`), nous surchargeons `HttpOverrides` :

```dart
class SapHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```

Activé au point d'entrée `lib/main.dart` :
```dart
HttpOverrides.global = SapHttpOverrides();
```

---

### 2. Authentification et Cycle de Session SAP

1. **Login** : `POST /b1s/v1/Login`
   ```json
   {
     "CompanyDB": "CompanyDB",
     "UserName": "UserName",
     "Password": "..."
   }
   ```
2. **Extraction des Cookies** : SAP retourne un en-tête `Set-Cookie` contenant `B1SESSION` et `ROUTEID`.
3. **Requêtes suivantes** : Injection obligatoire de `Cookie: B1SESSION=...; ROUTEID=...`.
4. **Logout** : `POST /b1s/v1/Logout` pour libérer la licence SAP Service Layer.

---

### 3. Pagination OData et Infinite Scroll

Pour éviter de surcharger la bande passante mobile, nous découpons les données en pages de 20 éléments :

- `$top=20` : Nombre d'enregistrements demandés.
- `$skip=0`, `$skip=20`, `$skip=40`... : Décalage de la page.
- `$select=...` : Récupération des colonnes strictement nécessaires.
- `$filter=...` : Filtrage côté serveur SAP (recherche textuelle).

Lors du défilement, le `ScrollController` déclenche la page suivante :
```dart
if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
  provider.fetchNextPage(baseUrl);
}
```

---

## 📁 Structure du Projet

```text
sap_b1_service_layer_demo/
├── pubspec.yaml                   # Dépendances Flutter
├── analysis_options.yaml          # Règles de linting Dart
├── .gitignore                     # Fichiers ignorés par Git
├── README.md                      # Documentation du projet
└── lib/
    ├── main.dart                  # Point d'entrée de l'application
    ├── core/
    │   ├── sap_http_overrides.dart   # Bypass SSL
    │   ├── sap_config.dart           # Configuration & SharedPreferences
    │   └── sap_session_manager.dart  # Gestionnaire de cookies et session
    ├── models/
    │   ├── sap_item_model.dart       # Modèle Article (Items)
    │   ├── sap_client_model.dart     # Modèle Client (BusinessPartners)
    │   └── sap_page_response.dart    # Enveloppe générique de pagination OData
    ├── services/
    │   └── sap_service_layer_client.dart # Client HTTP Service Layer complet
    ├── providers/
    │   ├── sap_auth_provider.dart    # Provider Authentification
    │   ├── sap_items_provider.dart   # Provider Articles + Infinite Scroll
    │   └── sap_clients_provider.dart # Provider Clients + Infinite Scroll
    └── ui/
        ├── screens/
        │   ├── sap_login_screen.dart     # Formulaire de configuration & connexion
        │   ├── sap_dashboard_screen.dart # Hub de sélection des entités
        │   ├── sap_items_screen.dart     # Liste paginée des articles
        │   └── sap_clients_screen.dart   # Liste paginée des clients
        └── widgets/
            ├── educational_info_banner.dart # Affiche l'URL OData en direct
            ├── item_card_widget.dart        # Carte d'article avec modal JSON
            └── client_card_widget.dart      # Carte de client avec adresses
```

---

## 📝 Licence & Contribution
Projet libre à des fins éducatives et de partage de connaissances.
