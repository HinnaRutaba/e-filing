import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/daak/create_daak_model.dart';
import 'package:efiling_balochistan/models/daak/daak_departments_model.dart';
import 'package:efiling_balochistan/models/daak/daak_meta_model.dart';
import 'package:efiling_balochistan/models/department/department_model.dart';
import 'package:efiling_balochistan/utils/validators.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/attachment_picker_sheet.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/date_picker_text_field.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/search_drop_down_field.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ScanDaakScreen extends ConsumerStatefulWidget {
  const ScanDaakScreen({super.key});

  @override
  ConsumerState<ScanDaakScreen> createState() => _ScanDaakScreenState();
}

class _ScanDaakScreenState extends ConsumerState<ScanDaakScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController letterNoController = TextEditingController();
  final TextEditingController letterDateController = TextEditingController();
  final TextEditingController departmentSearchController =
      TextEditingController();
  final TextEditingController sourceDepartmentNameController =
      TextEditingController();
  final TextEditingController fwdToSearchController = TextEditingController();

  DaakDepartmentsModel? meta;
  bool loading = true;

  DepartmentModel? selectedDepartment;
  DepartmentUser? selectedFwdToUser;
  DateTime? selectedLetterDate;
  XFile? scanAttachment;

  bool get isOtherDepartment => selectedDepartment?.isOther == true;

  Future<void> fetchMeta() async {
    final DaakDepartmentsModel? data = await ref
        .read(daakController.notifier)
        .fetchCreateFormMeta();
    if (!mounted) return;
    setState(() {
      meta = data;
      loading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchMeta());
    super.initState();
  }

  @override
  void dispose() {
    subjectController.dispose();
    letterNoController.dispose();
    letterDateController.dispose();
    departmentSearchController.dispose();
    sourceDepartmentNameController.dispose();
    fwdToSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return GradientScaffold(
      child: BaseScreen(
        bgColor: Colors.transparent,
        isdash: false,
        title: "Scan Daak",
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.titleSmall(
                          "Letter Details",
                          color: appColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: subjectController,
                          labelText: "Subject",
                          hintText: "Enter subject",
                          isMandatory: true,
                          validator: Validators.notEmptyValidator,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: letterNoController,
                                labelText: "Letter Number (Optional)",
                                hintText: "Enter letter number",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DatePickerTextField(
                                config: TextFieldConfig(
                                  controller: letterDateController,
                                  labelText: "Letter Date (Optional)",
                                  hintText: "Select date",
                                ),
                                lastDate: DateTime.now(),
                                onDateSelected: (date) {
                                  setState(() => selectedLetterDate = date);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SearchDropDownField<DepartmentModel>(
                          controller: departmentSearchController,
                          labelText: "Received From Department",
                          hintText: "Search department",
                          isMandatory: true,
                          suggestionsCallback: (pattern) {
                            final q = pattern.toLowerCase();
                            return (meta?.departments ?? [])
                                .where(
                                  (d) =>
                                      (d.title ?? '').toLowerCase().contains(q),
                                )
                                .toList();
                          },
                          itemBuilder: (context, item) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: AppText.titleMedium(item.title ?? ''),
                          ),
                          onSelected: (item) {
                            setState(() {
                              selectedDepartment = item;
                              departmentSearchController.text =
                                  item.title ?? '';
                            });
                          },
                          validator: (_) {
                            if (selectedDepartment == null) {
                              return 'Please select a department';
                            }
                            return null;
                          },
                        ),
                        if (isOtherDepartment) ...[
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: sourceDepartmentNameController,
                            labelText: "External Agency Name",
                            hintText: "Enter the sending agency's name",
                            isMandatory: true,
                            validator: Validators.notEmptyValidator,
                          ),
                        ],
                        const SizedBox(height: 12),
                        SearchDropDownField<DepartmentUser>(
                          controller: fwdToSearchController,
                          labelText: "Forward To Department User",
                          hintText: "Search user",
                          isMandatory: true,
                          suggestionsCallback: (pattern) {
                            final q = pattern.toLowerCase();
                            return (meta?.departmentUsers ?? [])
                                .where(
                                  (u) =>
                                      (u.name ?? '').toLowerCase().contains(q),
                                )
                                .toList();
                          },
                          itemBuilder: (context, item) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.titleSmall(item.name ?? ''),
                                if ((item.designation ?? '').isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow[400],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.yellow[600]!.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: AppText.labelSmall(
                                      item.designation ?? '',
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          onSelected: (item) {
                            setState(() {
                              selectedFwdToUser = item;
                              fwdToSearchController.text = item.name ?? '';
                            });
                          },
                          validator: (_) {
                            if (selectedFwdToUser == null) {
                              return 'Please select a user';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            AppText.titleSmall(
                              "Scanned Letter (PDF Only)",
                              color: appColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            AppText.titleSmall(" *", color: Colors.red),
                          ],
                        ),

                        const SizedBox(height: 8),
                        DashedBorderBox(
                          color: appColors.accent.withValues(alpha: 0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () async {
                                    final file =
                                        await showAttachmentPickerSheet(
                                          context,
                                        );
                                    if (file != null) {
                                      setState(() => scanAttachment = file);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: appColors.border,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .fillColor
                                          ?.withValues(alpha: 0.2),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: appColors.surfaceMuted,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  bottomLeft: Radius.circular(
                                                    8,
                                                  ),
                                                ),
                                          ),
                                          child: AppText.bodyMedium(
                                            "Choose File",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: AppText.bodyMedium(
                                              scanAttachment?.name ??
                                                  "No file selected",
                                              color: appColors.textSecondary,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        if (scanAttachment != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () => scanAttachment = null,
                                                );
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AppText.labelMedium(
                                  "Only PDF files are allowed, or scan with your camera. Max size 10MB.",
                                  color: appColors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppSolidButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() != true) {
                              return;
                            }
                            if (scanAttachment == null) {
                              Toast.error(
                                message: "Attachment for daak is required",
                              );
                              return;
                            }
                            final model = CreateDaakModel(
                              subject: subjectController.text.trim(),
                              letterNo: letterNoController.text.trim().isEmpty
                                  ? null
                                  : letterNoController.text.trim(),
                              letterDate: selectedLetterDate,
                              sourceDepartmentId: selectedDepartment!.id,
                              sourceDepartmentName: isOtherDepartment
                                  ? sourceDepartmentNameController.text.trim()
                                  : null,
                              toSecretaryUserDesgId: selectedFwdToUser!.id,
                              incomingScan: scanAttachment,
                            );
                            await ref
                                .read(daakController.notifier)
                                .scanDaak(
                                  model: model,
                                  onSuccess: () =>
                                      RouteHelper.navigateTo(Routes.daak),
                                );
                          },
                          text: "Submit",
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class DashedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  const DashedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 12,
    this.strokeWidth = 1.2,
    this.dashWidth = 6,
    this.dashGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashGap: dashGap,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rRect);

    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashedPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashGap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashGap != oldDelegate.dashGap;
  }
}
