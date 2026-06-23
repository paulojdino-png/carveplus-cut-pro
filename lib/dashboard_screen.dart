import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'project_model.dart';
import 'new_project_screen.dart';
import 'parts_entry_screen.dart';
import 'edge_band_part.dart';
import 'project_settings.dart';
import 'projects_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> recentProjects = [];
  int projectCount = 0;
  @override
  void initState() {
    super.initState();
    loadRecentProjects();
  }

  Future<void> loadProject() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    if (!mounted) return;

    if (files.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No saved projects found')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Load Project'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];

                final jsonString = file.path
                    .split('/')
                    .last
                    .replaceAll('.json', '');

                return ListTile(
                  title: Text(jsonString),
                  onTap: () async {
                    final jsonText = await file.readAsString();

                    final project = Project.fromJson(jsonDecode(jsonText));

                    final settings = ProjectSettings(
                      projectName: project.projectName,
                      material: project.material,
                      sheetWidth: project.sheetWidth,
                      sheetLength: project.sheetLength,
                      thickness: project.thickness,
                      borderMargin: project.borderMargin,
                      partSpacing: project.partSpacing,
                      edgeBandThickness: project.edgeBandThickness,
                      allowRotation: true,
                      woodGrain: false,
                    );

                    final loadedParts = project.parts.map((p) {
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

                    if (context.mounted) {
                      Navigator.pop(context);
                    }

                    if (!mounted) return;

                    await Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => PartsEntryScreen(
                          settings: settings,
                          initialParts: loadedParts,
                        ),
                      ),
                    );
                    loadRecentProjects();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),

      appBar: AppBar(backgroundColor: const Color(0xFF0B1120), elevation: 0),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/carveplus_logo.png',
                      width: 160,
                      height: 160,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'CARVEPLUS CUT PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Optimize. Cut. Build.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),

                    const Text(
                      'Offline. Fast. Accurate.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewProjectScreen(),
                      ),
                    );

                    loadRecentProjects();
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),

                  child: const Text(
                    '+ New Project',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Recent Projects ($projectCount)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...recentProjects.map((name) => _projectTile(name)),
              const SizedBox(height: 8),

              Center(
                child: TextButton(
                  onPressed: () async {
                    final refreshed = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                    );

                    if (refreshed == true) {
                      await loadRecentProjects();
                    }
                  },
                  child: Text(
                    'View All Projects ($projectCount)',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2234),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.cloud_off, color: Colors.green),

                    SizedBox(width: 10),

                    Text(
                      'Offline Mode Ready',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadRecentProjects() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    setState(() {
      recentProjects = files
          .take(5)
          .map((f) => f.path.split('/').last.replaceAll('.json', ''))
          .toList();
      projectCount = files.length;
    });
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

                await loadRecentProjects();

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

  Widget _projectTile(String name) {
    return Card(
      color: const Color(0xFF1A2234),
      child: ListTile(
        title: Text(name, style: const TextStyle(color: Colors.white)),

        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),

        onTap: () async {
          final dir = await getApplicationDocumentsDirectory();

          final file = File('${dir.path}/$name.json');

          if (!await file.exists()) {
            return;
          }

          final jsonText = await file.readAsString();

          final project = Project.fromJson(jsonDecode(jsonText));

          final settings = ProjectSettings(
            projectName: project.projectName,
            material: project.material,
            sheetWidth: project.sheetWidth,
            sheetLength: project.sheetLength,
            thickness: project.thickness,
            borderMargin: project.borderMargin,
            partSpacing: project.partSpacing,
            edgeBandThickness: project.edgeBandThickness,
            allowRotation: true,
            woodGrain: false,
          );

          final loadedParts = project.parts.map((p) {
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

          if (!mounted) return;

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
        onLongPress: () async {
          showDeleteProjectDialog(name);
        },
      ),
    );
  }
}
