import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sap_auth_provider.dart';
import '../../providers/sap_items_provider.dart';
import '../../providers/sap_clients_provider.dart';
import 'sap_items_screen.dart';
import 'sap_clients_screen.dart';
import 'sap_login_screen.dart';

/// ============================================================================
/// ÉCRAN : SapDashboardScreen
/// OBJECTIF PÉDAGOGIQUE :
/// Tableau de bord central une fois connecté à SAP Business One.
/// ============================================================================
class SapDashboardScreen extends StatelessWidget {
  const SapDashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion SAP'),
        content: const Text(
          'Voulez-vous fermer la session courante sur le Service Layer SAP ? '
          'Cela enverra une requête POST /Logout pour libérer la ressource.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final auth = context.read<SapAuthProvider>();
      context.read<SapItemsProvider>().clear();
      context.read<SapClientsProvider>().clear();
      await auth.logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SapLoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<SapAuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'SAP Demo Hub',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter de SAP',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Session SAP Active',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D47A1).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  auth.companyDb ?? 'SAP DB',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildInfoRow('Utilisateur connecté :', auth.username ?? '-'),
                          _buildInfoRow('Serveur cible :', auth.config.cleanBaseUrl),
                          _buildInfoRow(
                            'Session ID :',
                            auth.sessionId ?? 'Non défini',
                            isCode: true,
                          ),
                          if (auth.lastLoginDurationMs != null)
                            _buildInfoRow(
                              'Temps de login :',
                              '${auth.lastLoginDurationMs} ms',
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Entités SAP disponibles pour la démo :',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildEntityCard(
                    context: context,
                    icon: Icons.inventory_2,
                    iconColor: const Color(0xFF0D47A1),
                    backgroundColor: const Color(0xFFE3F2FD),
                    title: 'Articles (Items)',
                    endpoint: 'GET /b1s/v1/Items',
                    description:
                        'Récupération du catalogue d\'articles avec pagination OData (\$top, \$skip), recherche par code/désignation et chargement infini au défilement.',
                    buttonText: 'Consulter les Articles',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SapItemsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildEntityCard(
                    context: context,
                    icon: Icons.people_alt,
                    iconColor: const Color(0xFF2E7D32),
                    backgroundColor: const Color(0xFFE8F5E9),
                    title: 'Clients (BusinessPartners)',
                    endpoint: 'GET /b1s/v1/BusinessPartners',
                    description:
                        'Extraction des partenaires commerciaux avec filtre CardType=\'cCustomer\', adresses de livraison et pagination au scroll.',
                    buttonText: 'Consulter les Clients',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SapClientsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cookie_outlined,
                              color: Colors.blueGrey.shade800,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Comment fonctionne la communication ?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.blueGrey.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Toutes les requêtes vers les endpoints /Items et /BusinessPartners '
                          'transmettent automatiquement le header HTTP "Cookie" contenant '
                          'le B1SESSION et le ROUTEID retournés par le Login initial.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey.shade800,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: isCode ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntityCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String endpoint,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          endpoint,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.download, size: 16),
                  label: Text(buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
