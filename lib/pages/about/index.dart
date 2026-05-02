import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/pages/about/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aboutProvider);
    final Color outline = Theme.of(context).colorScheme.outline;
    TextStyle subTitleStyle =
        TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        title: Text('关于', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo/logo.png',
              width: 150,
            ),
            Text(
              'PiliOtto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Badge(
              isLabelVisible: state.isLoading ? false : state.isUpdate,
              label: const Text('New'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: FilledButton.tonal(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                launchUrl(
                                  Uri.parse(
                                      'https://github.com/CyaniAgent/piliotto/releases'),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              title: const Text('Github下载'),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).padding.bottom + 20)
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    'V${state.currentVersion}',
                    style: subTitleStyle.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () => _githubUrl(),
              title: const Text('开源地址'),
              trailing: Text(
                'github.com/CyaniAgent/piliotto',
                style: subTitleStyle,
              ),
            ),
            ListTile(
              onTap: () => _feedback(),
              title: const Text('问题反馈'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: outline,
              ),
            ),
            ListTile(
              onTap: () => context.push('/logs'),
              title: const Text('错误日志'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: outline),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20)
          ],
        ),
      ),
    );
  }

  void _githubUrl() {
    launchUrl(
      Uri.parse('https://github.com/CyaniAgent/piliotto'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _feedback() {
    launchUrl(
      Uri.parse('https://github.com/CyaniAgent/piliotto/issues'),
      mode: LaunchMode.externalApplication,
    );
  }
}
