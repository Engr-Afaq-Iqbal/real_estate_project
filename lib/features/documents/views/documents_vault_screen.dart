import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/documents_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';
import '../../../presentation/widgets/common/app_card.dart';

class DocumentsVaultScreen extends GetView<DocumentsController> {
  const DocumentsVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('documents_vault'.tr),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Folder grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 1.3,
              children: controller.folders.map((f) => _FolderCard(folder: f)).toList(),
            ),

            const SizedBox(height: AppDimensions.xl),

            Row(
              children: [
                Expanded(child: Text('recent'.tr, style: AppTextStyles.h3(context))),
                GestureDetector(
                  onTap: () {},
                  child: Text('see_all'.tr, style: const TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600)),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.md),

            _RecentFile(type: 'PDF', name: 'Construction NOC — DHA.pdf', size: '1.2 MB', date: '20 May'),
            _RecentFile(type: 'CAD', name: 'Architect Drawing v3.dwg', size: '4.8 MB', date: '18 May'),
            _RecentFile(type: 'PDF', name: 'Cement Invoice — Lucky.pdf', size: '184 KB', date: '17 May'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final DocumentFolder folder;
  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _folderColor(folder.colorHex).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(Icons.folder_outlined, color: _folderColor(folder.colorHex), size: 20),
          ),
          const Spacer(),
          Text(folder.name, style: AppTextStyles.h4(context)),
          Text('${folder.fileCount} files', style: AppTextStyles.caption(context)),
          Text(folder.lastUpdated, style: AppTextStyles.caption(context)),
        ],
      ),
    );
  }

  Color _folderColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _RecentFile extends StatelessWidget {
  final String type;
  final String name;
  final String size;
  final String date;

  const _RecentFile({
    required this.type,
    required this.name,
    required this.size,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.base,
        vertical: AppDimensions.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 44,
            decoration: BoxDecoration(
              color: _typeColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Center(
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _typeColor(),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.labelLarge(context)),
                Text('$size · $date', style: AppTextStyles.caption(context)),
              ],
            ),
          ),
          const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondaryLight),
        ],
      ),
    );
  }

  Color _typeColor() {
    switch (type) {
      case 'PDF': return AppColors.error;
      case 'CAD': return AppColors.primary;
      default: return AppColors.textSecondaryLight;
    }
  }
}
