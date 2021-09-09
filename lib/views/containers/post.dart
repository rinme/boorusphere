import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/booru_post.dart';
import '../../provider/booru_api.dart';
import '../components/post_display.dart';
import '../components/post_toolbox.dart';
import '../components/preferred_visibility.dart';
import '../components/subbed_title.dart';

final lastOpenedPostProvider = StateProvider((_) => -1);

class Post extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final beginPage = ModalRoute.of(context)?.settings.arguments as int;

    final pageController = usePageController(initialPage: beginPage);
    final booruPosts = useProvider(postsProvider);
    final lastOpenedIndex = useProvider(lastOpenedPostProvider);
    final page = useState(beginPage);
    final isFullscreen = useState(false);

    final isNotVideo = booruPosts[page.value].displayType != PostType.video;

    useEffect(() {
      SystemChrome.setSystemUIChangeCallback((fullscreen) async {
        isFullscreen.value = fullscreen;
      });

      // reset SystemChrome when pop back to timeline
      return () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([]);
      };
    }, const []);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredVisibility(
        visible: !isFullscreen.value,
        child: AppBar(
          backgroundColor: Colors.black.withOpacity(0.4),
          elevation: 0,
          title: SubbedTitle(
            title: '#${page.value + 1} of ${booruPosts.length}',
            subtitle: booruPosts[page.value].tags.join(' '),
          ),
        ),
      ),
      body: PageView.builder(
        controller: pageController,
        onPageChanged: (index) {
          page.value = index;
          lastOpenedIndex.state = index;
        },
        itemCount: booruPosts.length,
        itemBuilder: (_, index) => PostDisplay(content: booruPosts[index]),
      ),
      bottomNavigationBar: Visibility(
        visible: !isFullscreen.value && isNotVideo,
        child: PostToolbox(booruPosts[page.value]),
      ),
    );
  }
}
