import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sap_auth_provider.dart';
import 'sap_dashboard_screen.dart';

/// ============================================================================
/// ÉCRAN : SapLoginScreen
/// OBJECTIF PÉDAGOGIQUE :
/// Formulaire de configuration du serveur et connexion à SAP Business One.
/// ============================================================================
class SapLoginScreen extends StatefulWidget {
  const SapLoginScreen({super.key});

  @override
  State<SapLoginScreen> createState() => _SapLoginScreenState();
}

class _SapLoginScreenState extends State<SapLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _dbController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<SapAuthProvider>();
    _urlController = TextEditingController(text: auth.config.serverUrl);
    _dbController = TextEditingController(text: auth.config.companyDb);
    _userController = TextEditingController(text: auth.config.username);
    _passwordController = TextEditingController(text: auth.config.password);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _dbController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<SapAuthProvider>();
    auth.updateConfig(
      serverUrl: _urlController.text.trim(),
      companyDb: _dbController.text.trim(),
      username: _userController.text.trim(),
      password: _passwordController.text,
    );

    final success = await auth.login();
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SapDashboardScreen()),
      );
    }
  }

  void _fillSampleDefaults() {
    _urlController.text = 'https://ip:50000/b1s/v1';
    _dbController.text = 'CompanyDB';
    _userController.text = 'username';
    _passwordController.text = 'password';
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Valeurs de démonstration insérées.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<SapAuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'SAP Service Layer Demo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Remplir avec valeurs démo',
            onPressed: _fillSampleDefaults,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    color: const Color(0xFF0D47A1).withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.hub_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Connexion SAP B1 Service Layer',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0D47A1),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cette application démontre l\'authentification, le bypass SSL et la pagination OData (\$top/\$skip).',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (auth.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Paramètres du serveur',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _urlController,
                              decoration: InputDecoration(
                                labelText: 'Service Layer URL',
                                hintText: 'https://192.168.10.41:50000/b1s/v1',
                                prefixIcon: const Icon(Icons.link),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                helperText: 'Adresse IP/domaine avec port et version (/b1s/v1)',
                              ),
                              keyboardType: TextInputType.url,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Veuillez saisir l\'URL du Service Layer';
                                }
                                if (!v.startsWith('http://') && !v.startsWith('https://')) {
                                  return 'L\'URL doit commencer par http:// ou https://';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _dbController,
                              decoration: InputDecoration(
                                labelText: 'Base de données (CompanyDB)',
                                hintText: 'ex: GROUPE_PRODUCTION',
                                prefixIcon: const Icon(Icons.storage),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Veuillez renseigner le nom de la base SAP'
                                  : null,
                            ),

                            const SizedBox(height: 20),
                            Text(
                              'Identifiants de connexion',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _userController,
                              decoration: InputDecoration(
                                labelText: 'Nom d\'utilisateur (UserName)',
                                hintText: 'ex: user1',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Veuillez renseigner le nom d\'utilisateur'
                                  : null,
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe (Password)',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Veuillez renseigner le mot de passe'
                                  : null,
                            ),

                            const SizedBox(height: 24),

                            ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D47A1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login),
                                        SizedBox(width: 8),
                                        Text(
                                          'Se connecter à SAP',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.security, color: Colors.amber.shade900, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note : La classe SapHttpOverrides est active pour autoriser automatiquement les certificats SSL auto-signés de développement.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
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
}
