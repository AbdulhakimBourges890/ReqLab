import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/common.dart';

const kGithubUrl = 'https://github.com/AbdulhakimbBourges890/ReqLab';

const kGithubProfileUrl = 'https://github.com/AbdulhakimBourges890/';

const kPlayStoreUrl =
    'https://play.google.com/store/apps/developer?id=BourgesDev';

const kEmail = 'abdulhakimbourges@gmail.com';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link. Please try again.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Check your connection.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withValues(alpha: 0.55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.bolt, size: 46, color: cs.onPrimary),
          ),
        ),

        const SizedBox(height: 14),

        const Center(
          child: Text(
            'ReqLab',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ),

        Center(
          child: Text(
            'Version 1.0.1',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),

        const SizedBox(height: 20),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About the app',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              Text(
                'ReqLab is a free and open-source tool for fast, simple, and efficient API testing.',
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        InkWell(
          onTap: () => _open(context, Uri.parse(kGithubProfileUrl)),
          borderRadius: BorderRadius.circular(16),
          child: AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: const AssetImage(
                    'assets/images/developer.jpg',
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Abdulhakim Bourges',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'The developer',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.github,
                            size: 14,
                            color: cs.primary,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            'View on GitHub',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(Icons.open_in_new, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LinkIcon(
              icon: FontAwesomeIcons.envelope,
              tooltip: 'Email',
              onTap: () => _open(
                context,
                Uri(
                  scheme: 'mailto',
                  path: kEmail,
                  query: 'subject=ReqLab feedback',
                ),
              ),
            ),

            _LinkIcon(
              icon: FontAwesomeIcons.googlePlay,
              tooltip: 'My apps on Google Play',
              onTap: () => _open(context, Uri.parse(kPlayStoreUrl)),
            ),

            _LinkIcon(
              icon: FontAwesomeIcons.github,
              tooltip: 'GitHub Repository',
              onTap: () => _open(context, Uri.parse(kGithubUrl)),
            ),
          ],
        ),
      ],
    );
  }
}

class _LinkIcon extends StatelessWidget {
  const _LinkIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final FaIconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline),
            ),
            child: FaIcon(icon, color: cs.primary, size: 22),
          ),
        ),
      ),
    );
  }
}
