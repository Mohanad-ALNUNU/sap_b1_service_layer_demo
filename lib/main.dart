import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/sap_http_overrides.dart';
import 'providers/sap_auth_provider.dart';
import 'providers/sap_items_provider.dart';
import 'providers/sap_clients_provider.dart';
import 'ui/screens/sap_login_screen.dart';

/// ============================================================================
/// APPLICATION AUTONOME : SAP Business One Service Layer Demo
/// ============================================================================
/// OBJECTIF PÉDAGOGIQUE :
/// Application de référence pour apprendre à :
///  1. Gérer le bypass SSL pour les certificats auto-signés (`HttpOverrides`).
///  2. Authentifier l'utilisateur via `POST /b1s/v1/Login` et maintenir la session
///     avec les cookies `B1SESSION` et `ROUTEID`.
///  3. Récupérer et paginer les Articles (`/b1s/v1/Items`) et Clients (`/b1s/v1/BusinessPartners`)
///     avec le protocole OData (`$top`, `$skip`, `$select`, `$filter`).
///  4. Implémenter l'Infinite Scroll (chargement au défilement) avec Flutter Provider.
/// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Contournement du certificat SSL pour les environnements de dev/test SAP
  HttpOverrides.global = SapHttpOverrides();

  // Initialisation et chargement des préférences
  final authProvider = SapAuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        // MultiProvider crée une seule instance partagée pour chaque feature.
        // Tous les widgets sous MaterialApp peuvent ensuite récupérer ces objets
        // avec context.read<T>() ou se reconstruire automatiquement lors de leurs
        // changements via context.watch<T>().
        ChangeNotifierProvider<SapAuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<SapItemsProvider>(
            create: (_) => SapItemsProvider()),
        ChangeNotifierProvider<SapClientsProvider>(
            create: (_) => SapClientsProvider()),
      ],
      child: const SapDemoApp(),
    ),
  );
}

class SapDemoApp extends StatelessWidget {
  const SapDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAP B1 Service Layer Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), // Bleu SAP
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const SapLoginScreen(),
    );
  }
}
