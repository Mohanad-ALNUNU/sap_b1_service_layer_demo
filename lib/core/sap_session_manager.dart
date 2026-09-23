/// ============================================================================
/// CLASSE : SapSessionManager
/// OBJECTIF PÉDAGOGIQUE :
/// Le Service Layer de SAP Business One utilise un mécanisme d'état de session
/// basé sur les cookies HTTP :
///
/// 1. Lors d'un appel réussi à `POST /b1s/v1/Login`, le serveur SAP retourne :
///    - Dans le corps JSON :
///      - `SessionId` (identifiant unique de la session)
///      - `SessionTimeout` (durée de validité en minutes, ex: 30 min)
///    - Dans les en-têtes HTTP de réponse (`Set-Cookie`) :
///      - `B1SESSION=...` : Cookie de session SAP
///      - `ROUTEID=.nodeX` : Cookie d'équilibrage de charge (Load Balancing)
///
/// 2. Pour TOUTES les requêtes suivantes (GET /Items, GET /BusinessPartners, etc.),
///    le client DOIT obligatoirement renvoyer ces cookies dans l'en-tête HTTP :
///    `Cookie: B1SESSION=...; ROUTEID=...`
///
/// Cette classe gère ce cycle de vie en mémoire sous forme de Singleton.
/// ============================================================================
class SapSessionManager {
  static final SapSessionManager _instance = SapSessionManager._internal();
  factory SapSessionManager() => _instance;
  SapSessionManager._internal();

  String? _sessionId;
  String? _cookieHeader;
  DateTime? _loginTime;
  int _sessionTimeoutMinutes = 30;
  String? _companyDb;
  String? _username;

  bool get isAuthenticated {
    if (_sessionId == null || _cookieHeader == null || _loginTime == null) {
      return false;
    }
    final now = DateTime.now();
    final elapsedMinutes = now.difference(_loginTime!).inMinutes;
    return elapsedMinutes < _sessionTimeoutMinutes;
  }

  String? get sessionId => _sessionId;
  String? get cookieHeader => _cookieHeader;
  String? get companyDb => _companyDb;
  String? get username => _username;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;

  Duration get remainingTime {
    if (_loginTime == null) return Duration.zero;
    final expiresAt = _loginTime!.add(Duration(minutes: _sessionTimeoutMinutes));
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void startSession({
    required String sessionId,
    required String? cookieHeader,
    required int timeoutMinutes,
    required String companyDb,
    required String username,
  }) {
    _sessionId = sessionId;
    _cookieHeader = cookieHeader;
    _sessionTimeoutMinutes = timeoutMinutes > 0 ? timeoutMinutes : 30;
    _loginTime = DateTime.now();
    _companyDb = companyDb;
    _username = username;
  }

  Map<String, String> getRequestHeaders({Map<String, String>? extraHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    if (_cookieHeader != null && _cookieHeader!.isNotEmpty) {
      headers['Cookie'] = _cookieHeader!;
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  void clearSession() {
    _sessionId = null;
    _cookieHeader = null;
    _loginTime = null;
    _companyDb = null;
    _username = null;
  }
}
