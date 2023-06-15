import 'dart:io';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/favorite_post/entity/favorite_post.dart';
import 'package:boorusphere/data/repository/search_history/entity/search_history.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/data/repository/tags_blocker/entity/booru_tag.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/entity/download_quality.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;

void initializeTestHive() {
  final runtimeDir =
      path.join(Directory.current.path, 'build', 'test', 'runtime');
  Hive.init(runtimeDir);
  Hive
    ..registerAdapter(ServerAdapter())
    ..registerAdapter(BooruTagAdapter())
    ..registerAdapter(SearchHistoryAdapter())
    ..registerAdapter(PostAdapter())
    ..registerAdapter(DownloadEntryAdapter())
    ..registerAdapter(FavoritePostAdapter())
    ..registerAdapter(BooruRatingAdapter())
    ..registerAdapter(DownloadQualityAdapter());
}

Future<void> destroyTestHive() async {
  await Hive.deleteFromDisk();
  await Hive.close();
}
