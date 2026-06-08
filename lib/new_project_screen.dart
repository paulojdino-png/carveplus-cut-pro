import 'package:flutter/material.dart';
import 'parts_entry_screen.dart';
import 'project_settings.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final TextEditingController projectNameController = TextEditingController(
    text: 'New Project',
  );

  final TextEditingController sheetWidthController = TextEditingController(
    text: '1220',
  );

  final TextEditingController sheetLengthController = TextEditingController(
    text: '2440',
  );

  final TextEditingController thicknessController = TextEditingController(
    text: '18',
  );

  final TextEditingController borderMarginController = TextEditingController(
    text: '15',
  );

  final TextEditingController partSpacingController = TextEditingController(
    text: '10',
  );

  final TextEditingController edgeBandController = TextEditingController(
    text: '1',
  );

  String selectedMaterial = 'Plywood';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1120),
        elevation: 0,
        title: const Text('New Project', style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Project Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller: projectNameController,
              label: 'Project Name',
              isNumber: false,
            ),

            const SizedBox(height: 16),

            const Text(
              'Material',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: selectedMaterial,
              dropdownColor: const Color(0xFF1A2234),
              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A2234),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: const [
                DropdownMenuItem(value: 'Plywood', child: Text('Plywood')),
                DropdownMenuItem(value: 'MDF', child: Text('MDF')),
                DropdownMenuItem(value: 'Melamine', child: Text('Melamine')),
                DropdownMenuItem(value: 'PVC Board', child: Text('PVC Board')),
              ],

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedMaterial = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: sheetWidthController,
              label: 'Sheet Width (mm)',
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: sheetLengthController,
              label: 'Sheet Length (mm)',
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: thicknessController,
              label: 'Thickness (mm)',
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: borderMarginController,
              label: 'Border Margin (mm)',
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: partSpacingController,
              label: 'Part Spacing (mm)',
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: edgeBandController,
              label: 'Edge Band Thickness (mm)',
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 60,

              child: ElevatedButton(
                onPressed: () {
                  final settings = ProjectSettings(
                    projectName: projectNameController.text,
                    material: selectedMaterial,

                    sheetWidth:
                        double.tryParse(sheetWidthController.text) ?? 1220,

                    sheetLength:
                        double.tryParse(sheetLengthController.text) ?? 2440,

                    thickness: double.tryParse(thicknessController.text) ?? 18,

                    borderMargin:
                        double.tryParse(borderMarginController.text) ?? 15,

                    partSpacing:
                        double.tryParse(partSpacingController.text) ?? 10,

                    edgeBandThickness:
                        double.tryParse(edgeBandController.text) ?? 1,

                    allowRotation: true,
                    woodGrain: false,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PartsEntryScreen(settings: settings),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),

                    SizedBox(width: 8),

                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = true,
  }) {
    return TextField(
      controller: controller,

      keyboardType: isNumber ? TextInputType.number : TextInputType.text,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        labelText: label,

        labelStyle: const TextStyle(color: Colors.white70),

        filled: true,
        fillColor: const Color(0xFF1A2234),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
