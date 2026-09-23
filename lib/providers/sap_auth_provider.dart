import 'package:flutter/material.dart';
import '../core/sap_config.dart';
import '../core/sap_session_manager.dart';
import '../services/sap_service_layer_client.dart';

/// ============================================================================
/// PROVIDER : SapAuthProvider
/// OBJECTIF PÉDAGOGIQUE :
/// Gère l'état d'authentification et les paramètres de connexion SAP.
/// ============================================================================
class SapAuthProvider with ChangeNotifier {
  final SapServiceLayerClient _client = SapServiceLayerClient();
  final SapSessionManager _sessionManager = SapSessionManager();

  SapConfig _config = SapConfig(
    serverUrl: SapConfig.defaultServerUrl,
    companyDb: SapConfig.defaultCompanyDb,
    username: SapConfig.defaultUsername,
    password: SapConfig.defaultPassword,
  );

  bool _isLoading = false;
  String? _errorMessage;
  int? _lastLoginDurationMs;

  SapConfig get config => _config;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get lastLoginDurationMs => _lastLoginDurationMs;
  bool get isAuthenticated => _sessionManager.isAuthenticated;
  String? get sessionId => _sessionManager.sessionId;
  String? get companyDb => _sessionManager.companyDb;
  String? get username => _sessionManager.username;
  Duration get remainingSessionTime => _sessionManager.remainingTime;

  // Appelé avant runApp pour que les paramètres enregistrés soient déjà
  // disponibles quand l'écran de connexion est construit. notifyListeners()
  // permet ensuite de rendre ces valeurs visibles dans les widgets qui
  // utilisent context.watch<SapAuthProvider>().
  Future<void> init() async {
    _config = await SapConfig.load();
    notifyListeners();
  }

  // Le provider est le propriétaire de l'état modifiable de la connexion.
  // L'écran de login envoie simplement les valeurs ici, sans se soucier de la
  // manière dont elles sont stockées ou sauvegardées.
  void updateConfig({
    String? serverUrl,
    String? companyDb,
    String? username,
    String? password,
  }) {
    if (serverUrl != null) _config.serverUrl = serverUrl;
    if (companyDb != null) _config.companyDb = companyDb;
    if (username != null) _config.username = username;
    if (password != null) _config.password = password;
    notifyListeners();
  }

  Future<bool> login() async {
    // Le chargement et les erreurs sont aussi des états. En publiant cette
    // première mise à jour, l'interface peut désactiver le formulaire et
    // afficher une progression pendant l'appel HTTP.
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _config.save();

      final result = await _client.login(
        baseUrl: _config.cleanBaseUrl,
        companyDb: _config.companyDb,
        username: _config.username,
        password: _config.password,
      );

      _lastLoginDurationMs = result['durationMs'] as int?;
      _isLoading = false;
      // SapServiceLayerClient stocke les cookies SAP dans le gestionnaire de
      // session. Le provider publie ensuite l'état authentifié au dashboard.
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _client.logout(_config.cleanBaseUrl);

    // logout() vide aussi le gestionnaire de session si SAP ne répond plus,
    // pour éviter qu'une session expirée continue d'être affichée dans l'UI.
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await _config.reset();
    _errorMessage = null;
    notifyListeners();
  }
}
