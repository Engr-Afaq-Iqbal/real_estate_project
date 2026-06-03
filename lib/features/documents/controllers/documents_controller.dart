import 'package:get/get.dart';

class DocumentFolder {
  final String name;
  final int fileCount;
  final String lastUpdated;
  final String colorHex;

  const DocumentFolder({
    required this.name,
    required this.fileCount,
    required this.lastUpdated,
    required this.colorHex,
  });
}

class DocumentsController extends GetxController {
  final folders = <DocumentFolder>[
    const DocumentFolder(name: 'NOC / Approvals', fileCount: 8, lastUpdated: 'Updated 2d ago', colorHex: '8B5CF6'),
    const DocumentFolder(name: 'Drawings', fileCount: 12, lastUpdated: 'Updated 6d ago', colorHex: '8B5CF6'),
    const DocumentFolder(name: 'Contracts', fileCount: 4, lastUpdated: 'Updated 12d ago', colorHex: '22C55E'),
    const DocumentFolder(name: 'Invoices', fileCount: 34, lastUpdated: 'Updated Today', colorHex: 'F59E0B'),
    const DocumentFolder(name: 'Photos', fileCount: 218, lastUpdated: 'Updated Today', colorHex: 'EF4444'),
    const DocumentFolder(name: 'Misc', fileCount: 6, lastUpdated: 'Updated 3w ago', colorHex: '64748B'),
  ].obs;
}
