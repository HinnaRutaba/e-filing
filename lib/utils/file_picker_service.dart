import 'dart:io';

//import 'package:file_picker/file_picker.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
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

  Future<bool> checkPermission(Permission perm) async {
    print("SSSS______${await perm.status}");
    if (await perm.isGranted) return true;
    PermissionStatus permission = await perm.request();
    if (permission == PermissionStatus.granted) return true;
    await perm.request();
    Toast.error(message: "Kindly grant ${perm} for ACM");
    return false;
  }

  // Future<bool> getVideoPermission() async {
  //   if(await Permission.videos.isGranted) return true;
  //   PermissionStatus permission = await Permission.videos.request();
  //   if (permission == PermissionStatus.granted) return true;
  //   Toast.error(message: "Kindly grant Video permission for ACM");
  //   return false;
  // }
  //
  // Future<bool> getStoragePermission() async {
  //   if(await Permission.storage.isGranted) return true;
  //   PermissionStatus permission = await Permission.storage.request();
  //   if (permission == PermissionStatus.granted) return true;
  //   Toast.error(message: "Kindly grant Storage permission for ACM");
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
      EasyLoading.show(status: "Selecting files...");

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      await Future.delayed(Duration(milliseconds: 500));

      List<XFile> files = result?.xFiles ?? [];
      print('MEDIA_______${files.length}');

      EasyLoading.dismiss();

      // Filter files under 20MB
      final validFiles = <XFile>[];
      for (final file in files) {
        final fileLength = await file.length();
        if (bytesToMB(fileLength) <= 20) {
          validFiles.add(file);
        }
      }

      print('VALID_______${validFiles.length}');

      if (validFiles.length != files.length) {
        Toast.error(
            message: "Some files exceeded the 20MB limit and were not added.");
      }

      await Future.delayed(Duration(milliseconds: 500));

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
}
