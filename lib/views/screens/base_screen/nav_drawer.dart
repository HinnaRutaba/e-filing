import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/assets_constants.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/services/version_sync_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _collapsedWidth = 76;
const double _effectiveExpandedWidth = 240;
const Duration _animDuration = Duration(milliseconds: 250);

/// User preference for the embedded nav drawer (tablet/desktop).
/// `null` means "use the device default": desktop → expanded, tablet → collapsed.
final navDrawerExpandedProvider = StateProvider<bool?>((ref) => null);

class NavDrawer extends ConsumerStatefulWidget {
  const NavDrawer({
    super.key,
    this.expanded,
    this.onToggle,
    this.alwaysExpanded = false,
  });

  /// When provided, the drawer is controlled externally.
  final bool? expanded;

  /// Called when the user taps the collapse/expand chevron.
  /// If null, the drawer manages its own state internally.
  final VoidCallback? onToggle;

  /// When true, the drawer is always fully expanded and no toggle is shown.
  /// Used for the mobile overlay drawer.
  final bool alwaysExpanded;

  @override
  ConsumerState<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends ConsumerState<NavDrawer> {
  bool _internalExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _effectiveExpanded {
    if (widget.alwaysExpanded) return true;
    return widget.expanded ?? _internalExpanded;
  }

  bool get _showToggle => !widget.alwaysExpanded;

  void _toggle() {
    if (widget.onToggle != null) {
      widget.onToggle!();
    } else {
      setState(() => _internalExpanded = !_internalExpanded);
    }
  }

  final List<DrawerMenu> menus = [
    DrawerMenu(
      title: "Dashboard",
      icon: Icons.dashboard,
      routeName: Routes.dashboard,
    ),
    DrawerMenu(title: "Chats", icon: Icons.chat, routeName: Routes.chats),
    DrawerMenu(
      title: "Daak Letters",
      icon: Icons.mark_email_unread_outlined,
      routeName: Routes.daak,
    ),
    DrawerMenu(
      title: "Pending Files",
      icon: Icons.event_repeat_rounded,
      routeName: Routes.pendingFiles,
    ),
    DrawerMenu(
      title: "Action Required",
      icon: Icons.file_open,
      routeName: Routes.actionRequiredFiles,
    ),
    DrawerMenu(
      title: "Forwarded Files",
      icon: Icons.send_time_extension_rounded,
      routeName: Routes.forwarded,
    ),
    DrawerMenu(
      title: "Summaries",
      icon: Icons.summarize_outlined,
      routeName: Routes.summaries,
    ),
    DrawerMenu(
      title: "Secretary Summary",
      icon: Icons.assignment_ind_outlined,
      routeName: Routes.cmDashboard, //Routes.secretarySummary,
    ),
    DrawerMenu(
      title: "Create New File",
      icon: Icons.add_link,
      routeName: Routes.createFile,
    ),
    DrawerMenu(
      title: "My Files",
      icon: Icons.receipt_long,
      routeName: Routes.myFiles,
    ),
    DrawerMenu(
      title: "Archived",
      icon: Icons.archive_sharp,
      routeName: Routes.archived,
    ),
    DrawerMenu(
      title: "Change Password",
      icon: Icons.lock_reset,
      routeName: Routes.changePassword,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    UserModel currentUser = ref.read(authController);
    final ChatService chatService = ChatService();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = context.appColors;
    final bool isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: _animDuration,
      curve: Curves.easeOut,
      width: _effectiveExpanded ? _effectiveExpandedWidth : _collapsedWidth,

      child: Material(
        color: theme.cardColor,
        elevation: 8,
        shadowColor: appColors.secondaryDark,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      appColors.secondaryDark.withValues(alpha: 0.9),
                      appColors.secondaryDark.withValues(alpha: 0.6),
                      theme.cardColor,
                      theme.cardColor,
                      theme.cardColor,
                    ]
                  : [
                      appColors.secondaryDark.withValues(alpha: 0.7),
                      colorScheme.secondary.withValues(alpha: 0.5),
                      appColors.secondaryLight.withValues(alpha: .3),
                      appColors.accent.withValues(alpha: .3),
                      appColors.surfaceMuted,
                      appColors.accent,
                    ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  primary: false,
                  child: Column(
                    children: [
                      ...menus.map(
                        (m) => _buildMenuItem(m, chatService, currentUser),
                      ),
                      if (_effectiveExpanded) _buildPoweredBy(),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
      child: Column(
        children: [
          if (_showToggle)
            Align(
              alignment: _effectiveExpanded
                  ? Alignment.centerRight
                  : Alignment.center,
              child: IconButton(
                tooltip: _effectiveExpanded ? 'Collapse' : 'Expand',
                onPressed: _toggle,
                icon: Icon(
                  _effectiveExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? context.appColors.secondaryLight
                      : context.appColors.secondaryDark,
                ),
              ),
            )
          else
            const SizedBox(height: 40),
          AnimatedSize(
            duration: _animDuration,
            curve: Curves.easeOut,
            child: Image.asset(
              AssetsConstants.logo,
              width: _effectiveExpanded ? 100 : 44,
              height: _effectiveExpanded ? 100 : 44,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    DrawerMenu menu,
    ChatService chatService,
    UserModel currentUser,
  ) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final bool isDark = theme.brightness == Brightness.dark;
    final bool isSelected = menu.routeName == RouteHelper.currentLocation;
    final Color fgColor = isSelected
        ? (isDark ? appColors.primaryLight : appColors.primaryDark)
        : (isDark ? appColors.secondaryLight : appColors.secondaryDark);
    final Color selectedBg = appColors.secondaryLight.withValues(
      alpha: isDark ? 0.25 : 0.2,
    );
    final bool isChats = menu.routeName == Routes.chats;

    void onTap() {
      if (menu.routeName != null) {
        RouteHelper.navigateTo(menu.routeName!);
      }
    }

    if (!_effectiveExpanded) {
      final iconWidget = Icon(menu.icon, color: fgColor, size: 22);
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Tooltip(
          message: menu.title,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: isChats
                    ? StreamBuilder<int>(
                        stream: chatService.getUnreadChatsCountStream(
                          userDesignationId:
                              currentUser.currentDesignation?.userDesgId,
                          userId: currentUser.id!,
                        ),
                        builder: (context, ss) {
                          final unread = ss.hasData ? (ss.data ?? 0) : 0;
                          return Badge(
                            isLabelVisible: unread > 0,
                            label: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: TextStyle(
                                color: appColors.accent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: theme.colorScheme.error,
                            child: iconWidget,
                          );
                        },
                      )
                    : iconWidget,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: isSelected ? selectedBg : Colors.transparent,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        leading: Icon(menu.icon, color: fgColor, size: 20),
        horizontalTitleGap: 12,
        title: isChats
            ? StreamBuilder<int>(
                stream: chatService.getUnreadChatsCountStream(
                  userDesignationId: currentUser.currentDesignation?.userDesgId,
                  userId: currentUser.id!,
                ),
                builder: (context, ss) {
                  final unread = ss.hasData ? (ss.data ?? 0) : 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.titleMedium("Chats", color: fgColor),
                      if (unread != 0)
                        AppText.labelMedium(
                          "$unread unread chat${unread > 1 ? 's' : ''}",
                          color: fgColor,
                        ),
                    ],
                  );
                },
              )
            : AppText.titleMedium(menu.title, color: fgColor),
        subtitle: menu.routeName == null
            ? AppText.bodyMedium(
                "Coming Soon",
                color: appColors.textSecondary.withValues(alpha: 0.6),
              )
            : null,
        onTap: menu.onTap ?? onTap,
      ),
    );
  }

  Widget _buildPoweredBy() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AppText.titleSmall("Powered By"),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(AssetsConstants.cmduLogo, height: 38),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(1.0),
                child: Image.asset(AssetsConstants.govtLogo, height: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        if (_effectiveExpanded)
          FutureBuilder(
            future: VersionSyncService().getAppVersionString(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: AppText.bodySmall(
                    "Version: ${snapshot.data}",
                    textAlign: TextAlign.center,
                    color: context.appColors.textSecondary,
                  ),
                );
              }
            },
          ),
        if (_effectiveExpanded)
          AppTextLinkButton(
            onPressed: () {
              ref.read(authController.notifier).logout(context);
            },
            text: "Sign Out",
            icon: Icons.logout,
            color: context.appColors.warning,
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Tooltip(
              message: 'Sign Out',
              child: IconButton(
                onPressed: () {
                  ref.read(authController.notifier).logout(context);
                },
                icon: Icon(Icons.logout, color: context.appColors.warning),
              ),
            ),
          ),
      ],
    );
  }
}

class DrawerMenu {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final String? routeName;
  final Widget? titleWidget;

  DrawerMenu({
    required this.title,
    required this.icon,
    this.onTap,
    this.titleWidget,
    required this.routeName,
  });
}
