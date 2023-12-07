import 'package:flutter/material.dart';
import 'models.dart';

class DueDatePriorityViewPage extends StatelessWidget {
  final Project project;

  const DueDatePriorityViewPage({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Task> todayTasks = [];
    List<Task> thisWeekTasks = [];
    List<Task> thisMonthTasks = [];
    List<Task> thisYearTasks = [];

    for (Task task in project.tasks) {
      if (task.deadline != null && task.deadline!.date != null) {
        DateTime dueDate = task.deadline!.date!;

        if (dueDate.isBefore(DateTime.now().add(Duration(days: 1)))) {
          todayTasks.add(task);
        } else if (dueDate.isBefore(DateTime.now().add(Duration(days: 7)))) {
          thisWeekTasks.add(task);
        } else if (dueDate.isBefore(DateTime.now().add(Duration(days: 30)))) {
          thisMonthTasks.add(task);
        } else if (dueDate.isBefore(DateTime.now().add(Duration(days: 365)))) {
          thisYearTasks.add(task);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Due Date Task List')),
      body: Column(
        children: [
          Expanded(
            child: prioritySection('Today', todayTasks, Colors.purple.shade400),
          ),
          Expanded(
            child: prioritySection('This week', thisWeekTasks, Colors.purple.shade500),
          ),
          Expanded(
            child: prioritySection('This month', thisMonthTasks, Colors.purple.shade600),
          ),
          Expanded(
            child: prioritySection('This year', thisYearTasks, Colors.purple.shade700),
          ),
        ],
      ),
    );
  }

  Widget prioritySection(String title, List<Task> tasks, Color sectionColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title,
              style: TextStyle(
                color: sectionColor,
                fontSize: 24,
              )),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Task task = tasks[index];
              return ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      task.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      task.description ?? "", // Assuming description is a String
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }


}