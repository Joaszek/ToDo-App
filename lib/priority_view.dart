import 'package:flutter/material.dart';
import 'package:todo_app/models.dart';


class PriorityViewPage extends StatelessWidget {
  const PriorityViewPage({super.key, required Project project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Priority Task List')),
      body: Column(
        children: [
          Expanded(
            child: prioritySection(
                'High Priority', 5),
          ),
          Expanded(
            child: prioritySection(
                'Medium Priority', 5), // Liczba przycisków dla tej sekcji
          ),
          Expanded(
            child: prioritySection(
                'Low Priority', 8), // Liczba przycisków dla tej sekcji
          ),
        ],
      ),
    );
  }

  Widget prioritySection(String title, int count) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 24,
              )),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: count,
            itemBuilder: (context, index) {
              return ListTile(
                title: ElevatedButton(
                  onPressed: () {/* Do something */},
                  child: Text('Task ${index + 1} $title'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //List<Task> createList(Project project, Priority priority) {
  //  List<Task> finalTasks = project.tasks.forEach((element) {element.priority == priority});
  //  return final
  //}
}