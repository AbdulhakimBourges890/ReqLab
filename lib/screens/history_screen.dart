import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../services/history_service.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await HistoryService.getAll();

    if (!mounted) return;

    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  String _date(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  Color _methodColor(String method) {
    switch (method) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.purple;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _clearHistory() async {
    if (_entries.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This will permanently delete all saved requests.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.clear();
      await _load();
    }
  }

  Future<void> _openDetails(HistoryEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryDetailScreen(entry: entry)),
    );

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request History',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            onPressed: _entries.isEmpty ? null : _clearHistory,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 48,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No request history yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Your requests will appear here.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Dismissible(
                      key: ValueKey(entry.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: cs.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.delete_outline, color: cs.onError),
                      ),
                      onDismissed: (_) async {
                        await HistoryService.delete(entry.id);
                        await _load();
                      },
                      child: AppCard(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _openDetails(entry),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: _methodColor(entry.method)
                                      .withValues(alpha: 0.13),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  entry.method,
                                  style: TextStyle(
                                    color: _methodColor(entry.method),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.url,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          entry.failed
                                              ? Icons.error_outline
                                              : Icons.check_circle_outline,
                                          size: 14,
                                          color: entry.failed
                                              ? cs.error
                                              : Colors.green,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          entry.failed
                                              ? 'Failed'
                                              : '${entry.status} ${entry.reason ?? ''}',
                                          style: TextStyle(
                                            color: entry.failed
                                                ? cs.error
                                                : cs.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _date(entry.date),
                                          style: TextStyle(
                                            color: cs.onSurfaceVariant,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.chevron_right,
                                color: cs.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// --------------------------------------------------
// Request details
// --------------------------------------------------

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.entry});

  final HistoryEntry entry;

  String _date(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
  }

  String _json(Object? value) {
    if (value == null) return '';

    if (value is String) return value;

    return const JsonEncoder.withIndent('  ').convert(value);
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete request?'),
        content: const Text(
          'This request will be permanently removed from history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await HistoryService.delete(entry.id);

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        actions: [
          IconButton(
            tooltip: 'Delete request',
            onPressed: () => _delete(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.method,
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      entry.failed
                          ? 'FAILED'
                          : '${entry.status} ${entry.reason ?? ''}',
                      style: TextStyle(
                        color: entry.failed ? cs.error : Colors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  entry.url,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _date(entry.date),
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Text(
                  'Response time: ${entry.responseTime} ms',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                Text(
                  'Response size: ${entry.responseSize} bytes',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _DetailSection(title: 'Query Parameters', value: _json(entry.params)),

          _DetailSection(
            title: 'Request Headers',
            value: _json(entry.requestHeaders),
          ),

          _DetailSection(
            title: 'Request Body',
            value: entry.requestBody ?? '(No request body)',
          ),

          _DetailSection(
            title: 'Response Headers',
            value: _json(entry.responseHeaders),
          ),

          _DetailSection(
            title: 'Response Body',
            value: entry.responseBody.isEmpty
                ? '(Empty response body)'
                : entry.responseBody,
          ),

          if (entry.error != null)
            _DetailSection(title: 'Error', value: entry.error!, error: true),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.value,
    this.error = false,
  });

  final String title;
  final String value;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                  color: error ? cs.error : cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
