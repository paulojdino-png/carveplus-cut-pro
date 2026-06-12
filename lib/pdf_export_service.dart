import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import 'project_model.dart';

class PdfExportService {
  static Future<File> exportProject(Project project) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CarvePlus Cut Pro', style: pw.TextStyle(fontSize: 24)),

              pw.SizedBox(height: 20),

              pw.Text('Project: ${project.projectName}'),

              pw.Text('Material: ${project.material}'),

              pw.Text(
                'Sheet Size: ${project.sheetWidth} x ${project.sheetLength}',
              ),

              pw.Text('Thickness: ${project.thickness}'),

              pw.SizedBox(height: 20),

              pw.Text('Parts List', style: pw.TextStyle(fontSize: 18)),

              pw.SizedBox(height: 10),

              ...project.parts.map(
                (part) => pw.Text(
                  '${part.name} | '
                  '${part.width} x ${part.height} | '
                  'Qty ${part.quantity}',
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/${project.projectName}.pdf');

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
