import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================================
/// CLASSE : SapConfig
/// OBJECTIF PÉDAGOGIQUE :
/// Cette classe gère le stockage et la persistance locale des paramètres
/// de connexion au Service Layer SAP Business One :
///  - URL du Service Layer (ex: https://ip:50000/b1s/v1)
///  - Nom de la base de données SAP (CompanyDB, ex: GROUPE_PRODUCTION)
///  - Identifiant utilisateur SAP (UserName)
///  - Mot de passe (Password)
///
/// L'utilisation de `SharedPreferences` permet à l'utilisateur de ne pas
/// retaper ses identifiants à chaque redémarrage de l'application de démo.
/// ============================================================================
class SapConfig {
  static const String _keyServerUrl = 'sap_demo_server_url';
  static const String _keyCompanyDb = 'sap_demo_company_db';
  static const String _keyUsername = 'sap_demo_username';
  static const String _keyPassword = 'sap_demo_password';

  static const String defaultServerUrl = 'https://ip:50000/b1s/v1';
  static const String defaultCompanyDb = '';
  static const String defaultUsername = '';
  static const String defaultPassword = '';

  String serverUrl;
  String companyDb;
  String username;
  String password;

  SapConfig({
    required this.serverUrl,
    required this.companyDb,
    required this.username,
    required this.password,
  });

  String get cleanBaseUrl {
    String url = serverUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static Future<SapConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SapConfig(
      serverUrl: prefs.getString(_keyServerUrl) ?? defaultServerUrl,
      companyDb: prefs.getString(_keyCompanyDb) ?? defaultCompanyDb,
      username: prefs.getString(_keyUsername) ?? defaultUsername,
      password: prefs.getString(_keyPassword) ?? defaultPassword,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerUrl, serverUrl.trim());
    await prefs.setString(_keyCompanyDb, companyDb.trim());
    await prefs.setString(_keyUsername, username.trim());
    await prefs.setString(_keyPassword, password);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyServerUrl);
    await prefs.remove(_keyCompanyDb);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyPassword);
    serverUrl = defaultServerUrl;
    companyDb = defaultCompanyDb;
    username = defaultUsername;
    password = defaultPassword;
  }
}
