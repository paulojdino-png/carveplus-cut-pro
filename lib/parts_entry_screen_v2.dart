import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'optimization_screen.dart';
import 'project_model.dart';
import 'package:path_provider/path_provider.dart';

import 'edge_band_part.dart';
import 'project_settings.dart';

class PartsEntryScreenV2 extends StatefulWidget {
  final ProjectSettings settings;
  final List<EdgeBandPart>? initialParts;

  const PartsEntryScreenV2({
    super.key,
    required this.settings,
    this.initialParts,
  });

  @override
  State<PartsEntryScreenV2> createState() => _PartsEntryScreenV2State();
}

class PartRow {
  PartRow({VoidCallback? onChanged}) {
    if (onChanged != null) {
      label.addListener(onChanged);
      length.addListener(onChanged);
      width.addListener(onChanged);
      qty.addListener(onChanged);
    }
  }
  final TextEditingController label = TextEditingController();
  final TextEditingController length = TextEditingController();
  final TextEditingController width = TextEditingController();
  final TextEditingController qty = TextEditingController();

  bool top = false;
  bool right = false;
  bool bottom = false;
  bool left = false;

  bool allowRotation = true;
}

class _PartsEntryScreenV2State extends State<PartsEntryScreenV2> {
  final List<PartRow> rows = [];
  bool _hasUnsavedChanges = false;
  void _markDirty() {
    if (_hasUnsavedChanges) return;

    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialParts != null && widget.initialParts!.isNotEmpty) {
      for (final part in widget.initialParts!) {
        final row = PartRow(onChanged: _markDirty);

        row.label.text = part.name;
        row.length.text = part.height;
        row.width.text = part.width;
        row.qty.text = part.qty;

        row.top = part.top;
        row.right = part.right;
        row.bottom = part.bottom;
        row.left = part.left;

        row.allowRotation = part.allowRotation;

        rows.add(row);
      }
    }

    while (rows.length < 5) {
      rows.add(PartRow(onChanged: _markDirty));
    }
  }

  void _addRowIfNeeded(PartRow row) {
    if (rows.last != row) return;

    final hasData =
        row.label.text.isNotEmpty ||
        row.length.text.isNotEmpty ||
        row.width.text.isNotEmpty ||
        row.qty.text.isNotEmpty;

    if (hasData) {
      setState(() {
        rows.add(PartRow(onChanged: _markDirty));
      });
    }
  }

  List<EdgeBandPart> _getParts() {
    return rows
        .where(
          (r) =>
              r.label.text.trim().isNotEmpty &&
              r.length.text.trim().isNotEmpty &&
              r.width.text.trim().isNotEmpty &&
              r.qty.text.trim().isNotEmpty,
        )
        .map(
          (r) => EdgeBandPart(
            name: r.label.text.trim(),
            height: r.length.text.trim(),
            width: r.width.text.trim(),
            qty: r.qty.text.trim(),
            top: r.top,
            right: r.right,
            bottom: r.bottom,
            left: r.left,
            allowRotation: r.allowRotation,
          ),
        )
        .toList();
  }

  String? _validateParts() {
    bool hasAnyData = false;

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];

      final label = row.label.text.trim();
      final length = row.length.text.trim();
      final width = row.width.text.trim();
      final qty = row.qty.text.trim();

      final rowHasData =
          label.isNotEmpty ||
          length.isNotEmpty ||
          width.isNotEmpty ||
          qty.isNotEmpty;

      if (!rowHasData) continue;

      hasAnyData = true;

      if (label.isEmpty) {
        return 'Row ${i + 1}: Label is required';
      }

      if (length.isEmpty) {
        return 'Row ${i + 1}: Length is required';
      }

      if (width.isEmpty) {
        return 'Row ${i + 1}: Width is required';
      }

      if (qty.isEmpty) {
        return 'Row ${i + 1}: Quantity is required';
      }

      final l = double.tryParse(length);
      if (l == null || l <= 0) {
        return 'Row ${i + 1}: Invalid length';
      }

      final w = double.tryParse(width);
      if (w == null || w <= 0) {
        return 'Row ${i + 1}: Invalid width';
      }

      final q = int.tryParse(qty);
      if (q == null || q <= 0) {
        return 'Row ${i + 1}: Invalid quantity';
      }
    }

    if (!hasAnyData) {
      return 'Please add at least one part.';
    }

    return null;
  }

  Future<void> _writeProjectToDisk() async {
    final uiParts = _getParts();

    final projectParts = uiParts.map((p) {
      return Part(
        name: p.name,
        width: double.tryParse(p.width) ?? 0,
        height: double.tryParse(p.height) ?? 0,
        quantity: int.tryParse(p.qty) ?? 1,
        topEdge: p.top,
        bottomEdge: p.bottom,
        leftEdge: p.left,
        rightEdge: p.right,
        allowRotation: p.allowRotation,
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
  }

  Future<void> saveProject() async {
    await _writeProjectToDisk();

    if (!mounted) return;
    setState(() {
      _hasUnsavedChanges = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Project Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,

      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes.\n\nDo you want to save before leaving?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'discard'),
                child: const Text('Discard'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, 'save'),
                child: const Text('Save'),
              ),
            ],
          ),
        );

        if (action == 'save') {
          await saveProject();

          if (!context.mounted) return;

          Navigator.pop(context);
        }

        if (action == 'discard') {
          setState(() {
            _hasUnsavedChanges = false;
          });

          if (!context.mounted) return;

          Navigator.pop(context);
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Parts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey.shade300,
                child: const Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Label',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: Center(
                        child: Text(
                          'Length',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 70,
                      child: Center(
                        child: Text(
                          'Width',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 60,
                      child: Center(
                        child: Text(
                          'Qty',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          'EB',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(child: Icon(Icons.screen_rotation)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: ValueKey(rows[index]),

                      direction: DismissDirection.endToStart,

                      background: Container(),

                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Part'),
                                content: const Text(
                                  'Are you sure you want to delete this part?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      },

                      onDismissed: (direction) {
                        setState(() {
                          rows.removeAt(index);
                        });
                      },

                      child: _buildRow(rows[index]),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final error = _validateParts();

                        if (error != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                          return;
                        }

                        await _writeProjectToDisk();
                      },
                      child: const Text('Save Project'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final error = _validateParts();

                        if (error != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                          return;
                        }

                        final parts = _getParts();

                        await saveProject();

                        if (!context.mounted) return;

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OptimizationScreen(
                              parts: parts,
                              settings: widget.settings,
                            ),
                          ),
                        );
                      },
                      child: const Text('Optimize'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editEdgeBand(PartRow row) async {
    bool top = row.top;
    bool right = row.right;
    bool bottom = row.bottom;
    bool left = row.left;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Center(
                child: Text(
                  'Edge Banding',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              content: StatefulBuilder(
                builder: (context, setDialogState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setDialogState(() => top = !top);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: top
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                        child: const Text("TOP"),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RotatedBox(
                            quarterTurns: 3,
                            child: ElevatedButton(
                              onPressed: () {
                                setDialogState(() => left = !left);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: left
                                    ? Colors.green
                                    : Colors.grey.shade300,
                              ),
                              child: const Text("LEFT"),
                            ),
                          ),

                          const SizedBox(width: 20),

                          EdgeBandPreview(
                            top: top,
                            right: right,
                            bottom: bottom,
                            left: left,
                          ),

                          const SizedBox(width: 20),

                          RotatedBox(
                            quarterTurns: 1,
                            child: ElevatedButton(
                              onPressed: () {
                                setDialogState(() => right = !right);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: right
                                    ? Colors.green
                                    : Colors.grey.shade300,
                              ),
                              child: const Text("RIGHT"),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        onPressed: () {
                          setDialogState(() => bottom = !bottom);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bottom
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                        child: const Text("BOTTOM"),
                      ),
                    ],
                  );
                },
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      row.top = top;
                      row.right = right;
                      row.bottom = bottom;
                      row.left = left;

                      _markDirty();
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRow(PartRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: row.label,
              onChanged: (_) {
                _addRowIfNeeded(row);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 4),

          SizedBox(
            width: 70,
            child: TextField(
              controller: row.length,
              onChanged: (_) {
                _addRowIfNeeded(row);
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),

          const SizedBox(width: 4),

          SizedBox(
            width: 70,
            child: TextField(
              controller: row.width,
              onChanged: (_) {
                _addRowIfNeeded(row);
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),

          const SizedBox(width: 4),

          SizedBox(
            width: 60,
            child: TextField(
              controller: row.qty,
              onChanged: (_) {
                _addRowIfNeeded(row);
              },
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),

          SizedBox(
            width: 40,
            child: InkWell(
              onTap: () => _editEdgeBand(row),
              child: Center(
                child: EdgeBandPreview(
                  top: row.top,
                  right: row.right,
                  bottom: row.bottom,
                  left: row.left,
                ),
              ),
            ),
          ),

          SizedBox(
            width: 40,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                setState(() {
                  row.allowRotation = !row.allowRotation;
                  _markDirty();
                });
              },
              child: Center(
                child: Icon(
                  row.allowRotation ? Icons.screen_rotation : Icons.block,
                  color: row.allowRotation ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EdgeBandPreview extends StatelessWidget {
  final bool top;
  final bool right;
  final bool bottom;
  final bool left;

  const EdgeBandPreview({
    super.key,
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    const green = Colors.green;
    const black = Colors.black54;

    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        children: [
          // Top
          Positioned(
            left: 2,
            right: 2,
            top: 0,
            child: Container(height: 2, color: top ? green : black),
          ),

          // Bottom
          Positioned(
            left: 2,
            right: 2,
            bottom: 0,
            child: Container(height: 2, color: bottom ? green : black),
          ),

          // Left
          Positioned(
            top: 2,
            bottom: 2,
            left: 0,
            child: Container(width: 2, color: left ? green : black),
          ),

          // Right
          Positioned(
            top: 2,
            bottom: 2,
            right: 0,
            child: Container(width: 2, color: right ? green : black),
          ),
        ],
      ),
    );
  }
}
