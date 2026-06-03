import 'package:get/get.dart';
import '../../projects/data/models/project_model.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final projects = <ProjectModel>[].obs;
  final unreadNotifications = 3.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    projects.value = ProjectModel.mockList();
    isLoading.value = false;
  }

  ProjectModel? get primaryProject =>
      projects.isNotEmpty ? projects.first : null;

  List<ProjectModel> get activeProjects =>
      projects.where((p) => p.status == 'active').toList();
}
