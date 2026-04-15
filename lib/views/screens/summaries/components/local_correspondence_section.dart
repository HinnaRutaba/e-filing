import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/daak_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LocalCorrespondenceSection extends StatelessWidget {
  final List<DaakModel> linkedDaak;
  final List<FileModel> linkedFiles;
  final ValueChanged<DaakModel>? onViewDaak;
  final ValueChanged<FileModel>? onViewFile;

  const LocalCorrespondenceSection({
    super.key,
    required this.linkedDaak,
    required this.linkedFiles,
    this.onViewDaak,
    this.onViewFile,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = linkedDaak.isEmpty && linkedFiles.isEmpty;

    return _sidebarShell(
      header: 'Internal Files / Local Correspondence',
      headerColor: AppColors.primaryDark,
      trailing: _countBadge(linkedDaak.length, linkedFiles.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isEmpty)
            AppText.bodySmall(
              'No local correspondence linked.',
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          if (linkedDaak.isNotEmpty) ...[
            _groupLabel('Linked Daak', linkedDaak.length),
            const SizedBox(height: 6),
            for (int i = 0; i < linkedDaak.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _daakTile(linkedDaak[i])
                  .animate()
                  .fadeIn(
                    delay: (80 * i).ms,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .slideX(
                    begin: -0.15,
                    end: 0,
                    delay: (80 * i).ms,
                    duration: 350.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ],
          if (linkedDaak.isNotEmpty && linkedFiles.isNotEmpty)
            const SizedBox(height: 12),
          if (linkedFiles.isNotEmpty) ...[
            _groupLabel('Linked Files', linkedFiles.length),
            const SizedBox(height: 6),
            for (int i = 0; i < linkedFiles.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _fileTile(linkedFiles[i])
                  .animate()
                  .fadeIn(
                    delay: (80 * (linkedDaak.length + i)).ms,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .slideX(
                    begin: -0.15,
                    end: 0,
                    delay: (80 * (linkedDaak.length + i)).ms,
                    duration: 350.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _countBadge(int daakCount, int fileCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.25),
        ),
      ),
      child: AppText.bodySmall(
        '$daakCount daak, $fileCount file(s)',
        color: AppColors.primaryDark,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _groupLabel(String label, int count) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        AppText.bodySmall(
          label.toUpperCase(),
          color: AppColors.secondaryDark,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
        const SizedBox(width: 6),
        AppText.bodySmall(
          '($count)',
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  Widget _daakTile(DaakModel daak) {
    final title = daak.diaryNo ?? daak.letterNo ?? '—';
    final subject = daak.subject ?? '';
    return _linkedTile(
      icon: Icons.mail_outline_rounded,
      iconColor: AppColors.secondary,
      title: title,
      subtitle: subject,
      onView: onViewDaak == null ? null : () => onViewDaak!(daak),
    );
  }

  Widget _fileTile(FileModel file) {
    final title = file.referenceNo ?? file.barcode ?? '—';
    final subject = file.subject ?? '';
    return _linkedTile(
      icon: Icons.folder_outlined,
      iconColor: AppColors.secondary,
      title: title,
      subtitle: subject,
      onView: onViewFile == null ? null : () => onViewFile!(file),
    );
  }

  Widget _linkedTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onView,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: iconColor.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodySmall(
                  title,
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (subtitle.isNotEmpty)
                  AppText.bodySmall(
                    subtitle,
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          if (onView != null) ...[
            const SizedBox(width: 8),
            _viewButton(onTap: onView),
          ],
        ],
      ),
    );
  }

  Widget _viewButton({required VoidCallback onTap}) {
    return Material(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.remove_red_eye_outlined,
                size: 13,
                color: AppColors.white,
              ),
              const SizedBox(width: 4),
              AppText.bodySmall(
                'View',
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sidebarShell({
    required String header,
    required Color headerColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryLight.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: headerColor.withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppText.bodyMedium(
                    header,
                    fontWeight: FontWeight.w700,
                    color: headerColor,
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}
