import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'history_screen.dart';
import '../services/history_service.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class TesterScreen extends StatefulWidget {
  const TesterScreen({super.key});

  @override
  State<TesterScreen> createState() => _TesterScreenState();
}

class _TesterScreenState extends State<TesterScreen> {
  static const _methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];

  String _method = 'GET';
  final _url = TextEditingController();
  final _body = TextEditingController();
  final _params = <KvRow>[KvRow()];
  final _headers = <KvRow>[KvRow()];

  int _reqTab = 0;
  int _resTab = 0;
  bool _loading = false;
  ApiResult? _result;

  bool get _hasBody => _method != 'GET';

  Map<String, String> _toMap(List<KvRow> rows) => {
    for (final r in rows)
      if (r.enabled && r.key.text.trim().isNotEmpty)
        r.key.text.trim(): r.value.text.trim(),
  };

  Future<void> _send() async {
    if (_url.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a URL first')));
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    final method = _method;
    final url = _url.text.trim();
    final params = _toMap(_params);
    final headers = _toMap(_headers);
    final requestBody = _hasBody ? _body.text : null;

    final r = await ApiService.send(
      method: method,
      url: url,
      params: params,
      headers: headers,
      body: requestBody,
    );

    // Save every request, including failed requests.
    try {
      await HistoryService.add(
        method: method,
        url: url,
        params: params,
        requestHeaders: headers,
        requestBody: requestBody,
        result: r,
      );
    } catch (e) {
      debugPrint('History save error: $e');
    }

    if (!mounted) return;

    setState(() {
      _result = r;
      _loading = false;
      _resTab = 0;
    });

    if (r.failed) {
      await _showRequestError(r.error!);
    }
  }

  Future<void> _showRequestError(String error) async {
    final e = error.toLowerCase();

    String title;
    String message;
    IconData icon;

    if (e.contains('socketexception') ||
        e.contains('failed host lookup') ||
        e.contains('connection refused') ||
        e.contains('network is unreachable') ||
        e.contains('connection reset')) {
      title = 'Connection Problem';
      message = 'Unable to connect to the server. Please check your internet connection and try again.';
      icon = Icons.wifi_off_rounded;
    } else if (e.contains('timeout')) {
      title = 'Request Timed Out';
      message = 'The server took too long to respond. Please check your connection and try again.';
      icon = Icons.timer_off_outlined;
    } else if (e.contains('formatexception') || e.contains('invalid uri')) {
      title = 'Invalid URL';
      message = 'The URL is invalid. Please check the address and try again.';
      icon = Icons.link_off_rounded;
    } else {
      title = 'Request Failed';
      message = 'Something went wrong while processing your request. Please check your request settings and try again.';
      icon = Icons.error_outline_rounded;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          icon,
          color: Theme.of(dialogContext).colorScheme.error,
          size: 38,
        ),
        title: Text(title),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _url.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tabs = _hasBody
        ? ['Params', 'Headers', 'Body']
        : ['Params', 'Headers'];
    if (_reqTab >= tabs.length) _reqTab = 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bolt, color: cs.onPrimary, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'ReqLab',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Request History',
              icon: const Icon(Icons.history_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outline),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _method,
                        dropdownColor: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        icon: Icon(
                          Icons.expand_more,
                          color: cs.onSurfaceVariant,
                        ),
                        items: [
                          for (final m in _methods)
                            DropdownMenuItem(
                              value: m,
                              child: Text(
                                m,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Semantic.method(m),
                                ),
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _method = v!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _url,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'https://api.example.com/users',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _send,
                  icon: _loading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_loading ? 'Sending...' : 'Send'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PillTabs(
                labels: tabs,
                index: _reqTab,
                onChanged: (i) => setState(() => _reqTab = i),
              ),
              const SizedBox(height: 12),
              if (_reqTab == 0)
                KvEditor(rows: _params, keyHint: 'Param', valueHint: 'Value')
              else if (_reqTab == 1)
                KvEditor(rows: _headers, keyHint: 'Header', valueHint: 'Value')
              else
                TextField(
                  controller: _body,
                  maxLines: 8,
                  minLines: 5,
                  autocorrect: false,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: '{\n  "name": "value"\n}',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildResponse(cs),
      ],
    );
  }

  Widget _buildResponse(ColorScheme cs) {
    final r = _result;
    if (r == null) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.rocket_launch_outlined,
                size: 36,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 10),
              Text(
                'Send a request to see the response',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    if (r.failed) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Semantic.bad),
                const SizedBox(width: 8),
                const Text(
                  'Request failed',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Semantic.bad,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'The request could not be completed. '
              'Check your connection or request settings.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final color = Semantic.status(r.status);
    final content = _resTab == 0
        ? (r.body.isEmpty ? '(empty body)' : r.body)
        : r.headers.entries.map((e) => '${e.key}: ${e.value}').join('\n');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge('${r.status} ${r.reason ?? ''}'.trim(), color),
              const SizedBox(width: 8),
              _Badge('${r.time.inMilliseconds} ms', cs.onSurfaceVariant),
              const SizedBox(width: 8),
              _Badge(_size(r.size), cs.onSurfaceVariant),
              const Spacer(),
              IconButton(
                tooltip: 'Copy response body',
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: r.body));

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Response copied')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          PillTabs(
            labels: ['Body', 'Headers (${r.headers.length})'],
            index: _resTab,
            onChanged: (i) => setState(() => _resTab = i),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 420),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                content,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _size(int b) =>
      b < 1024 ? '$b B' : '${(b / 1024).toStringAsFixed(1)} KB';
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
