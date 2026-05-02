import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:piliotto/utils/route_arguments.dart';

import '../pages/about/index.dart';
import '../pages/dynamics/detail/index.dart';
import '../pages/dynamics/index.dart';
import '../pages/fan/index.dart';
import '../pages/fav/index.dart';
import '../pages/fav_detail/index.dart';
import '../pages/follow/index.dart';
import '../pages/history/index.dart';
import '../pages/main/view.dart';
import '../pages/search/index.dart';
import '../pages/setting/extra_setting.dart';
import '../pages/setting/index.dart';
import '../pages/setting/pages/action_menu_set.dart';
import '../pages/setting/pages/color_select.dart';
import '../pages/setting/pages/display_mode.dart';
import '../pages/setting/pages/font_size_select.dart';
import '../pages/setting/pages/home_tabbar_set.dart';
import '../pages/setting/pages/navigation_bar_set.dart';
import '../pages/setting/pages/play_gesture_set.dart';
import '../pages/setting/pages/play_speed_set.dart';
import '../pages/setting/pages/logs.dart';
import '../pages/setting/play_setting.dart';
import '../pages/setting/style_setting.dart';
import '../pages/video/detail/index.dart';
import '../pages/video/detail/reply_reply/index.dart';
import '../pages/webview/index.dart';
import '../pages/whisper_detail/index.dart';
import '../pages/login/index.dart';
import '../pages/member/index.dart';
import '../pages/member_archive/index.dart';
import '../pages/member_dynamics/index.dart';
import '../pages/message/index.dart';
import '../pages/media/index.dart';
import '../pages/mine/index.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MainApp();
      },
    ),
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const SearchPage();
      },
    ),
    GoRoute(
      path: '/video',
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        routeArguments.setArguments(extra);
        routeArguments.setQueryParameters(state.uri.queryParameters);
        return const VideoDetailPage();
      },
    ),
    GoRoute(
      path: '/webview',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const WebviewPage();
      },
    ),
    GoRoute(
      path: '/setting',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingPage();
      },
    ),
    GoRoute(
      path: '/media',
      builder: (BuildContext context, GoRouterState state) {
        return const MediaPage();
      },
    ),
    GoRoute(
      path: '/fav',
      builder: (BuildContext context, GoRouterState state) {
        return const FavPage();
      },
    ),
    GoRoute(
      path: '/favDetail',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const FavDetailPage();
      },
    ),
    GoRoute(
      path: '/history',
      builder: (BuildContext context, GoRouterState state) {
        return const HistoryPage();
      },
    ),
    GoRoute(
      path: '/dynamics',
      builder: (BuildContext context, GoRouterState state) {
        return const DynamicsPage();
      },
    ),
    GoRoute(
      path: '/dynamicDetail',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const DynamicDetailPage();
      },
    ),
    GoRoute(
      path: '/follow',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const FollowPage();
      },
    ),
    GoRoute(
      path: '/fan',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const FansPage();
      },
    ),
    GoRoute(
      path: '/member',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const MemberPage();
      },
    ),
    GoRoute(
      path: '/mine',
      builder: (BuildContext context, GoRouterState state) {
        return const MinePage(showBackButton: true);
      },
    ),
    GoRoute(
      path: '/replyReply',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const VideoReplyReplyPanel();
      },
    ),
    GoRoute(
      path: '/playSetting',
      builder: (BuildContext context, GoRouterState state) {
        return const PlaySetting();
      },
    ),
    GoRoute(
      path: '/styleSetting',
      builder: (BuildContext context, GoRouterState state) {
        return const StyleSetting();
      },
    ),
    GoRoute(
      path: '/extraSetting',
      builder: (BuildContext context, GoRouterState state) {
        return const ExtraSetting();
      },
    ),
    GoRoute(
      path: '/colorSetting',
      builder: (BuildContext context, GoRouterState state) {
        return const ColorSelectPage();
      },
    ),
    GoRoute(
      path: '/tabbarSetting',
      builder: (BuildContext context, GoRouterState state) {
        return const TabbarSetPage();
      },
    ),
    GoRoute(
      path: '/fontSizeSetting',
      builder: (BuildContext context, GoRouterState state) {
        return const FontSizeSelectPage();
      },
    ),
    GoRoute(
      path: '/displayModeSetting',
      builder: (BuildContext context, GoRouterState state) {
        return const SetDiaplayMode();
      },
    ),
    GoRoute(
      path: '/about',
      builder: (BuildContext context, GoRouterState state) {
        return const AboutPage();
      },
    ),
    GoRoute(
      path: '/playSpeedSet',
      builder: (BuildContext context, GoRouterState state) {
        return const PlaySpeedPage();
      },
    ),
    GoRoute(
      path: '/loginPage',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),
    GoRoute(
      path: '/memberDynamics',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const MemberDynamicsPage();
      },
    ),
    GoRoute(
      path: '/memberArchive',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const MemberArchivePage();
      },
    ),
    GoRoute(
      path: '/logs',
      builder: (BuildContext context, GoRouterState state) {
        return const LogsPage();
      },
    ),
    GoRoute(
      path: '/playerGestureSet',
      builder: (BuildContext context, GoRouterState state) {
        return const PlayGesturePage();
      },
    ),
    GoRoute(
      path: '/navbarSetting',
      builder: (BuildContext context, GoRouterState state) {
        return const NavigationBarSetPage();
      },
    ),
    GoRoute(
      path: '/actionMenuSet',
      builder: (BuildContext context, GoRouterState state) {
        return const ActionMenuSetPage();
      },
    ),
    GoRoute(
      path: '/whisperDetail',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const WhisperDetailPage();
      },
    ),
    GoRoute(
      path: '/message',
      builder: (BuildContext context, GoRouterState state) {
        routeArguments.setQueryParameters(state.uri.queryParameters);
        routeArguments.setArguments(state.extra as Map<String, dynamic>?);
        return const MessagePage();
      },
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) {
    return Scaffold(
      body: Center(
        child: Text('页面未找到: ${state.error}'),
      ),
    );
  },
);
