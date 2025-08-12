import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/screens/chats/ai_agent_chat_screen.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/read_only_flag_attachment.dart';
import 'package:efiling_balochistan/views/screens/files/preview_file.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor_v2/quill_html_editor_v2.dart';

class FileDetailsScreen extends StatefulWidget {
  final int? fileId;
  const FileDetailsScreen({super.key, required this.fileId});

  @override
  State<FileDetailsScreen> createState() => _FileDetailsScreenState();
}

class _FileDetailsScreenState extends State<FileDetailsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final QuillEditorController quillEditorController = QuillEditorController();
  String? selectedFileType;
  bool showHtmlEditor = true;

  final String htmlContent = """
<p><strong>Subject:</strong> TESTING REOPEN THE FILE</p>

<p><strong>PROG/13333B<br>
FILE NO: ____/CMDU/ADMIN/2024</strong></p>

<p><strong>SUBJECT:</strong> asdasdsadasdasdasdasdasdassdasd</p>

<p>It is submitted that under the umbrella of E-Governance, a significant new initiative, the E-Filing System, has been developed by the Chief Minister Delivery Unit (CMDU) under your visionary leadership. This system was officially presented to the Hon’ble Chief Minister Balochistan on 12th November 2024, in the Small Conference Room of the Chief Minister Secretariat</p>

<p>The E-Filing System aims to transform traditional file handling by introducing a digital platform that ensures efficiency, transparency, and accountability. Key features of the system include:</p>

<ul>
<li><strong>Digital File Management:</strong> Automates file creation, tracking, and movement for seamless workflow management.</li>
<li><strong>Enhanced Accessibility:</strong> Provides real-time access to files and updates, enabling quicker decision-making.</li>
<li><strong>Data Security and Transparency:</strong> Includes robust encryption and a comprehensive audit trail to ensure secure and transparent file handling.</li>
<li><strong>Scalability and Adaptability:</strong> Designed to support deployment across all government departments, enhancing overall governance.</li>
</ul>

<p>Furthermore, it is submitted on the feedback received during the initial presentation, all suggested changes have been incorporated, and the system is now ready for deployment. As an initial step, it is proposed to deploy the E-Filing System in the Admin Section of the Chief Minister Secretariat as a pilot project. Upon successful implementation and evaluation, the system can be expanded to the entire Chief Minister Secretariat and eventually deployed across other government departments.</p>

<p>In this regard, it is kindly requested to approve the deployment of the E-Filing System in the Admin Section of the Chief Minister Secretariat as a pilot project and provide directions for its phased expansion.</p>

<p>Submitted for approval and further directions please</p>

<p>Haroon Khan<br>
(Programmer)<br>
08-08-2025<br>
CMDU Admin<br>
CMDU(ADMN)/93968H<br>
this file is forwarder reopen check</p>

<p>CMDU<br>
(CMDU Admin)<br>
08-08-2025<br>
Programmer<br>
PROG/64935S<br>
tis fle is apporve</p>

<p>Haroon Khan<br>
(Programmer)<br>
08-08-2025<br>
Programmer<br>
this file is resubmited</p>

<p>Haroon Khan<br>
(Programmer)<br>
08-08-2025<br>
CMDU Admin</p>
""";

  List<AddFlagAndAttachment> attachments = [const AddFlagAndAttachment()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.headlineSmall("File Details"),
        backgroundColor: AppColors.background,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppTextLinkButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.9),
                  showDragHandle: false,
                  isScrollControlled: true,
                  backgroundColor: AppColors.background,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: AIAgentChatScreen(
                        file: htmlContent,
                      ),
                    );
                  },
                );
              },
              text: "Ask AI",
              icon: Icons.auto_awesome,
              color: AppColors.secondaryDark,
              // textSize: 16,
              // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              header(Icons.text_snippet_outlined, "File"),
              const SizedBox(height: 16),
              PreviewFile(html: htmlContent),
              const SizedBox(height: 24),
              header(Icons.code, "File Description"),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.secondaryLight.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.white),
                  child: Column(
                    children: [
                      ToolBar(
                        activeIconColor: Colors.blue,
                        padding: const EdgeInsets.all(8),
                        iconSize: 24,
                        controller: quillEditorController,
                        toolBarConfig: const [
                          ToolBarStyle.bold,
                          ToolBarStyle.italic,
                          ToolBarStyle.underline,
                          //ToolBarStyle.listBullet,
                          ToolBarStyle.listOrdered,
                          ToolBarStyle.size,
                          ToolBarStyle.headerOne,
                          ToolBarStyle.headerTwo,
                          ToolBarStyle.link,
                          ToolBarStyle.align,
                          ToolBarStyle.color,
                          ToolBarStyle.blockQuote,
                          ToolBarStyle.codeBlock,
                          ToolBarStyle.addTable,
                          ToolBarStyle.editTable,
                        ],
                      ),
                      Divider(color: Colors.grey[300]!),
                      const SizedBox(height: 8),
                      Container(
                        child: showHtmlEditor
                            ? QuillHtmlEditor(
                                text: '',
                                hintText: "...",
                                autoFocus: true,
                                controller: quillEditorController,
                                minHeight: 270,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                hintTextStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                onEditorCreated: () {
                                  quillEditorController.requestFocus();
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppOutlineButton(
                    onPressed: () {
                      RouteHelper.push(Routes.fileChat(0));
                    },
                    text: "Start Discussion",
                    icon: Icons.chat,
                    color: AppColors.primaryDark,
                    textSize: 16,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  const SizedBox(width: 12),
                  AppOutlineButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.9),
                        showDragHandle: false,
                        isScrollControlled: true,
                        backgroundColor: AppColors.background,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return const Padding(
                            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: AIAgentChatScreen(),
                          );
                        },
                      );
                    },
                    text: "Draft with AI",
                    icon: Icons.drafts_rounded,
                    color: AppColors.secondary,
                    textSize: 16,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ReadOnlyFlagAttachmentList(
                header: header(Icons.flag_outlined, "Flags"),
                data: [
                  {"flagType": "A", "attachmentName": "document1.pdf"},
                  {"flagType": "B", "attachmentName": null},
                  {"flagType": "C", "attachmentName": "contract.pdf"},
                ],
              ),
              const SizedBox(height: 24),
              header(Icons.code, "Flag & Attachment"),
              const SizedBox(height: 16),
              ListView.builder(
                itemCount: attachments.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, i) {
                  return Column(
                    children: [
                      attachments[i],
                      if (i != attachments.length - 1)
                        Divider(
                          height: 40,
                          color: AppColors.secondaryLight.withOpacity(0.5),
                        )
                      else
                        const SizedBox(height: 12),
                    ],
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: AppOutlineButton(
                  onPressed: () {
                    setState(() {
                      attachments.add(
                        AddFlagAndAttachment(
                          onDelete: () {},
                        ),
                      );
                    });
                  },
                  text: "Add More",
                  color: AppColors.secondary,
                  textSize: 18,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 40),
              AppSolidButton(
                onPressed: () {
                  RouteHelper.navigateTo(Routes.dashboard);
                },
                text: "Submit",
                backgroundColor: AppColors.primary,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget header(IconData icon, String title) {
    return Row(
      children: [
        Card(
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: AppColors.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 24, color: AppColors.primaryDark),
          ),
        ),
        const SizedBox(width: 8),
        AppText.headlineSmall(
          title,
          color: AppColors.primaryDark,
        ),
      ],
    );
  }
}
