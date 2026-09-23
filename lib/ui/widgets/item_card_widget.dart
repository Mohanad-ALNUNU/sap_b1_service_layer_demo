import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/sap_item_model.dart';

/// ============================================================================
/// WIDGET : ItemCardWidget
/// OBJECTIF PÉDAGOGIQUE :
/// Affiche la fiche synthétique d'un article SAP (`Item`) et permet
/// d'ouvrir une boîte de dialogue pour inspecter le JSON brut reçu depuis SAP.
/// ============================================================================
class ItemCardWidget extends StatelessWidget {
  final SapItem item;
  final int index;

  const ItemCardWidget({
    super.key,
    required this.item,
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
          initialChildSize: 0.7,
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
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(Icons.inventory_2, color: Color(0xFF0D47A1)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              item.itemName,
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
                    'Propriétés SAP :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  _buildPropertyRow('Unité de mesure (UOM)', item.inventoryUOM ?? '-'),
                  _buildPropertyRow('Poids unitaire', item.inventoryWeight != null ? '${item.inventoryWeight} kg' : '-'),
                  _buildPropertyRow('Nom étranger (ForeignName)', item.foreignName ?? '-'),
                  _buildPropertyRow('Famille (U_FAMILLE)', item.famille ?? '-'),
                  _buildPropertyRow('Variété (U_VARIETE)', item.variete ?? '-'),
                  _buildPropertyRow('Calibre (U_CALIBRE)', item.calibre ?? '-'),
                  _buildPropertyRow('Marque (U_MARQUE)', item.marque ?? '-'),
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
                      const JsonEncoder.withIndent('  ').convert(item.rawJson),
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
          backgroundColor: const Color(0xFF0D47A1).withValues(alpha: 0.1),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Color(0xFF0D47A1),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          item.itemCode,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.itemName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (item.inventoryUOM != null && item.inventoryUOM!.isNotEmpty)
                  _buildChip(item.inventoryUOM!, Colors.blueGrey),
                if (item.famille != null && item.famille!.isNotEmpty)
                  _buildChip(item.famille!, Colors.indigo),
                if (item.variete != null && item.variete!.isNotEmpty)
                  _buildChip(item.variete!, Colors.teal),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline, color: Color(0xFF0D47A1)),
          tooltip: 'Voir détails & JSON OData',
          onPressed: () => _showDetailsModal(context),
        ),
        onTap: () => _showDetailsModal(context),
      ),
    );
  }

  Widget _buildChip(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color.shade800, fontWeight: FontWeight.w500),
      ),
    );
  }
}
