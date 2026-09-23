import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/sap_session_manager.dart';
import '../models/sap_item_model.dart';
import '../models/sap_client_model.dart';
import '../models/sap_page_response.dart';

/// ============================================================================
/// SERVICE : SapServiceLayerClient
/// OBJECTIF PÉDAGOGIQUE :
/// Client HTTP central dialoguant avec l'API SAP Business One Service Layer.
/// ============================================================================
class SapServiceLayerClient {
  final SapSessionManager _sessionManager = SapSessionManager();

  /// ==========================================================================
  /// 1. AUTHENTIFICATION : Connexion au Service Layer (Login)
  /// ==========================================================================
  Future<Map<String, dynamic>> login({
    required String baseUrl,
    required String companyDb,
    required String username,
    required String password,
  }) async {
    final cleanUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$cleanUrl/Login');

    final body = jsonEncode({
      'CompanyDB': companyDb.trim(),
      'UserName': username.trim(),
      'Password': password,
    });

    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 20));

      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final setCookie = response.headers['set-cookie'];
        final sessionId = data['SessionId']?.toString() ?? '';
        final sessionTimeout = (data['SessionTimeout'] as num?)?.toInt() ?? 30;

        _sessionManager.startSession(
          sessionId: sessionId,
          cookieHeader: setCookie,
          timeoutMinutes: sessionTimeout,
          companyDb: companyDb,
          username: username,
        );

        return {
          'success': true,
          'sessionId': sessionId,
          'sessionTimeout': sessionTimeout,
          'durationMs': stopwatch.elapsedMilliseconds,
          'setCookie': setCookie,
        };
      } else {
        final errorMsg = _extractSapErrorMessage(response.body, response.statusCode);
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erreur réseau lors de la connexion à SAP : $e');
    }
  }

  /// ==========================================================================
  /// 2. DÉCONNEXION : Clôture de la session SAP (Logout)
  /// ==========================================================================
  Future<void> logout(String baseUrl) async {
    if (!_sessionManager.isAuthenticated) {
      _sessionManager.clearSession();
      return;
    }

    final cleanUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$cleanUrl/Logout');

    try {
      final headers = _sessionManager.getRequestHeaders();
      await http.post(uri, headers: headers).timeout(const Duration(seconds: 10));
    } catch (_) {
    } finally {
      _sessionManager.clearSession();
    }
  }

  /// ==========================================================================
  /// 3. RÉCUPÉRATION DES ARTICLES (Items) AVEC PAGINATION ODATA
  /// ==========================================================================
  Future<SapPageResponse<SapItem>> fetchItems({
    required String baseUrl,
    int skip = 0,
    int top = 20,
    String? searchQuery,
  }) async {
    final cleanUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    const selectFields =
        'ItemCode,ItemName,ForeignName,InventoryUOM,InventoryWeight,ItemType,Valid,U_FAMILLE,U_VARIETE,U_CALIBRE,U_MARQUE';

    String filterClause = '';
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final cleanQuery = searchQuery.trim().replaceAll("'", "''");
      filterClause = "&\$filter=contains(ItemCode,'$cleanQuery') or contains(ItemName,'$cleanQuery')";
    }

    final queryParams =
        '\$select=$selectFields&\$top=$top&\$skip=$skip$filterClause';
    final fullUrlString = '$cleanUrl/Items?$queryParams';
    final uri = Uri.parse(fullUrlString);

    final stopwatch = Stopwatch()..start();
    final headers = _sessionManager.getRequestHeaders();

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    stopwatch.stop();

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      final rawList = jsonBody['value'] as List<dynamic>? ?? [];
      final List<SapItem> items = rawList
          .map((item) => SapItem.fromJson(item as Map<String, dynamic>))
          .toList();

      final nextLink = jsonBody['odata.nextLink']?.toString();
      final hasMore = nextLink != null || items.length == top;

      return SapPageResponse<SapItem>(
        items: items,
        hasMore: hasMore,
        skip: skip,
        top: top,
        nextLink: nextLink,
        executedUrl: fullUrlString,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } else {
      final errorMsg = _extractSapErrorMessage(response.body, response.statusCode);
      throw Exception(errorMsg);
    }
  }

  /// ==========================================================================
  /// 4. RÉCUPÉRATION DES CLIENTS (BusinessPartners) AVEC PAGINATION ODATA
  /// ==========================================================================
  Future<SapPageResponse<SapClient>> fetchClients({
    required String baseUrl,
    int skip = 0,
    int top = 20,
    String? searchQuery,
  }) async {
    final cleanUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    const selectFields =
        'CardCode,CardName,CardType,Address,ContactPerson,Phone1,Cellular,EmailAddress,ZipCode,City,Country,BPAddresses';

    String filterClause = "CardType eq 'cCustomer'";
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final cleanQuery = searchQuery.trim().replaceAll("'", "''");
      filterClause +=
          " and (contains(CardCode,'$cleanQuery') or contains(CardName,'$cleanQuery') or contains(City,'$cleanQuery'))";
    }

    final queryParams =
        '\$select=$selectFields&\$top=$top&\$skip=$skip&\$filter=$filterClause';
    final fullUrlString = '$cleanUrl/BusinessPartners?$queryParams';
    final uri = Uri.parse(fullUrlString);

    final stopwatch = Stopwatch()..start();
    final headers = _sessionManager.getRequestHeaders();

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    stopwatch.stop();

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      final rawList = jsonBody['value'] as List<dynamic>? ?? [];
      final List<SapClient> clients = rawList
          .map((c) => SapClient.fromJson(c as Map<String, dynamic>))
          .toList();

      final nextLink = jsonBody['odata.nextLink']?.toString();
      final hasMore = nextLink != null || clients.length == top;

      return SapPageResponse<SapClient>(
        items: clients,
        hasMore: hasMore,
        skip: skip,
        top: top,
        nextLink: nextLink,
        executedUrl: fullUrlString,
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } else {
      final errorMsg = _extractSapErrorMessage(response.body, response.statusCode);
      throw Exception(errorMsg);
    }
  }

  String _extractSapErrorMessage(String responseBody, int statusCode) {
    try {
      final parsed = jsonDecode(responseBody);
      if (parsed is Map && parsed.containsKey('error')) {
        final error = parsed['error'];
        if (error is Map && error.containsKey('message')) {
          final msgObj = error['message'];
          if (msgObj is Map && msgObj.containsKey('value')) {
            return 'Erreur SAP ($statusCode) : ${msgObj['value']}';
          } else if (msgObj is String) {
            return 'Erreur SAP ($statusCode) : $msgObj';
          }
        }
      }
    } catch (_) {}

    switch (statusCode) {
      case 401:
        return 'Erreur 401 : Identifiants incorrects ou session expirée.';
      case 403:
        return 'Erreur 403 : Accès refusé ou licence utilisateur insuffisante.';
      case 404:
        return 'Erreur 404 : Ressource ou endpoint SAP introuvable.';
      case 500:
        return 'Erreur 500 : Erreur interne du serveur SAP Service Layer.';
      default:
        return 'Erreur HTTP $statusCode : $responseBody';
    }
  }
}
