import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/utils/responsive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme toggle + unread-chats button shown on the right of the dashboard
/// user header. Shared by the standard and secretary dashboards.
class DashboardHeaderActions extends ConsumerStatefulWidget {
  const DashboardHeaderActions({super.key});

  @override
  ConsumerState<DashboardHeaderActions> createState() =>
      _DashboardHeaderActionsState();
}

class _DashboardHeaderActionsState
    extends ConsumerState<DashboardHeaderActions> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authController);
    final userId = currentUser.id;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThemeToggleButton(
          onTap: () => ref.read(themeController.notifier).toggle(),
          isDark: ref.watch(themeController) == ThemeMode.dark,
        ),
        const SizedBox(width: 8),
        if (userId != null)
          StreamBuilder<int>(
            stream: _chatService.getUnreadChatsCountStream(
              userDesignationId: currentUser.currentDesignation?.userDesgId,
              userId: userId,
            ),
            builder: (context, ss) {
              final unread = ss.hasData ? (ss.data ?? 0) : 0;
              if (context.isMobile) {
                return InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => RouteHelper.push(Routes.chats),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.appColors.accent.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Badge(
                      isLabelVisible: unread > 0,
                      label: Text(unread > 99 ? '99+' : '$unread'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      textColor: context.appColors.accent,
                      alignment: const Alignment(4, -1.8),
                      child: Icon(
                        Icons.chat_rounded,
                        color: context.appColors.accent,
                        size: 20,
                      ),
                    ),
                  ),
                );
              }
              return _UnreadMessagesPill(
                unread: unread,
                onTap: () => RouteHelper.push(Routes.chats),
              );
            },
          ),
      ],
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeToggleButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.accent.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) =>
              RotationTransition(turns: animation, child: child),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey<bool>(isDark),
            color: context.appColors.accent,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _UnreadMessagesPill extends StatefulWidget {
  final int unread;
  final VoidCallback onTap;

  const _UnreadMessagesPill({required this.unread, required this.onTap});

  @override
  State<_UnreadMessagesPill> createState() => _UnreadMessagesPillState();
}

class _UnreadMessagesPillState extends State<_UnreadMessagesPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconIn;
  late final Animation<double> _textReveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _iconIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
    );
    _textReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = widget.unread;
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(10),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final revealValue = _textReveal.value.clamp(0.0, 1.0);
            final iconValue = _iconIn.value.clamp(0.0, 1.0);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: revealValue,
                    child: Opacity(
                      opacity: revealValue,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: context.appColors.accent,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'You have '),
                              TextSpan(
                                text: '$unread',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: unread == 1
                                    ? ' new message'
                                    : ' new messages',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: iconValue,
                  child: Opacity(
                    opacity: iconValue,
                    child: Icon(
                      Icons.chat_rounded,
                      color: context.appColors.accent,
                      size: 22,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
