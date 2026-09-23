import 'dart:io';

/// ============================================================================
/// CLASSE : SapHttpOverrides
/// OBJECTIF PÉDAGOGIQUE :
/// Dans les environnements de développement ou locaux de SAP Business One,
/// le Service Layer utilise très fréquemment des certificats SSL/TLS auto-signés
/// (self-signed certificates) ou non reconnus par les autorités de certification
/// publiques (comme Let's Encrypt ou DigiCert).
///
/// Par défaut, Dart et Flutter rejettent toute connexion HTTPS dont le certificat
/// n'est pas validé par le système d'exploitation avec l'erreur :
/// `HandshakeException: Handshake error in client (CERTIFICATE_VERIFY_FAILED)`.
///
/// Cette classe hérite de `HttpOverrides` pour intercepter toutes les requêtes
/// HTTP/HTTPS de l'application et accepter les certificats auto-signés via
/// la méthode `badCertificateCallback`.
///
/// ATTENTION / BONNE PRATIQUE :
/// En environnement de PRODUCTION réelle avec un vrai certificat émis par une
/// autorité reconnue, cette désactivation ne doit pas être utilisée afin de
/// garantir la protection contre les attaques Man-in-the-Middle (MitM).
/// ============================================================================
class SapHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      // On intercepte le callback de validation du certificat
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        // En retournant 'true', on autorise la communication sécurisée
        // même si le certificat est auto-signé ou expiré.
        return true;
      };
  }
}
