import 'package:flutter/material.dart';

/// ============================================================================
/// WIDGET : EducationalInfoBanner
/// OBJECTIF PÉDAGOGIQUE :
/// Affiche de façon interactive la requête OData exécutée vers SAP Service Layer.
/// ============================================================================
class EducationalInfoBanner extends StatefulWidget {
  final String title;
  final String? executedUrl;
  final int? durationMs;
  final String educationalNote;
  final Color accentColor;

  const EducationalInfoBanner({
    super.key,
    required this.title,
    this.executedUrl,
    this.durationMs,
    required this.educationalNote,
    this.accentColor = const Color(0xFF0D47A1),
  });

  @override
  State<EducationalInfoBanner> createState() => _EducationalInfoBannerState();
}

class _EducationalInfoBannerState extends State<EducationalInfoBanner> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: widget.accentColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.accentColor,
                          ),
                        ),
                        if (widget.durationMs != null)
                          Text(
                            'Temps de réponse SAP : ${widget.durationMs} ms',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: widget.accentColor,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Explication pédagogique :',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.educationalNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  if (widget.executedUrl != null &&
                      widget.executedUrl!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      '📡 Requête OData exécutée :',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        widget.executedUrl!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
