import 'package:flutter/material.dart';
import '../models/sap_client_model.dart';
import '../services/sap_service_layer_client.dart';

/// ============================================================================
/// PROVIDER : SapClientsProvider
/// OBJECTIF PÉDAGOGIQUE :
/// Gère la liste paginée des Clients SAP (`BusinessPartners`) avec Infinite Scroll.
/// ============================================================================
class SapClientsProvider with ChangeNotifier {
  final SapServiceLayerClient _client = SapServiceLayerClient();

  final List<SapClient> _clients = [];
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentSkip = 0;
  static const int pageSize = 20;

  String _searchQuery = '';
  String? _errorMessage;
  String? _lastExecutedUrl;
  int? _lastDurationMs;

  List<SapClient> get clients => List.unmodifiable(_clients);
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get currentSkip => _currentSkip;
  int get totalLoadedCount => _clients.length;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  String? get lastExecutedUrl => _lastExecutedUrl;
  int? get lastDurationMs => _lastDurationMs;

  // Un rafraîchissement ou une nouvelle recherche remplace le jeu de données
  // courant. En gardant cette réinitialisation dans le provider, tous les
  // écrans suivent les mêmes règles de pagination.
  Future<void> fetchInitial(String baseUrl) async {
    _isLoadingInitial = true;
    _errorMessage = null;
    _clients.clear();
    _currentSkip = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final response = await _client.fetchClients(
        baseUrl: baseUrl,
        skip: 0,
        top: pageSize,
        searchQuery: _searchQuery,
      );

      _clients.addAll(response.items);
      _hasMore = response.hasMore;
      _currentSkip = response.items.length;
      _lastExecutedUrl = response.executedUrl;
      _lastDurationMs = response.durationMs;
      _isLoadingInitial = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage(String baseUrl) async {
    // Le listener du scroll peut se déclencher plusieurs fois près du seuil.
    // Ces garde-fous évitent les appels dupliqués et gardent l'ordre des pages.
    if (_isLoadingMore || _isLoadingInitial || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _client.fetchClients(
        baseUrl: baseUrl,
        skip: _currentSkip,
        top: pageSize,
        searchQuery: _searchQuery,
      );

      _clients.addAll(response.items);
      _hasMore = response.hasMore;
      // currentSkip est un offset OData, pas un numéro de page. On avance selon
      // la taille réelle de la réponse, car la dernière page peut être plus courte.
      _currentSkip += response.items.length;
      _lastExecutedUrl = response.executedUrl;
      _lastDurationMs = response.durationMs;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> search(String query, String baseUrl) async {
    // Une recherche repart à l'offset zéro via fetchInitial(), ce qui vide
    // aussi les résultats issus de la requête précédente.
    _searchQuery = query.trim();
    await fetchInitial(baseUrl);
  }

  void clear() {
    _clients.clear();
    _currentSkip = 0;
    _hasMore = true;
    _errorMessage = null;
    _searchQuery = '';
    notifyListeners();
  }
}
