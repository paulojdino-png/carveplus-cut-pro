import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'edge_band_part.dart';
import 'parts_entry_screen.dart';
import 'project_model.dart';
import 'project_settings.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<String> projects = [];
  List<String> filteredProjects = [];

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    setState(() {
      projects = files
          .map((f) => f.path.split('/').last.replaceAll('.json', ''))
          .toList();

      filteredProjects = List.from(projects);
    });
  }

  Future<void> showProjectOptions(String projectName) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Project Options'),
          content: Text(projectName),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                showRenameDialog(projectName);
              },
              child: const Text('Rename'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                showDeleteProjectDialog(projectName);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showRenameDialog(String oldName) async {
    final controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Project'),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Project Name'),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () async {
                final dir = await getApplicationDocumentsDirectory();

                final oldFile = File('${dir.path}/$oldName.json');

                final newFile = File('${dir.path}/${controller.text}.json');

                if (await oldFile.exists()) {
                  await oldFile.rename(newFile.path);
                }

                await loadProjects();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDeleteProjectDialog(String projectName) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Project'),

          content: Text('Delete "$projectName"?'),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () async {
                final dir = await getApplicationDocumentsDirectory();

                final file = File('${dir.path}/$projectName.json');

                if (await file.exists()) {
                  await file.delete();
                }

                await loadProjects();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001B2E),

      appBar: AppBar(
        title: Text('Projects (${projects.length})'),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintStyle: const TextStyle(color: Colors.white54),
                hintText: 'Search Projects',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),

              onChanged: (value) {
                setState(() {
                  filteredProjects = projects
                      .where(
                        (project) =>
                            project.toLowerCase().contains(value.toLowerCase()),
                      )
                      .toList();
                });
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                final project = filteredProjects[index];

                return ListTile(
                  title: Text(
                    project,
                    style: const TextStyle(color: Colors.white),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green,
                  ),

                  onTap: () async {
                    final dir = await getApplicationDocumentsDirectory();

                    final file = File('${dir.path}/$project.json');

                    if (!await file.exists()) {
                      return;
                    }

                    final jsonText = await file.readAsString();

                    final projectData = Project.fromJson(jsonDecode(jsonText));
                    final settings = ProjectSettings(
                      projectName: projectData.projectName,
                      material: projectData.material,
                      sheetWidth: projectData.sheetWidth,
                      sheetLength: projectData.sheetLength,
                      thickness: projectData.thickness,
                      borderMargin: projectData.borderMargin,
                      partSpacing: projectData.partSpacing,
                      edgeBandThickness: projectData.edgeBandThickness,
                      allowRotation: true,
                      woodGrain: false,
                    );
                    final loadedParts = projectData.parts.map((p) {
                      return EdgeBandPart(
                        name: p.name,
                        width: p.width.toString(),
                        height: p.height.toString(),
                        qty: p.quantity.toString(),
                        top: p.topEdge,
                        bottom: p.bottomEdge,
                        left: p.leftEdge,
                        right: p.rightEdge,
                      );
                    }).toList();
                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PartsEntryScreen(
                          settings: settings,
                          initialParts: loadedParts,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showProjectOptions(project);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
