import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'project_model.dart';

import 'optimization_screen.dart';
import 'edge_band_part.dart';
import 'project_settings.dart';

class PartsEntryScreen extends StatefulWidget {
  final ProjectSettings settings;

  const PartsEntryScreen({super.key, required this.settings});

  @override
  State<PartsEntryScreen> createState() => _PartsEntryScreenState();
}

class _PartsEntryScreenState extends State<PartsEntryScreen> {
  final partNameController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final qtyController = TextEditingController(text: '1');

  final List<EdgeBandPart> parts = [];
  Future<void> saveProject() async {
    final projectParts = parts.map((p) {
      return Part(
        name: p.name,
        width: double.tryParse(p.width) ?? 0,
        height: double.tryParse(p.height) ?? 0,
        quantity: int.tryParse(p.qty) ?? 1,
        topEdge: p.top,
        bottomEdge: p.bottom,
        leftEdge: p.left,
        rightEdge: p.right,
      );
    }).toList();

    final project = Project(
      projectName: widget.settings.projectName,
      material: widget.settings.material,
      sheetWidth: widget.settings.sheetWidth,
      sheetLength: widget.settings.sheetLength,
      thickness: widget.settings.thickness,
      borderMargin: widget.settings.borderMargin,
      partSpacing: widget.settings.partSpacing,
      edgeBandThickness: widget.settings.edgeBandThickness,
      parts: projectParts,
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/${project.projectName}.json');

    await file.writeAsString(jsonEncode(project.toJson()));
    debugPrint('PROJECT SAVED TO: ${file.path}');

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Project Saved')));
  }

  bool topEdge = false;
  bool rightEdge = false;
  bool bottomEdge = false;
  bool leftEdge = false;

  void addPart() {
    if (partNameController.text.isEmpty ||
        widthController.text.isEmpty ||
        heightController.text.isEmpty) {
      return;
    }

    setState(() {
      parts.add(
        EdgeBandPart(
          name: partNameController.text,
          width: widthController.text,
          height: heightController.text,
          qty: qtyController.text,
          top: topEdge,
          right: rightEdge,
          bottom: bottomEdge,
          left: leftEdge,
        ),
      );

      partNameController.clear();
      widthController.clear();
      heightController.clear();
      qtyController.text = '1';

      topEdge = false;
      rightEdge = false;
      bottomEdge = false;
      leftEdge = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1120),

        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          'Parts Entry',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(partNameController, 'Part Name'),
            const SizedBox(height: 10),
            _field(widthController, 'Width (mm)'),
            const SizedBox(height: 10),
            _field(heightController, 'Height (mm)'),
            const SizedBox(height: 10),
            _field(qtyController, 'Quantity'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _preview(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: addPart,
                    child: const Text('+ Add Part'),
                  ),
                  const SizedBox(height: 16),
                  ...parts.asMap().entries.map((e) {
                    final p = e.value;
                    return Card(
                      child: ListTile(
                        title: Text(p.name),
                        subtitle: Text(
                          '${p.width} × ${p.height} | Qty ${p.qty}\n'
                          '${p.top ? "🟩" : "⬜"} Top  '
                          '${p.right ? "🟩" : "⬜"} Right  '
                          '${p.bottom ? "🟩" : "⬜"} Bottom  '
                          '${p.left ? "🟩" : "⬜"} Left',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              parts.removeAt(e.key);
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: saveProject,
                        child: const Text('Save Project'),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OptimizationScreen(
                                parts: parts,
                                settings: widget.settings,
                              ),
                            ),
                          );
                        },
                        child: const Text('Optimize Layout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview() {
    double w = double.tryParse(widthController.text) ?? 300;
    double h = double.tryParse(heightController.text) ?? 300;

    double maxSize = 180;

    double drawW;
    double drawH;

    if (w >= h) {
      drawW = maxSize;
      drawH = (h / w) * maxSize;
    } else {
      drawH = maxSize;
      drawW = (w / h) * maxSize;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2234),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _edgeButton('TOP', topEdge, () {
            setState(() => topEdge = !topEdge);
          }),
          const SizedBox(height: 8),
          Text('${w.toInt()} mm', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  _edgeButton('LEFT', leftEdge, () {
                    setState(() => leftEdge = !leftEdge);
                  }),
                  const SizedBox(height: 12),
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      '${h.toInt()} mm',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: drawW,
                height: drawH,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: topEdge ? Colors.green : Colors.white,
                      width: 4,
                    ),
                    right: BorderSide(
                      color: rightEdge ? Colors.green : Colors.white,
                      width: 4,
                    ),
                    bottom: BorderSide(
                      color: bottomEdge ? Colors.green : Colors.white,
                      width: 4,
                    ),
                    left: BorderSide(
                      color: leftEdge ? Colors.green : Colors.white,
                      width: 4,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${partNameController.text.isEmpty ? "NEW PART" : partNameController.text}\nQty: ${qtyController.text}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: _edgeButton('RIGHT', rightEdge, () {
                  setState(() => rightEdge = !rightEdge);
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _edgeButton('BOTTOM', bottomEdge, () {
            setState(() => bottomEdge = !bottomEdge);
          }),
        ],
      ),
    );
  }

  Widget _edgeButton(String text, bool selected, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.green : const Color(0xFF0B1120),
      ),
      child: Text(text),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return TextField(
      controller: c,
      onChanged: (_) => setState(() {}),

      style: const TextStyle(color: Colors.white, fontSize: 18),

      decoration: InputDecoration(
        labelText: label,

        labelStyle: const TextStyle(color: Colors.white70),

        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),

        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}
