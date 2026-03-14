import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ProfileDesign extends StatelessWidget {
  final String? bannerUrl;
  final String? avatarUrl;
  final String displayName;
  final String username;
  final String? host;
  final String? description;
  final List<BadgeRole> badgeRoles;
  final UserStats? stats;
  final DateTime? joinedDate;
  final bool isLoggedIn;
  final VoidCallback? onBannerTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onMessagePressed;
  final bool isOwner;
  final String? followButtonText;
  final bool showFollowButton;

  const ProfileDesign({
    super.key,
    this.bannerUrl,
    this.avatarUrl,
    required this.displayName,
    required this.username,
    this.host,
    this.description,
    this.badgeRoles = const [],
    this.stats,
    this.joinedDate,
    this.isLoggedIn = true,
    this.onBannerTap,
    this.onAvatarTap,
    this.onLoginPressed,
    this.onFollowPressed,
    this.onMessagePressed,
    this.isOwner = false,
    this.followButtonText,
    this.showFollowButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 900;
    final bannerHeight = isWideScreen ? 350.0 : 200.0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  _buildBanner(context, theme, bannerHeight),
                  if (isLoggedIn)
                    _buildLoggedInHeader(context, theme, isWideScreen)
                  else
                    _buildLoggedOutHeader(context, theme),
                ],
              ),
              if (isLoggedIn)
                Positioned(
                  top: bannerHeight - 45,
                  left: 20,
                  child: _buildAvatar(context, theme),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(BuildContext context, ThemeData theme, double height) {
    if (!isLoggedIn) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primary,
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: bannerUrl != null ? onBannerTap : null,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          image: bannerUrl != null
              ? DecorationImage(
                  image: NetworkImage(bannerUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: bannerUrl == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primary,
                  ],
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                theme.colorScheme.surface.withAlpha(100),
              ],
              stops: const [0.6, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.surface,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(50),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 45,
          backgroundColor: theme.colorScheme.surface,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Icon(
                  Icons.person,
                  size: 50,
                  color: theme.colorScheme.primary,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLoggedInHeader(
    BuildContext context,
    ThemeData theme,
    bool isWideScreen,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildUserInfoSection(context, theme),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: _buildUserStats(context, theme),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoSection(context, theme),
              ],
            ),
          if (description != null && description!.isNotEmpty)
            _buildDescription(context, theme),
          if (!isWideScreen) _buildUserStats(context, theme),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, ThemeData theme) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.only(left: 115),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                ...badgeRoles.map((role) => _buildBadgeRole(theme, role)),
              ],
            ),
            Text(
              '@$username${host != null ? '@$host' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (!isOwner && showFollowButton)
              Row(
                children: [
                  if (onFollowPressed != null)
                    FilledButton(
                      onPressed: onFollowPressed,
                      child: Text(followButtonText ?? '关注'),
                    ),
                  if (onMessagePressed != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: onMessagePressed,
                      child: const Text('发消息'),
                    ),
                  ],
                ],
              ),
            if (isOwner)
              FilledButton(
                onPressed: onLoginPressed,
                child: const Text('编辑资料'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRole(ThemeData theme, BadgeRole role) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary,
        ),
      ),
      child: Text(
        role.name,
        style: TextStyle(
          fontSize: 10,
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, ThemeData theme) {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final text = description!;
            final style = TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            );

            final textPainter = TextPainter(
              text: TextSpan(text: text, style: style),
              maxLines: 10,
              textDirection: ui.TextDirection.ltr,
            )..layout(maxWidth: constraints.maxWidth);

            final isOverflown = textPainter.didExceedMaxLines;

            if (isOverflown) {
              return InkWell(
                onTap: () => _showFullBioCard(context, text),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '查看完整简介',
                      style: style.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SelectableText(text, style: style);
          },
        ),
      ),
    );
  }

  void _showFullBioCard(BuildContext context, String bio) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '个人简介',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: SelectableText(
                      bio,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedOutHeader(BuildContext context, ThemeData theme) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '欢迎来到 Ottohub',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '登录以体验完整功能',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: theme.colorScheme.shadow.withAlpha(51),
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onLoginPressed,
            icon: const Icon(Icons.login),
            label: const Text('立即登录'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, ThemeData theme) {
    if (stats == null && joinedDate == null) {
      return const SizedBox.shrink();
    }

    final List<Widget> statsWidgets = [];

    if (joinedDate != null) {
      statsWidgets.add(
        _buildStatItem(
          theme,
          '加入时间',
          _formatDate(joinedDate!),
        ),
      );
    }

    if (stats != null) {
      if (stats!.notesCount != null) {
        statsWidgets.add(
          _buildStatItem(
            theme,
            '动态',
            _formatCount(stats!.notesCount!),
          ),
        );
      }
      if (stats!.followingCount != null) {
        statsWidgets.add(
          _buildStatItem(
            theme,
            '关注',
            _formatCount(stats!.followingCount!),
          ),
        );
      }
      if (stats!.followersCount != null) {
        statsWidgets.add(
          _buildStatItem(
            theme,
            '粉丝',
            _formatCount(stats!.followersCount!),
          ),
        );
      }
    }

    if (statsWidgets.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statsWidgets
          .map(
            (s) => Padding(padding: const EdgeInsets.only(right: 16), child: s),
          )
          .toList(),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatCount(int count) {
    if (count > 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class BadgeRole {
  final String name;
  final Color? color;

  const BadgeRole({
    required this.name,
    this.color,
  });
}

class UserStats {
  final int? notesCount;
  final int? followingCount;
  final int? followersCount;

  const UserStats({
    this.notesCount,
    this.followingCount,
    this.followersCount,
  });
}
