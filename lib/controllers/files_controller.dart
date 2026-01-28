import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/models/file_model.dart';
import 'package:efiling_balochistan/models/flag_model.dart';
import 'package:efiling_balochistan/models/forward_to.dart';
import 'package:efiling_balochistan/models/new_file_data_model.dart';
import 'package:efiling_balochistan/models/section_schema.dart';
import 'package:efiling_balochistan/repository/files/files_repo.dart';
import 'package:efiling_balochistan/views/screens/files/file_card.dart';
import 'package:efiling_balochistan/views/screens/files/file_details_screen.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/add_file_flag_and_attachmention.dart';
import 'package:efiling_balochistan/views/widgets/toast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FileViewModel {
  final List<FileModel> files;
  final List<FileModel> filteredFiles;
  final List<SectionModel> sections;
  final List<FlagModel> flags;
  final NewFileDataModel? newFileData;
  final bool loadingSections;
  final bool loadingForwardList;
  final bool loadingFlag;
  final bool loadingNewFileData;

  FileViewModel({
    this.files = const [],
    this.filteredFiles = const [],
    this.sections = const [],
    this.flags = const [],
    this.loadingFlag = true,
    this.loadingForwardList = true,
    this.loadingSections = true,
    this.newFileData,
    this.loadingNewFileData = true,
  });

  FileViewModel copyWith({
    List<FileModel>? files,
    List<FileModel>? filteredFiles,
    List<SectionModel>? sections,
    List<FlagModel>? flags,
    bool? loadingSections,
    bool? loadingForwardList,
    bool? loadingFlag,
    NewFileDataModel? newFileData,
    bool? loadingNewFileData,
  }) {
    return FileViewModel(
      files: files ?? this.files,
      filteredFiles: filteredFiles ?? this.filteredFiles,
      sections: sections ?? this.sections,
      flags: flags ?? this.flags,
      loadingSections: loadingSections ?? this.loadingSections,
      loadingForwardList: loadingForwardList ?? this.loadingForwardList,
      loadingFlag: loadingFlag ?? this.loadingFlag,
      newFileData: newFileData ?? this.newFileData,
      loadingNewFileData: loadingNewFileData ?? this.loadingNewFileData,
    );
  }

  getFilesByType(FileType actionRequired) {}
}

class FilesController extends BaseControllerState<FileViewModel> {
  FilesController(super.state, super.ref);

  FileRepo get repo => ref.read(filesRepo);

  Future<List<FileModel>> fetchFiles(FileType fileType,
      {bool showLoader = true}) async {
    List<FileModel> files = [];
    try {
      Future.delayed(Duration.zero, () {
        state = state.copyWith(
          files: files,
          filteredFiles: files,
        );
      });
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      if (showLoader) EasyLoading.show();
      if (fileType == FileType.pending) {
        files = await repo.fetchPendingFiles(designationId);
      } else if (fileType == FileType.my) {
        files = await repo.fetchMyFiles(designationId);
      } else if (fileType == FileType.actionRequired) {
        files = await repo.fetchActionReqFiles(designationId);
      } else if (fileType == FileType.forwarded) {
        files = await repo.fetchForwardedFiles(designationId);
      } else if (fileType == FileType.archived) {
        files = await repo.fetchArchivedFiles(designationId);
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
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      if (showLoader) EasyLoading.show();
      if (fileType == FileType.pending) {
        file = await repo.viewPendingFileDetails(fileId, designationId);
      } else if (fileType == FileType.my) {
        file = await repo.viewMyFileDetails(fileId, designationId);
      } else if (fileType == FileType.actionRequired) {
        file = await repo.viewActionReqFileDetails(fileId, designationId);
      } else if (fileType == FileType.forwarded) {
        file = await repo.viewForwardedFileDetails(fileId, designationId);
      } else if (fileType == FileType.archived) {
        file = await repo.viewArchivedFileDetails(fileId, designationId);
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
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      return await repo.generateFileMovNumber(designationId) ?? '';
    } catch (e) {
      Toast.error(message: handleException(e));
      return '';
    }
  }

  Future<List<SectionModel>> getSections({bool showLoader = false}) async {
    List<SectionModel> sections = [];
    state = state.copyWith(loadingSections: true);
    try {
      if (showLoader) EasyLoading.show();
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      sections = await repo.getSections(designationId);
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
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      forwardTo = await repo.getForwardList(sectionId, designationId);
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

  Future<List<FlagModel>> getFlags(
      {bool showLoader = false, bool onlyFinal = false}) async {
    List<FlagModel> flags = [];
    state = state.copyWith(loadingFlag: true);
    try {
      if (showLoader) EasyLoading.show();
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      flags = await repo.getFlags(designationId);
      if (onlyFinal) {
        flags = flags
            .where((f) => f.title?.toLowerCase() == "final attachment")
            .toList();
      }
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
      int? uid = await ref.read(authRepo).fetchLoggedInUserId();
      EasyLoading.show(status: "Adding Remarks...");
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      await repo.sendPendingFileRemarks(
        fileId: fileId,
        userId: uid!,
        content: content,
        forwardTo: forwardTo,
        fileMovNo: fileMovNo,
        lastTrackId: lastTrackId,
        flags: flags,
        designationId: designationId!,
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

  Future<void> submitFile({
    required int fileId,
    required String content,
    required int? forwardTo,
    required String fileMovNo,
    required FileAction action,
    required List<FlagAndAttachmentModel>? flags,
  }) async {
    try {
      int? uid = await ref.read(authRepo).fetchLoggedInUserId();
      EasyLoading.show(status: "Submitting...");
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      await repo.submitAction(
        fileId: fileId,
        userId: uid!,
        content: content,
        forwardTo: forwardTo,
        choice: action.value,
        flags: flags,
        designationId: designationId!,
      );
      //await fetchFiles(FileType.actionRequired);
      Toast.success(message: "File ${action.label} successfully.");
      EasyLoading.dismiss();
      RouteHelper.navigateTo(Routes.dashboard);
    } catch (e, s) {
      print("SUBMIT FILE ERROR______${e}____$s");
      Toast.error(message: handleException(e));
      EasyLoading.dismiss();
    }
  }

  Future<void> reopenFile({
    required int fileId,
    required String content,
    required int? forwardTo,
    required int? sectionId,
    required List<FlagAndAttachmentModel>? flags,
  }) async {
    try {
      EasyLoading.show();
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      await repo.reopenFile(
        fileId: fileId,
        sectionId: sectionId!,
        content: content,
        forwardTo: forwardTo!,
        flags: flags,
        designationId: designationId!,
      );
      //await fetchFiles(FileType.actionRequired);
      Toast.success(message: "File reopened successfully.");
      EasyLoading.dismiss();
      RouteHelper.navigateTo(Routes.dashboard);
    } catch (e, s) {
      print("Reopen FILE ERROR______${e}____$s");
      Toast.error(message: handleException(e));
      EasyLoading.dismiss();
    }
  }

  Future<NewFileDataModel?> getFileData({bool showLoader = false}) async {
    NewFileDataModel? data;
    state = state.copyWith(loadingNewFileData: true);
    try {
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      if (showLoader) EasyLoading.show();
      data = await repo.fetchCreateFileData(designationId);
      state = state.copyWith(newFileData: data, loadingNewFileData: false);
    } catch (e, s) {
      print("FILE DATA ERROR______${e}____$s");
      Toast.error(message: handleException(e));
      state = state.copyWith(loadingNewFileData: false);
    } finally {
      EasyLoading.dismiss();
    }
    return data;
  }

  Future<void> createFile({
    required String? subject,
    required int? fileType,
    required String? content,
    required int? forwardTo,
    required String? fileMovNumber,
    required String? fileNo,
    required String? partFileNumber,
    required int? tagId,
    required List<FlagAndAttachmentModel>? flags,
  }) async {
    try {
      EasyLoading.show();
      int? designationId =
          ref.read(authController).currentDesignation?.userDesgId;
      await repo.createNewFile(
        subject: subject!,
        fileType: fileType!,
        content: content!,
        forwardTo: forwardTo!,
        fileMovNumber: fileMovNumber!,
        refNumber: fileNo!,
        partFileNumber: partFileNumber!,
        tagId: tagId!,
        flags: flags,
        designationId: designationId!,
      );
      //await fetchFiles(FileType.actionRequired);
      Toast.success(message: "File created successfully.");
      EasyLoading.dismiss();
      RouteHelper.navigateTo(Routes.dashboard);
    } catch (e, s) {
      print("Create FILE ERROR______${e}____$s");
      Toast.error(message: handleException(e));
      EasyLoading.dismiss();
    }
  }
}
