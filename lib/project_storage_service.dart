import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'project_model.dart';

class ProjectStorageService {
  static Future<File> saveProject(Project project) async {
    final dir = await getApplicationDocumentsDirectory();

    final safeName = project.projectName
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\-]'), '');

    final file = File('${dir.path}/$safeName.cpcp');

    await file.writeAsString(jsonEncode(project.toJson()));

    return file;
  }

  static Future<Project> loadProject(File file) async {
    final jsonString = await file.readAsString();

    final jsonMap = jsonDecode(jsonString);

    return Project.fromJson(jsonMap);
  }
}
