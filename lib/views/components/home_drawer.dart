import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/server_data.dart';
import '../../provider/app_version.dart';
import '../../provider/booru_api.dart';
import '../../provider/booru_query.dart';
import '../../provider/server_data.dart';
import '../../provider/settings/active_server.dart';
import '../../provider/settings/theme.dart';
import '../../routes.dart';
import 'favicon.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: constraints.copyWith(
                minHeight: constraints.maxHeight,
                maxHeight: double.infinity,
              ),
              child: IntrinsicHeight(
                child: SafeArea(
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(15, 30, 15, 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Boorusphere!',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                  _ThemeSwitcherButton(),
                                ],
                              ),
                            ),
                            _ServerSelection(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Divider(),
                              _BackToHomeTile(),
                              ListTile(
                                title: const Text('Downloads'),
                                leading: const Icon(Icons.cloud_download),
                                dense: true,
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.downloads),
                              ),
                              ListTile(
                                title: const Text('Server'),
                                leading: const Icon(Icons.public),
                                dense: true,
                                onTap: () =>
                                    Navigator.pushNamed(context, Routes.server),
                              ),
                              ListTile(
                                title: const Text('Tags Blocker'),
                                leading: const Icon(Icons.block),
                                dense: true,
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.tagsBlocker),
                              ),
                              ListTile(
                                title: const Text('Settings'),
                                leading: const Icon(Icons.settings),
                                dense: true,
                                onTap: () => Navigator.pushNamed(
                                    context, Routes.settings),
                              ),
                              const AppVersionTile(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThemeSwitcherButton extends HookConsumerWidget {
  IconData themeIconOf(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return Icons.brightness_2;
      case ThemeMode.light:
        return Icons.brightness_high;
      default:
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return IconButton(
      icon: Icon(themeIconOf(themeMode)),
      onPressed: ref.read(themeModeProvider.notifier).cycleTheme,
    );
  }
}

class AppVersionTile extends HookConsumerWidget {
  const AppVersionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider);
    return ListTile(
      title: Text(version.shouldUpdate
          ? 'Update available: ${version.lastestVersion}'
          : 'Boorusphere ${version.version}'),
      leading: Icon(
        Icons.info_outline,
        color: version.shouldUpdate ? Colors.pink.shade300 : null,
      ),
      dense: true,
      onTap: () => Navigator.pushNamed(context, Routes.about),
    );
  }
}

class _BackToHomeTile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(booruApiProvider);
    final booruQuery = ref.watch(booruQueryProvider);
    final booruQueryNotifier = ref.watch(booruQueryProvider.notifier);

    return Visibility(
      visible: booruQuery.tags != ServerData.defaultTag,
      child: ListTile(
        title: const Text('Back to home'),
        leading: const Icon(Icons.home_outlined),
        dense: true,
        onTap: () {
          booruQueryNotifier.setTag(query: ServerData.defaultTag);
          api.posts.clear();
          api.fetch();
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ServerSelection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(booruApiProvider);
    final serverData = ref.watch(serverDataProvider);
    final activeServer = ref.watch(activeServerProvider);
    final activeServerNotifier = ref.read(activeServerProvider.notifier);

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: serverData.map((it) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: ListTile(
            title: Text(it.name),
            leading: Favicon(url: '${it.homepage}/favicon.ico'),
            dense: true,
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            selected: it.name == activeServer.name,
            selectedTileColor: theme.colorScheme.primary
                .withAlpha(theme.brightness == Brightness.light ? 50 : 25),
            onTap: () {
              activeServerNotifier.use(it);
              api.posts.clear();
              api.fetch();
              Navigator.pop(context);
            },
          ),
        );
      }).toList(),
    );
  }
}
