import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'project_model.dart';
import 'new_project_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> loadProject() async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final file = File('${dir.path}/test.json');

      if (!await file.exists()) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('test.json not found')));
        return;
      }

      final jsonString = await file.readAsString();

      final project = Project.fromJson(jsonDecode(jsonString));

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Loaded: ${project.projectName}')));

      debugPrint('PROJECT LOADED: ${project.projectName}');
    } catch (e) {
      debugPrint('LOAD ERROR: $e');
    }
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

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2234),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Projects', style: TextStyle(color: Colors.white)),
                      ],
                    ),

                    Column(
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Materials',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewProjectScreen(),
                      ),
                    );
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

              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton(
                  onPressed: loadProject,

                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),

                  child: const Text(
                    'Load Project',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Recent Projects',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _projectTile('Kitchen Cabinet A'),
              _projectTile('Wardrobe Project'),
              _projectTile('TV Console'),

              const SizedBox(height: 30),

              const Text(
                'Quick Tools',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _menuButton(Icons.layers, 'Material Library'),
              _menuButton(Icons.history, 'Optimization History'),
              _menuButton(Icons.picture_as_pdf, 'DXF Exports'),
              _menuButton(Icons.settings, 'Settings'),

              const SizedBox(height: 20),

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

  static Widget _projectTile(String name) {
    return Card(
      color: const Color(0xFF1A2234),
      child: ListTile(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
      ),
    );
  }

  static Widget _menuButton(IconData icon, String title) {
    return Card(
      color: const Color(0xFF1A2234),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
      ),
    );
  }
}
