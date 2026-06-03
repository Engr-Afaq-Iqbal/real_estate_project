import 'package:get/get.dart';
import '../data/models/project_model.dart';
import '../data/models/stage_model.dart';

class ProjectsController extends GetxController {
  final isLoading = false.obs;
  final projects = <ProjectModel>[].obs;
  final selectedProject = Rxn<ProjectModel>();
  final selectedFilter = 'active'.obs;

  // New project wizard
  final wizardStep = 0.obs;
  final selectedProjectType = 'House'.obs;
  final projectName = ''.obs;
  final projectCity = 'Lahore'.obs;
  final projectArea = ''.obs;
  final projectPlotSize = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
    if (Get.arguments is ProjectModel) {
      selectedProject.value = Get.arguments as ProjectModel;
    }
  }

  Future<void> loadProjects() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    projects.value = ProjectModel.mockList();
    isLoading.value = false;
  }

  List<ProjectModel> get filteredProjects {
    switch (selectedFilter.value) {
      case 'active':
        return projects.where((p) => p.status == 'active').toList();
      case 'completed':
        return projects.where((p) => p.status == 'completed').toList();
      case 'on_hold':
        return projects.where((p) => p.status == 'on_hold').toList();
      default:
        return projects;
    }
  }

  void selectProject(ProjectModel project) {
    selectedProject.value = project;
    selectedProject.refresh();
  }

  void nextWizardStep() {
    if (wizardStep.value < 3) wizardStep.value++;
  }

  void prevWizardStep() {
    if (wizardStep.value > 0) wizardStep.value--;
  }

  StageModel? get currentStage {
    final stages = selectedProject.value?.stages ?? [];
    try {
      return stages.firstWhere((s) => s.isInProgress);
    } catch (_) {
      return stages.isNotEmpty ? stages.first : null;
    }
  }
}
