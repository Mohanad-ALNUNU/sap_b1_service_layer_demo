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
