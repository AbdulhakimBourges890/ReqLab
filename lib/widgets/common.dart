import 'package:material_ui/material_ui.dart';

/// Rounded surface container used instead of the default Card.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: child,
    );
  }
}

/// Small pill-style tab switcher.
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? cs.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: i == index ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class KvRow {
  final key = TextEditingController();
  final value = TextEditingController();
  bool enabled = true;
}

/// Editable key/value list (query params, headers).
class KvEditor extends StatefulWidget {
  const KvEditor({
    super.key,
    required this.rows,
    this.keyHint = 'Key',
    this.valueHint = 'Value',
  });
  final List<KvRow> rows;
  final String keyHint;
  final String valueHint;

  @override
  State<KvEditor> createState() => _KvEditorState();
}

class _KvEditorState extends State<KvEditor> {
  @override
  Widget build(BuildContext context) {
    final rows = widget.rows;
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Checkbox(
                  value: rows[i].enabled,
                  visualDensity: VisualDensity.compact,
                  onChanged: (v) => setState(() => rows[i].enabled = v ?? true),
                ),
                Expanded(
                  child: TextField(
                    controller: rows[i].key,
                    decoration: InputDecoration(hintText: widget.keyHint),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: rows[i].value,
                    decoration: InputDecoration(hintText: widget.valueHint),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() {
                    if (rows.length == 1) {
                      rows[0].key.clear();
                      rows[0].value.clear();
                    } else {
                      rows.removeAt(i);
                    }
                  }),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => rows.add(KvRow())),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
        ),
      ],
    );
  }
}
