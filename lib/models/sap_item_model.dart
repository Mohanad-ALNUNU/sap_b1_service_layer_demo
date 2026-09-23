/// ============================================================================
/// MODÈLE : SapItem
/// OBJECTIF PÉDAGOGIQUE :
/// Représente un Article dans SAP Business One (Entité OData `Items`).
/// ============================================================================
class SapItem {
  final String itemCode;
  final String itemName;
  final String? foreignName;
  final String? inventoryUOM;
  final double? inventoryWeight;
  final String? itemType;
  final String? valid;
  
  final String? famille;
  final String? variete;
  final String? calibre;
  final String? marque;

  final Map<String, dynamic> rawJson;

  SapItem({
    required this.itemCode,
    required this.itemName,
    this.foreignName,
    this.inventoryUOM,
    this.inventoryWeight,
    this.itemType,
    this.valid,
    this.famille,
    this.variete,
    this.calibre,
    this.marque,
    required this.rawJson,
  });

  factory SapItem.fromJson(Map<String, dynamic> json) {
    return SapItem(
      itemCode: json['ItemCode']?.toString() ?? '',
      itemName: json['ItemName']?.toString() ?? '(Sans nom)',
      foreignName: json['ForeignName']?.toString(),
      inventoryUOM: json['InventoryUOM']?.toString(),
      inventoryWeight: _parseDouble(json['InventoryWeight']),
      itemType: json['ItemType']?.toString(),
      valid: json['Valid']?.toString(),
      famille: json['U_FAMILLE']?.toString(),
      variete: json['U_VARIETE']?.toString(),
      calibre: json['U_CALIBRE']?.toString(),
      marque: json['U_MARQUE']?.toString(),
      rawJson: json,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
