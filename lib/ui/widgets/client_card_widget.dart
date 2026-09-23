import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/sap_client_model.dart';

/// ============================================================================
/// WIDGET : ClientCardWidget
/// OBJECTIF PÉDAGOGIQUE :
/// Affiche la fiche d'un client SAP avec adresses et vue JSON OData.
/// ============================================================================
class ClientCardWidget extends StatelessWidget {
  final SapClient client;
  final int index;

  const ClientCardWidget({
    super.key,
    required this.client,
    required this.index,
  });

  void _showDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(Icons.business, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.cardCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              client.cardName,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Coordonnées du Client :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  _buildPropertyRow('Interlocuteur', client.contactPerson ?? '-'),
                  _buildPropertyRow('Téléphone fixe', client.phone1 ?? '-'),
                  _buildPropertyRow('Téléphone mobile', client.cellular ?? '-'),
                  _buildPropertyRow('Adresse E-mail', client.emailAddress ?? '-'),
                  _buildPropertyRow('Adresse principale', client.address ?? '-'),
                  _buildPropertyRow('Ville / Pays', '${client.city ?? '-'} / ${client.country ?? '-'}'),
                  if (client.addresses.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      'Adresses associées (${client.addresses.length}) :',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    ...client.addresses.map((addr) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.grey.shade50,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              addr.addressType == 'bo_ShipTo'
                                  ? Icons.local_shipping
                                  : Icons.receipt_long,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            title: Text(
                              addr.addressName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${addr.street ?? ''} ${addr.city ?? ''} ${addr.country ?? ''}',
                            ),
                          ),
                        )),
                  ],
                  const Divider(height: 24),
                  const Text(
                    'JSON OData brut reçu du serveur SAP :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      const JsonEncoder.withIndent('  ').convert(client.rawJson),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.lightGreenAccent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          client.cardCode,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              client.cardName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            if (client.city != null && client.city!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    client.city!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
          tooltip: 'Voir détails & JSON OData',
          onPressed: () => _showDetailsModal(context),
        ),
        onTap: () => _showDetailsModal(context),
      ),
    );
  }
}
