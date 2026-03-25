import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/screens/daak/daak_correspondence_card.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slide_up_panel/slide_up_panel.dart';

class DaakDetailsScreen extends ConsumerStatefulWidget {
  final int? daakId;
  const DaakDetailsScreen({super.key, required this.daakId});

  @override
  ConsumerState<DaakDetailsScreen> createState() => _DaakDetailsScreenState();
}

class _DaakDetailsScreenState extends ConsumerState<DaakDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    double minHeight = MediaQuery.of(context).size.height * 0.11;
    double maxHeight = MediaQuery.of(context).size.height * 0.8;
    return SlideUpPanel(
      overLay: false,
      rounded: true,
      backGroundWidget: Scaffold(
        appBar: AppBar(
          title: Text('Daak Details - ID: ${widget.daakId}'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.headlineSmall(
                'Previous Correspondences',
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryDark,
              ),
              ...List.generate(
                2,
                (index) => DaakCorrespondenceCard(
                  status: index % 2 == 0 ? "Forwarded" : "Received",
                  statusColor: index % 2 == 0 ? Colors.orange : Colors.green,
                  dateTime: '2024-06-15 10:00 AM',
                  sender: 'Sender ${index + 1}',
                  department: 'Department ${index + 1}',
                  message: 'This is a message for correspondence ${index + 1}.',
                  isBold: index % 2 == 0,
                ),
              ),
            ],
          ),
        ),
      ),
      sliderWidget: Container(
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: AppColors.appBarColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryDark.withValues(alpha: .2),
              blurRadius: 8,
              offset: const Offset(0, -2.5),
            ),
          ],
        ),
        child: ListTile(
          visualDensity: VisualDensity.compact,
          leading: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(
              Icons.picture_as_pdf,
              color: Colors.red[700],
              size: 32,
            ),
          ),
          horizontalTitleGap: 12,
          titleAlignment: ListTileTitleAlignment.top,
          title: AppText.titleMedium(
            'Daak PDF title',
            fontWeight: FontWeight.w600,
          ),
          subtitle: AppText.labelLarge(
            'Received on: 2024-06-15',
          ),
          trailing: AppTextLinkButton(
            onPressed: () {},
            text: "Open",
          ),
        ),
      ),
      maxHeight: maxHeight,
      minHeight: minHeight,
    );
  }
}
