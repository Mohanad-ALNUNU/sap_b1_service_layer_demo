/// ============================================================================
/// MODÈLE GÉNÉRIQUE : `SapPageResponse<T>`
/// OBJECTIF PÉDAGOGIQUE :
/// La pagination dans le protocole OData de SAP Service Layer repose sur :
///  - `$top` : Le nombre maximal d'éléments demandés par page (ex: 20)
///  - `$skip` : Le décalage / offset d'éléments à ignorer (ex: 0, 20, 40...)
///  - `odata.nextLink` : Une URL fournie par SAP indiquant l'adresse de la page suivante
/// ============================================================================
class SapPageResponse<T> {
  final List<T> items;
  final bool hasMore;
  final int skip;
  final int top;
  final String? nextLink;
  final String executedUrl;
  final int statusCode;
  final int durationMs;

  SapPageResponse({
    required this.items,
    required this.hasMore,
    required this.skip,
    required this.top,
    this.nextLink,
    required this.executedUrl,
    required this.statusCode,
    required this.durationMs,
  });
}
