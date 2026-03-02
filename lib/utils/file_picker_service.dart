import 'dart:developer';
import 'dart:io';

//import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

//export 'package:file_picker/file_picker.dart' show FileType;

class FilePickerService {
  final picker = ImagePicker();

  static const List<String> imageExt = [
    'jpg',
    'jpeg',
    'png',
  ];

  static const List<String> videoExt = [
    'mp4',
    'avi',
    'mov',
  ];

  static const List<String> allowedExtensions = [
    'mp3',
    'wav',
    'ogg',
    'm4a',
    'aac',
    'mp4',
    'mpeg',
    'mpga',
    'webm',
    'avi',
    'mov',
    'mkv',
    'flv',
    'wmv',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'svg',
    'webp',
    'bmp',
    'heic',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'csv'
  ];

  Future<bool> checkPermission(Permission perm) async {
    if (await perm.isGranted) return true;
    PermissionStatus permission = await perm.request();
    if (permission == PermissionStatus.granted) return true;
    await perm.request();
    Toast.error(message: "Kindly grant ${perm} for E-Filing");
    return false;
  }

  // Future<bool> getVideoPermission() async {
  //   if(await Permission.videos.isGranted) return true;
  //   PermissionStatus permission = await Permission.videos.request();
  //   if (permission == PermissionStatus.granted) return true;
  //   Toast.error(message: "Kindly grant Video permission for E-Filing");
  //   return false;
  // }
  //
  // Future<bool> getStoragePermission() async {
  //   if(await Permission.storage.isGranted) return true;
  //   PermissionStatus permission = await Permission.storage.request();
  //   if (permission == PermissionStatus.granted) return true;
  //   Toast.error(message: "Kindly grant Storage permission for E-Filing");
  //   return false;
  // }

  Future<List<XFile>> imagePick(ImageSource source,
      {bool isMultiImage = false}) async {
    List<XFile> images = [];
    final ImagePicker picker = ImagePicker();
    if (isMultiImage) {
      try {
        List<XFile>? pickedFiles =
            await picker.pickMultiImage(imageQuality: 35);
        if (pickedFiles.isNotEmpty) {
          images.addAll(pickedFiles);
        }
      } catch (e) {
        print('Error picking multiple images: $e');
      }
    } else {
      try {
        XFile? pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 35,
        );
        if (pickedFile != null) {
          images.add(pickedFile);
        }
      } catch (e) {
        rethrow;
      }
    }
    return images;
  }

  Future<XFile?> pickPdf() async {
    XFile? picked;
    try {
      EasyLoading.show(status: "Selecting files...");

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      EasyLoading.dismiss();

      if (result != null && result.files.isNotEmpty) {
        picked = result.xFiles.first;
      }
    } catch (e, s) {
      EasyLoading.dismiss();
      print("Error picking files: $e\n$s");
    }

    return picked;
  }

  Future<List<XFile>> pickMedia() async {
    List<XFile> pickedFiles = [];

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      List<XFile> files = result?.xFiles ?? [];

      EasyLoading.dismiss();

      // Filter files under 60MB (61440 KB)
      final validFiles = <XFile>[];
      for (final file in files) {
        final fileLength = await file.length();
        if (fileLength <= 61440 * 1024) {
          validFiles.add(file);
        }
      }

      if (validFiles.length != files.length) {
        Toast.error(
            message: "Some files exceeded the 60MB limit and were not added.");
      }

      await Future.delayed(const Duration(milliseconds: 200));

      pickedFiles.addAll(validFiles);
    } catch (e, s) {
      EasyLoading.dismiss();
      print("Error picking media: $e\n$s");
    }
    return pickedFiles;
  }

  double bytesToMB(int bytes) {
    const int bytesInMB = 1024 * 1024;
    return bytes / bytesInMB;
  }

  Future<XFile?> compressPhoto(XFile? image, String? id) async {
    if (kIsWeb) return image;
    if (image != null) {
      final tempDirectory = await getTemporaryDirectory();
      img.Image? mImageFile = img.decodeImage(await image.readAsBytes());
      if (mImageFile == null) return null;
      final compressedImageFile = XFile("${tempDirectory.path}/img_$id.jpg");
      return compressedImageFile;
    }
    return null;
  }

  Future<File> fileFromImageUrl(String networkImage) async {
    String picId = const Uuid().v4();
    final response = await http.get(Uri.parse(networkImage));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(p.join(documentDirectory.path, '$picId.jpg'));

    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  Future<void> downloadFile(
      BuildContext context, fileUrl, String fileName) async {
    try {
      // For Android 10+ (API 29+), storage permission is not needed for app-specific directories
      // or the Downloads folder. Only request permission for older Android versions.
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt < 29) {
          // Android 9 and below: need storage permission
          final permission = Permission.storage;
          PermissionStatus status = await permission.status;

          if (status.isDenied || status.isLimited) {
            final result = await permission.request();
            if (!result.isGranted) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Storage permission is required to download files'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          } else if (status.isPermanentlyDenied) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'Storage permission is permanently denied. Please enable it in app settings.'),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Settings',
                    textColor: Colors.white,
                    onPressed: () => openAppSettings(),
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
            return;
          }
        }
        // Android 10+: No permission needed for Downloads folder
      }

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        // Use Downloads directory - works without permission on Android 10+
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Could not access storage directory');
      }

      // Create E-Filing folder
      final eFilingDir = Directory('${downloadsDir.path}/E-Filing');
      if (!await eFilingDir.exists()) {
        await eFilingDir.create(recursive: true);
      }

      // Prepare file path
      final filePath = '${eFilingDir.path}/$fileName';
      final file = File(filePath);

      // Show downloading snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading $fileName...'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.secondary,
          ),
        );
      }

      final dio = Dio();
      await dio.download(fileUrl, filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded $fileName to E-Filing folder'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open Folder',
              textColor: Colors.white,
              onPressed: () async {
                final folderPath = File(filePath).parent.path;
                final result = await OpenFile.open(folderPath);
                if (result.type != ResultType.done) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Could not open folder: ${result.message}'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, s) {
      log('Download error: ${e}______$s');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download $fileName: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
