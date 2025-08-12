import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/utils/validators.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/chats/ai_agent_chat_screen.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/screens/files/preview_file.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_drop_down_field.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor_v2/quill_html_editor_v2.dart';

class CreateNewFileScreen extends StatefulWidget {
  const CreateNewFileScreen({super.key});

  @override
  State<CreateNewFileScreen> createState() => _CreateNewFileScreenState();
}

class _CreateNewFileScreenState extends State<CreateNewFileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController fileNo = TextEditingController();
  final TextEditingController partFileNo = TextEditingController();
  final TextEditingController fileMovementNo = TextEditingController();
  final TextEditingController subject = TextEditingController();

  final QuillEditorController quillEditorController = QuillEditorController();
  String? selectedFileType;
  bool showHtmlEditor = true;

  List<AddFlagAndAttachment> attachments = [const AddFlagAndAttachment()];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Create New File",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              header(Icons.text_snippet_outlined, "File Details"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppDropDownField(
                      items: ['PUC', 'Note'],
                      onChanged: (item) {
                        setState(() {
                          selectedFileType = item;
                        });
                      },
                      labelText: "File Type",
                      hintText: "Select file type",
                      itemBuilder: (item) {
                        return AppText.titleMedium(item ?? '');
                      },
                      validator: (item) {
                        if (selectedFileType == null ||
                            item == null ||
                            item.isEmpty) {
                          return 'Please select a file type';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: fileMovementNo,
                      labelText: "File Movement No",
                      hintText: "Auto generated",
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: fileNo,
                      labelText: "File No",
                      hintText: "Enter file number",
                      validator: Validators.notEmptyValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: partFileNo,
                      labelText: "Part File No",
                      hintText: "Enter if any",
                      //validator: Validators.notEmptyValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: subject,
                labelText: "File Subject",
                hintText: "Enter subject",
                validator: Validators.notEmptyValidator,
              ),
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
              Row(
                children: [
                  AppSolidButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.sizeOf(context).height * 0.9),
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
                            return SingleChildScrollView(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppText.headlineSmall(
                                          "File Preview",
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          RouteHelper.pop();
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const PreviewFile(),
                                  const SizedBox(height: 16),
                                  AppOutlineButton(
                                    onPressed: () {
                                      RouteHelper.pop();
                                    },
                                    text: "Close",
                                    color: AppColors.primaryDark,
                                    textSize: 18,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      text: "Preview"),
                  const SizedBox(width: 16),
                  AppSolidButton(
                    onPressed: () {
                      RouteHelper.navigateTo(Routes.dashboard);
                    },
                    text: "Submit",
                    backgroundColor: AppColors.secondary,
                  ),
                ],
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
