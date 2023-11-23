import 'package:flutter/material.dart';


class DueDatePriorityViewPage extends StatelessWidget {
  const DueDatePriorityViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Due Date Task List')),
      body: Column(
        children: [
          Expanded(
            child:
            prioritySection('Today', 5),
          ),
          Expanded(
            child: prioritySection(
                'This week', 5),
          ),
          Expanded(
            child: prioritySection(
                'This month', 8),
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
}