import 'package:get/get.dart';

class WorkerAttendance {
  final String id;
  final String name;
  final String role;
  bool isPresent;
  String? checkInTime;

  WorkerAttendance({
    required this.id,
    required this.name,
    required this.role,
    this.isPresent = false,
    this.checkInTime,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class LaborController extends GetxController {
  final workers = <WorkerAttendance>[].obs;
  final selectedDate = DateTime.now().obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadWorkers();
  }

  void _loadWorkers() {
    workers.value = [
      WorkerAttendance(id: 'w1', name: 'Bashir Ahmed', role: 'Mason · Lead', isPresent: true, checkInTime: '08:42 AM'),
      WorkerAttendance(id: 'w2', name: 'Ramzan Ali', role: 'Mason', isPresent: true, checkInTime: '08:55 AM'),
      WorkerAttendance(id: 'w3', name: 'Sajid Khan', role: 'Helper', isPresent: true, checkInTime: '09:02 AM'),
      WorkerAttendance(id: 'w4', name: 'Nadeem Iqbal', role: 'Electrician', isPresent: false),
      WorkerAttendance(id: 'w5', name: 'Tariq Mehmood', role: 'Plumber', isPresent: true, checkInTime: '09:15 AM'),
      WorkerAttendance(id: 'w6', name: 'Yousaf Saleem', role: 'Helper', isPresent: true, checkInTime: '09:18 AM'),
    ];
  }

  int get presentCount => workers.where((w) => w.isPresent).length;
  int get absentCount => workers.where((w) => !w.isPresent).length;

  void toggleAttendance(String workerId) {
    final idx = workers.indexWhere((w) => w.id == workerId);
    if (idx == -1) return;
    final worker = workers[idx];
    worker.isPresent = !worker.isPresent;
    if (worker.isPresent) {
      final now = DateTime.now();
      worker.checkInTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour < 12 ? 'AM' : 'PM'}';
    } else {
      worker.checkInTime = null;
    }
    workers.refresh();
  }

  Future<void> submitAttendance() async {
    isSubmitting.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSubmitting.value = false;
    Get.back();
    Get.snackbar('Success', 'Attendance submitted for ${selectedDate.value.day} workers');
  }
}
