import 'package:flutter/material.dart';
import 'errand_list_screen.dart';
import 'models.dart';

class TaskListScreen extends StatefulWidget {
  final Project project;

  const TaskListScreen(this.project, {super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController taskNameController = TextEditingController();

  // Updated function to add a task and trigger UI update
  // void addTaskAndRefreshUI(String taskName) {
  //   if (taskName.isNotEmpty) {
  //     widget.addTask(
  //         widget.project.name, Task(taskName, [], null, null));
  //     widget.updateUI();
  //   }
  // }

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
                      widget.addErrand, widget.updateUI),
                ),
              );

              // When returning from the ErrandListScreen, update the UI to
              // reflect the new errand completion status.
              widget.updateUI();
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
                title: const Text('Create a New Task'),
                content: TextField(
                  controller: taskNameController,
                  decoration: const InputDecoration(labelText: 'Task Name'),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Create'),
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
        child: const Icon(Icons.add),
      ),
    );
  }

  void addTask(Project project, Task task) {
    setState(() {
      project.tasks.add(task);
    });
  }
}
