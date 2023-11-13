import 'package:flutter/cupertino.dart';

class Errand {
  final String name;
  bool isComplete;

  Errand(this.name, this.isComplete);
}

class Task {
  static int amount = 0;
  int id = 0;
  final String name;
  final List<Errand> errands;
  String? file; // File associated with the task (can be a single file)
  String? link; // Link associated with the task (can be a single link)

  Task(this.name, this.errands, this.file, this.link) {
    id = amount;
    increment();
  }

  void increment() {
    amount++;
  }
}

class Project {
  static int amount = 0;
  int id=0;
  String name = "";
  List<Task> tasks = [];

  Project(this.name, this.tasks){
    id = amount;
    increment();
  }

  void increment() {
    amount++;
  }

  int getId(){
    return id;
  }
}
