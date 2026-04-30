import 'dart:convert';
import 'dart:io';

import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pencil_kit/pencil_kit.dart';

class SecretarySummaryScreen extends StatefulWidget {
  const SecretarySummaryScreen({super.key});

  @override
  State<SecretarySummaryScreen> createState() => _SecretarySummaryScreenState();
}

class _SecretarySummaryScreenState extends State<SecretarySummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      isdash: false,
      title: 'Secretary Summary',
      body: Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: HandwritingPage(),
      ),
    );
  }
}

class HandwritingPage extends StatefulWidget {
  const HandwritingPage({super.key});

  @override
  State<HandwritingPage> createState() => _HandwritingPageState();
}

class _HandwritingPageState extends State<HandwritingPage> {
  late final PencilKitController controller;
  ToolType currentToolType = ToolType.pen;
  double currentWidth = 1;
  Color currentColor = Colors.black;
  String base64Image = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      final Directory documentDir =
                          await getApplicationDocumentsDirectory();
                      final String pathToSave = '${documentDir.path}/drawing';
                      try {
                        final data = await controller.save(
                          uri: pathToSave,
                          withBase64Data: true,
                        );
                        if (kDebugMode) {
                          print(data);
                        }
                        Toast.show(message: "Save Success to [$pathToSave]");
                      } catch (e) {
                        Toast.show(message: "Save Failed to [$pathToSave]");
                      }
                    },
                    tooltip: "Save",
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      final Directory documentDir =
                          await getApplicationDocumentsDirectory();
                      final String pathToLoad = '${documentDir.path}/drawing';
                      try {
                        final data = await controller.load(
                          uri: pathToLoad,
                          withBase64Data: true,
                        );
                        if (kDebugMode) {
                          print(data);
                        }
                        Toast.show(message: "Load Success from [$pathToLoad]");
                      } catch (e) {
                        Toast.show(message: "Load Failed from [$pathToLoad]");
                      }
                    },
                    tooltip: "Load",
                  ),
                  IconButton(
                    icon: const Icon(Icons.print),
                    onPressed: () async {
                      final data = await controller.getBase64Data();
                      Toast.show(message: data);
                    },
                    tooltip: "Get base64 data",
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      final data = await controller.getBase64PngData();
                      setState(() {
                        base64Image = data;
                      });
                    },
                    tooltip: "Get base64 png data",
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () async {
                      final data = await controller.getBase64JpegData();
                      setState(() {
                        base64Image = data;
                      });
                    },
                    tooltip: "Get base64 jpeg data",
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                          ToolType.pen,
                          ToolType.pencil,
                          ToolType.marker,
                          ToolType.monoline,
                          ToolType.fountainPen,
                          ToolType.watercolor,
                          ToolType.crayon,
                        ]
                        .map(
                          (e) => TextButton(
                            onPressed: () {
                              setState(() {
                                currentToolType = e;
                                controller.setPKTool(
                                  toolType: e,
                                  width: currentWidth,
                                  color: currentColor,
                                );
                              });
                            },
                            child: Text(
                              '${e.name}${e.isAvailableFromIos17 ? ' (iOS17)' : ''}',
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentToolType = ToolType.eraserVector;
                        controller.setPKTool(
                          toolType: currentToolType,
                          width: currentWidth,
                          color: currentColor,
                        );
                      });
                    },
                    child: const Text('Vector Eraser'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentToolType = ToolType.eraserBitmap;
                        controller.setPKTool(
                          toolType: currentToolType,
                          width: currentWidth,
                          color: currentColor,
                        );
                      });
                    },
                    child: const Text('Bitmap Eraser'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentToolType = ToolType.eraserFixedWidthBitmap;
                        controller.setPKTool(
                          toolType: currentToolType,
                          width: currentWidth,
                          color: currentColor,
                        );
                      });
                    },
                    child: const Text('FixedWidthBitmap Eraser(iOS 16.4)'),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    icon: Container(color: Colors.black, width: 12, height: 1),
                    onPressed: () {
                      setState(() {
                        currentWidth = 1;
                        controller.setPKTool(
                          toolType: currentToolType,
                          width: currentWidth,
                          color: currentColor,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: Container(color: Colors.black, width: 12, height: 3),
                    onPressed: () {
                      setState(() {
                        currentWidth = 3;
                        controller.setPKTool(
                          toolType: currentToolType,
                          width: currentWidth,
                          color: currentColor,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: Container(color: Colors.black, width: 12, height: 5),
                    onPressed: () {
                      setState(() {
                        currentWidth = 5;
                        controller.setPKTool(
                          toolType: currentToolType,
                          width: currentWidth,
                          color: currentColor,
                        );
                      });
                    },
                  ),
                  const VerticalDivider(),
                  IconButton(
                    icon: const Icon(Icons.lens, color: Colors.orange),
                    onPressed: () {
                      setState(() {
                        currentColor = Colors.orange;
                        controller.setPKTool(
                          toolType: currentToolType,
                          width: currentWidth,
                          color: currentColor,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.lens, color: Colors.purpleAccent),
                    onPressed: () {
                      setState(() {
                        currentColor = Colors.purpleAccent;
                        controller.setPKTool(
                          toolType: currentToolType,
                          width: currentWidth,
                          color: currentColor,
                        );
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.lens, color: Colors.greenAccent),
                    onPressed: () {
                      setState(() {
                        currentColor = Colors.greenAccent;
                        controller.setPKTool(
                          toolType: currentToolType,
                          width: currentWidth,
                          color: currentColor,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PencilKit(
                onPencilKitViewCreated: (controller) =>
                    this.controller = controller,
                alwaysBounceVertical: false,
                alwaysBounceHorizontal: true,
                isRulerActive: false,
                drawingPolicy: PencilKitIos14DrawingPolicy.anyInput,
                backgroundColor: Colors.yellow.withValues(alpha: 0.1),
                isOpaque: false,
                // toolPickerVisibilityDidChange: (isVisible) =>
                //     print('toolPickerVisibilityDidChange $isVisible'),
                // toolPickerIsRulerActiveDidChange: (isRulerActive) =>
                //     print('toolPickerIsRulerActiveDidChange $isRulerActive'),
                // toolPickerFramesObscuredDidChange: () =>
                //     print('toolPickerFramesObscuredDidChange'),
                // toolPickerSelectedToolDidChange: () =>
                //     print('toolPickerSelectedToolDidChange'),
                // canvasViewDidBeginUsingTool: () =>
                //     print('canvasViewDidBeginUsingTool'),
                // canvasViewDidEndUsingTool: () =>
                //     print('canvasViewDidEndUsingTool'),
                // canvasViewDrawingDidChange: () =>
                //     print('canvasViewDrawingDidChange'),
                // canvasViewDidFinishRendering: () =>
                //     print('canvasViewDidFinishRendering'),
              ),
            ),
          ],
        ),
        if (base64Image.isNotEmpty)
          Positioned(
            bottom: 128,
            right: 24,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: Colors.black12),
              ),
              child: Image.memory(base64Decode(base64Image)),
            ),
          ),
      ],
    );
  }
}
