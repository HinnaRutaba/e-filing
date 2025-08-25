import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/models/forward_to.dart';
import 'package:efiling_balochistan/models/section_schema.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/files/files_repo.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FileViewModel {
  final List<FileModel> files;
  final List<FileModel> filteredFiles;
  final List<SectionModel> sections;
  final List<FlagModel> flags;
  final bool loadingSections;
  final bool loadingForwardList;
  final bool loadingFlag;

  FileViewModel({
    this.files = const [],
    this.filteredFiles = const [],
    this.sections = const [],
    this.flags = const [],
    this.loadingFlag = true,
    this.loadingForwardList = true,
    this.loadingSections = true,
  });

  FileViewModel copyWith({
    List<FileModel>? files,
    List<FileModel>? filteredFiles,
    List<SectionModel>? sections,
    List<FlagModel>? flags,
    bool? loadingSections,
    bool? loadingForwardList,
    bool? loadingFlag,
  }) {
    return FileViewModel(
      files: files ?? this.files,
      filteredFiles: filteredFiles ?? this.filteredFiles,
      sections: sections ?? this.sections,
      flags: flags ?? this.flags,
      loadingSections: loadingSections ?? this.loadingSections,
      loadingForwardList: loadingForwardList ?? this.loadingForwardList,
      loadingFlag: loadingFlag ?? this.loadingFlag,
    );
  }
}

class FilesController extends BaseControllerState<FileViewModel> {
  FilesController(super.state, super.ref);

  FileRepo get repo => ref.read(filesRepo);

  Future<List<FileModel>> fetchFiles(FileType fileType) async {
    List<FileModel> files = [];
    try {
      Future.delayed(Duration.zero, () {
        state = state.copyWith(
          files: files,
          filteredFiles: files,
        );
      });
      EasyLoading.show();
      if (fileType == FileType.pending) {
        files = await repo.fetchPendingFiles();
      } else if (fileType == FileType.my) {
        files = await repo.fetchMyFiles();
      } else if (fileType == FileType.actionRequired) {
        files = await repo.fetchActionReqFiles();
      }
      state = state.copyWith(
        files: files,
        filteredFiles: files,
      );
    } catch (e, s) {
      print("ERROR GETTING FILES______${e}____$s");
      Toast.error(message: handleException(e));
    } finally {
      EasyLoading.dismiss();
    }
    return files;
  }

  void filterFiles(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredFiles: state.files);
    } else {
      final filtered = state.files.where((file) {
        return file.referenceNo?.toLowerCase().contains(query.toLowerCase()) ==
                true ||
            file.fileType?.toLowerCase().contains(query.toLowerCase()) ==
                true ||
            file.barcode?.toLowerCase().contains(query.toLowerCase()) == true ||
            file.subject?.toLowerCase().contains(query.toLowerCase()) == true;
      }).toList();
      state = state.copyWith(filteredFiles: filtered);
    }
  }

  Future<FileDetailsModel?> fetchFileDetails(int fileId, FileType fileType,
      {bool showLoader = false}) async {
    FileDetailsModel? file;
    try {
      if (showLoader) EasyLoading.show();
      if (fileType == FileType.pending) {
        file = await repo.viewPendingFileDetails(fileId);
      } else if (fileType == FileType.my) {
        file = await repo.viewMyFileDetails(fileId);
      } else if (fileType == FileType.actionRequired) {
        file = await repo.viewActionReqFileDetails(fileId);
      }
    } catch (e, s) {
      print("FILE DETAILS DETAILS______${e}____$s");
      Toast.error(message: handleException(e));
    } finally {
      EasyLoading.dismiss();
    }
    return file;
  }

  Future<String> autoGenerateFileMovNumber() async {
    try {
      return await repo.generateFileMovNumber() ?? '';
    } catch (e, s) {
      Toast.error(message: handleException(e));
      return '';
    }
  }

  Future<List<SectionModel>> getSections({bool showLoader = false}) async {
    List<SectionModel> sections = [];
    state = state.copyWith(loadingSections: true);
    try {
      if (showLoader) EasyLoading.show();
      sections = await repo.getSections();
      state = state.copyWith(sections: sections, loadingSections: false);
    } catch (e, s) {
      print("SECTIONS ERROR______${e}____$s");
      Toast.error(message: handleException(e));
      state = state.copyWith(loadingSections: false);
    } finally {
      EasyLoading.dismiss();
    }
    return sections;
  }

  Future<List<ForwardToModel>> getForwardTo(int? sectionId,
      {bool showLoader = false}) async {
    List<ForwardToModel> forwardTo = [];
    state = state.copyWith(loadingForwardList: true);
    try {
      if (showLoader) EasyLoading.show();
      forwardTo = await repo.getForwardList(sectionId);
      state = state.copyWith(loadingForwardList: false);
    } catch (e, s) {
      print("FORWARD TO ERROR______${e}____$s");
      Toast.error(message: handleException(e));
      state = state.copyWith(loadingForwardList: false);
    } finally {
      EasyLoading.dismiss();
    }
    return forwardTo;
  }

  Future<List<FlagModel>> getFlags({bool showLoader = false}) async {
    List<FlagModel> flags = [];
    state = state.copyWith(loadingFlag: true);
    try {
      if (showLoader) EasyLoading.show();
      flags = await repo.getFlags();
      state = state.copyWith(flags: flags, loadingFlag: false);
    } catch (e, s) {
      print("FLAGS ERROR______${e}____$s");
      Toast.error(message: handleException(e));
      state = state.copyWith(loadingFlag: false);
    } finally {
      EasyLoading.dismiss();
    }
    return flags;
  }

  Future<void> sendPendingFileRemarks({
    required int fileId,
    required String content,
    required int forwardTo,
    required String fileMovNo,
    required int lastTrackId,
    required List<FlagAndAttachmentModel>? flags,
  }) async {
    try {
      UserModel? user = await ref.read(authRepo).fetchCurrentUserDetails();
      EasyLoading.show(status: "Adding Remarks...");
      await repo.sendPendingFileRemarks(
        fileId: fileId,
        userId: user!.id!,
        content: content,
        forwardTo: forwardTo,
        fileMovNo: fileMovNo,
        lastTrackId: lastTrackId,
        flags: flags,
      );
      //await fetchFiles(FileType.pending);
      Toast.success(message: "File forwarded and remarks added successfully.");
      EasyLoading.dismiss();
      RouteHelper.navigateTo(Routes.dashboard);
    } catch (e, s) {
      print("SEND PENDING FILE ERROR______${e}____$s");
      Toast.error(message: handleException(e));
      EasyLoading.dismiss();
    }
  }
}
