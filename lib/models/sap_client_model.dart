/// ============================================================================
/// MODÈLE : SapClient (Partenaire commercial / Business Partner)
/// OBJECTIF PÉDAGOGIQUE :
/// Dans SAP Business One, tous les tiers (Clients, Fournisseurs, Prospects)
/// sont gérés dans l'entité OData `BusinessPartners`.
/// ============================================================================
class SapClient {
  final String cardCode;
  final String cardName;
  final String cardType;
  final String? address;
  final String? contactPerson;
  final String? phone1;
  final String? cellular;
  final String? emailAddress;
  final String? zipCode;
  final String? city;
  final String? country;
  final List<SapClientAddress> addresses;
  final Map<String, dynamic> rawJson;

  SapClient({
    required this.cardCode,
    required this.cardName,
    required this.cardType,
    this.address,
    this.contactPerson,
    this.phone1,
    this.cellular,
    this.emailAddress,
    this.zipCode,
    this.city,
    this.country,
    required this.addresses,
    required this.rawJson,
  });

  factory SapClient.fromJson(Map<String, dynamic> json) {
    final rawAddresses = json['BPAddresses'] as List<dynamic>? ?? [];
    final parsedAddresses = rawAddresses
        .map((a) => SapClientAddress.fromJson(a as Map<String, dynamic>))
        .toList();

    return SapClient(
      cardCode: json['CardCode']?.toString() ?? '',
      cardName: json['CardName']?.toString() ?? '(Sans nom)',
      cardType: json['CardType']?.toString() ?? 'cCustomer',
      address: json['Address']?.toString(),
      contactPerson: json['ContactPerson']?.toString(),
      phone1: json['Phone1']?.toString(),
      cellular: json['Cellular']?.toString(),
      emailAddress: json['EmailAddress']?.toString(),
      zipCode: json['ZipCode']?.toString(),
      city: json['City']?.toString(),
      country: json['Country']?.toString(),
      addresses: parsedAddresses,
      rawJson: json,
    );
  }
}

class SapClientAddress {
  final String addressName;
  final String addressType; // 'bo_ShipTo' (Livraison) ou 'bo_BillTo' (Facturation)
  final String? street;
  final String? city;
  final String? country;

  SapClientAddress({
    required this.addressName,
    required this.addressType,
    this.street,
    this.city,
    this.country,
  });

  factory SapClientAddress.fromJson(Map<String, dynamic> json) {
    return SapClientAddress(
      addressName: json['AddressName']?.toString() ?? '',
      addressType: json['AddressType']?.toString() ?? 'bo_ShipTo',
      street: json['Street']?.toString(),
      city: json['City']?.toString(),
      country: json['Country']?.toString(),
    );
  }
}
