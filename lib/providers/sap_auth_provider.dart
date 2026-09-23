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

  Future<void> init() async {
    _config = await SapConfig.load();
    notifyListeners();
  }

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
