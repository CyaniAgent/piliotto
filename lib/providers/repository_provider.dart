import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/repositories/i_user_repository.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';
import 'package:piliotto/repositories/i_danmaku_repository.dart';
import 'package:piliotto/repositories/i_dynamics_repository.dart';
import 'package:piliotto/repositories/i_message_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_user_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_video_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_comment_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_danmaku_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_dynamics_repository.dart';
import 'package:piliotto/ottohub/repositories/ottohub_message_repository.dart';

part 'repository_provider.g.dart';

@riverpod
IUserRepository userRepository(Ref ref) {
  return OttohubUserRepository();
}

@riverpod
IVideoRepository videoRepository(Ref ref) {
  return OttohubVideoRepository();
}

@riverpod
ICommentRepository commentRepository(Ref ref) {
  return OttohubCommentRepository();
}

@riverpod
IDanmakuRepository danmakuRepository(Ref ref) {
  return OttohubDanmakuRepository();
}

@riverpod
IDynamicsRepository dynamicsRepository(Ref ref) {
  return OttohubDynamicsRepository();
}

@riverpod
IMessageRepository messageRepository(Ref ref) {
  return OttohubMessageRepository();
}
