class Routes {
  Routes._();

  static const String root = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String createFile = '/createFile';
  static String fileDetails([fileId]) =>
      '/fileDetails/${fileId ?? ':${PathParams.fileId}'}';
  static String fileChat([fileId]) =>
      '/fileChat/${fileId ?? ':${PathParams.fileId}'}';
  static const String pendingFiles = '/pendingFiles';
  static const String myFiles = '/myFiles';
  static const String actionRequiredFiles = '/actionRequiredFiles';
  static const String archived = '/archived';
  static const String forwarded = '/forwarded';
  static const String settings = '/settings';
  static const String users = '/users';
  static const String sections = '/sections';
  static const String designations = '/designations';
  static const String changePassword = '/changePassword';

  // Sub Routes
  static const String profile = 'profile';
  static String complainById([id]) =>
      '/complain/${id ?? ':${PathParams.complainId}'}';
  static const String complainTracks = '/tracks';
}

class PathParams {
  PathParams._();

  static const String fileId = 'fileId';

  static const String complainId = 'complainId';
}
