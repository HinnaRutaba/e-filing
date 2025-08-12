import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/search_drop_down_field.dart';
import 'package:flutter/material.dart';

class ActionRequiredFilesScreen extends StatefulWidget {
  const ActionRequiredFilesScreen({super.key});

  @override
  State<ActionRequiredFilesScreen> createState() =>
      _ActionRequiredFilesScreenState();
}

class _ActionRequiredFilesScreenState extends State<ActionRequiredFilesScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: "Action Required",
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            SearchDropDownField(
                suggestionsCallback: (String pattern) {
                  // Simulate a search operation
                  return Future.value([]);
                },
                onSelected: (void value) {
                  // Handle the selected value
                },
                showLabel: false,
                labelText: "Search",
                hintText: "Search by file name or number",
                itemBuilder: (BuildContext context, void item) {
                  // Build the item widget
                  return ListTile(
                    title: Text("Item"), // Customize as needed
                  );
                }),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemBuilder: (ctx, i) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: FileCard(
                    fileType: FileType.actionRequired,
                  ),
                ),
                itemCount: 10,
                physics: const BouncingScrollPhysics(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
