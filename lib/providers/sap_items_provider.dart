import 'package:flutter/material.dart';
import '../models/sap_item_model.dart';
import '../services/sap_service_layer_client.dart';

/// ============================================================================
/// PROVIDER : SapItemsProvider
/// OBJECTIF PÉDAGOGIQUE :
/// Gère la liste paginée des Articles SAP (`Items`) avec Infinite Scroll.
/// ============================================================================
class SapItemsProvider with ChangeNotifier {
  final SapServiceLayerClient _client = SapServiceLayerClient();

  final List<SapItem> _items = [];
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentSkip = 0;
  static const int pageSize = 20;

  String _searchQuery = '';
  String? _errorMessage;
  String? _lastExecutedUrl;
  int? _lastDurationMs;

  List<SapItem> get items => List.unmodifiable(_items);
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get currentSkip => _currentSkip;
  int get totalLoadedCount => _items.length;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  String? get lastExecutedUrl => _lastExecutedUrl;
  int? get lastDurationMs => _lastDurationMs;

  // Un rafraîchissement ou une nouvelle recherche démarre un nouvel ensemble
  // de données. La première notification affiche l'état de chargement ; la
  // seconde publie les données ou l'erreur.
  Future<void> fetchInitial(String baseUrl) async {
    _isLoadingInitial = true;
    _errorMessage = null;
    _items.clear();
    _currentSkip = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final response = await _client.fetchItems(
        baseUrl: baseUrl,
        skip: 0,
        top: pageSize,
        searchQuery: _searchQuery,
      );

      _items.addAll(response.items);
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
    // Les événements de scroll peuvent se déclencher plusieurs fois. Ces garde-
    // fussent empêchent les doublons pendant le chargement et arrêtent la
    // pagination après la dernière page.
    if (_isLoadingMore || _isLoadingInitial || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _client.fetchItems(
        baseUrl: baseUrl,
        skip: _currentSkip,
        top: pageSize,
        searchQuery: _searchQuery,
      );

      _items.addAll(response.items);
      _hasMore = response.hasMore;
      // currentSkip représente le nombre d'enregistrements déjà présents dans
      // la mémoire locale ; la prochaine requête OData commencera donc après
      // ces éléments.
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
    // fetchInitial() vide le résultat précédent pour éviter d'ajouter les
    // données filtrées à la liste de la requête précédente.
    _searchQuery = query.trim();
    await fetchInitial(baseUrl);
  }

  void clear() {
    _items.clear();
    _currentSkip = 0;
    _hasMore = true;
    _errorMessage = null;
    _searchQuery = '';
    notifyListeners();
  }
}
