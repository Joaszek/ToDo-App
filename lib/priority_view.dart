import 'package:flutter/material.dart';
import 'package:todo_app/models.dart';


class PriorityViewPage extends StatelessWidget {
  final Project project;

  const PriorityViewPage({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Priority Task List')),
      body: Column(
        children: [
          Expanded(
            child: prioritySection(
              'High Priority',
              project.tasks.where((task) => task.priority == Priority.high).toList(),
              Colors.red,
            ),
          ),
          Expanded(
            child: prioritySection(
              'Medium Priority',
              project.tasks.where((task) => task.priority == Priority.medium).toList(),
              Colors.orange,
            ),
          ),
          Expanded(
            child: prioritySection(
              'Low Priority',
              project.tasks.where((task) => task.priority == Priority.low).toList(),
              Colors.green,
            ),
          ),
          Expanded(
            child: prioritySection(
              'None Priority',
              project.tasks.where((task) => task.priority == Priority.none).toList(),
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget prioritySection(String title, List<Task> tasks, Color titleColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 24,
            ),
          ),
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
