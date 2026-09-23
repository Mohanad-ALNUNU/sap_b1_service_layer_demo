import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sap_auth_provider.dart';
import '../../providers/sap_clients_provider.dart';
import '../widgets/educational_info_banner.dart';
import '../widgets/client_card_widget.dart';

/// ============================================================================
/// ÉCRAN : SapClientsScreen
/// OBJECTIF PÉDAGOGIQUE :
/// Consultation paginée des Clients SAP (`BusinessPartners`) avec Infinite Scroll.
/// ============================================================================
class SapClientsScreen extends StatefulWidget {
  const SapClientsScreen({super.key});

  @override
  State<SapClientsScreen> createState() => _SapClientsScreenState();
}

class _SapClientsScreenState extends State<SapClientsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final baseUrl = context.read<SapAuthProvider>().config.cleanBaseUrl;
    context.read<SapClientsProvider>().fetchInitial(baseUrl);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= (maxScroll - 200)) {
      final baseUrl = context.read<SapAuthProvider>().config.cleanBaseUrl;
      context.read<SapClientsProvider>().fetchNextPage(baseUrl);
    }
  }

  void _handleSearch(String query) {
    final baseUrl = context.read<SapAuthProvider>().config.cleanBaseUrl;
    context.read<SapClientsProvider>().search(query, baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    final clientsProvider = context.watch<SapClientsProvider>();
    final auth = context.read<SapAuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Clients SAP (BusinessPartners)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recharger',
            onPressed: () => clientsProvider.fetchInitial(auth.config.cleanBaseUrl),
          ),
        ],
      ),
      body: Column(
        children: [
          EducationalInfoBanner(
            title: 'Requête OData BusinessPartners (Clients)',
            executedUrl: clientsProvider.lastExecutedUrl,
            durationMs: clientsProvider.lastDurationMs,
            accentColor: const Color(0xFF2E7D32),
            educationalNote:
                'SAP regroupe tous les partenaires dans "BusinessPartners". '
                'Le filtre "\$filter=CardType eq \'cCustomer\'" isole les clients. '
                'La pagination "\$skip=${clientsProvider.currentSkip}" charge les résultats par lots de 20.',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un client (code, nom ou ville)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onSubmitted: _handleSearch,
              textInputAction: TextInputAction.search,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${clientsProvider.totalLoadedCount} client(s) chargé(s)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (clientsProvider.hasMore)
                  Row(
                    children: [
                      Icon(Icons.autorenew, size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Défilez pour charger la suite',
                        style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                      ),
                    ],
                  )
                else
                  Text(
                    'Fin des clients',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),

          Expanded(
            child: _buildListContent(clientsProvider, auth),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(SapClientsProvider provider, SapAuthProvider auth) {
    if (provider.isLoadingInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
            SizedBox(height: 16),
            Text(
              'Récupération des clients depuis SAP...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (provider.errorMessage != null && provider.clients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.red.shade400),
              const SizedBox(height: 12),
              const Text(
                'Échec de la récupération',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.fetchInitial(auth.config.cleanBaseUrl),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Aucun client trouvé',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Modifiez vos termes de recherche ou vérifiez la base SAP.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchInitial(auth.config.cleanBaseUrl),
      color: const Color(0xFF2E7D32),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: provider.clients.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.clients.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: provider.isLoadingMore
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Chargement des clients suivants (\$skip)...',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }

          final client = provider.clients[index];
          return ClientCardWidget(client: client, index: index);
        },
      ),
    );
  }
}
