// task_list_screen.dart
import 'package:flutter/material.dart';
import 'errand_list_screen.dart';
import 'models.dart';

class TaskListScreen extends StatefulWidget {
  final Project project;
  final Function(String, Task) addTaskCallback;
  final Function(String, String, Errand) addErrandCallback;
  final VoidCallback updateUICallback;

  TaskListScreen(this.project, this.addTaskCallback, this.addErrandCallback,
      this.updateUICallback);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController taskNameController = TextEditingController();

  // Updated function to add a task and trigger UI update
  void addTaskAndRefreshUI(String taskName) {
    if (taskName.isNotEmpty) {
      widget.addTaskCallback(
          widget.project.name, Task(taskName, [], null, null));
      widget.updateUICallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
      ),
      body: ListView.builder(
        itemCount: widget.project.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.project.tasks[index];
          final allErrandsComplete = task.errands.isNotEmpty &&
              task.errands.every((errand) => errand.isComplete);

          return ListTile(
            title: Text(
              task.name,
              style: TextStyle(
                color: allErrandsComplete ? Colors.green : Colors.black,
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ErrandListScreen(widget.project, task,
                      widget.addErrandCallback, widget.updateUICallback),
                ),
              );

              // When returning from the ErrandListScreen, update the UI to
              // reflect the new errand completion status.
              widget.updateUICallback();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Create a New Task'),
                content: TextField(
                  controller: taskNameController,
                  decoration: InputDecoration(labelText: 'Task Name'),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Create'),
                    onPressed: () {
                      // Use the updated function to add a task and trigger UI update
                      addTaskAndRefreshUI(taskNameController.text);

                      // Close the dialog
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
