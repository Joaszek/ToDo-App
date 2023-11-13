// models.dart

class Errand {
  final String name;
  bool isComplete;

  Errand(this.name, this.isComplete);
}

class Task {
  final String name;
  final List<Errand> errands;
  String? file; // File associated with the task (can be a single file)
  String? link; // Link associated with the task (can be a single link)

  Task(this.name, this.errands, this.file, this.link);
}

class Project {
  final String name;
  final List<Task> tasks;

  Project(this.name, this.tasks);
}
