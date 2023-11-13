import 'package:flutter/material.dart';
import 'package:todo_app/task_list_screen.dart';
import 'create_task.dart';
import 'models.dart';

class CreateNewProject extends StatelessWidget {

  Project project;
  BuildContext context;
  CreateNewProject(this.context,this.project, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: Center(
        child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    )

                  ),
                  const SizedBox(
                    height: 50,
                    child: Row(

                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add your onPressed function here
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => exploreProject(project)),
                      );
                    },
                    child: const Text('New task Button'),
                  ),
                ],
              ),
            ]
        ),
      ),
    );
  }

  void exploreProject(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TaskListScreen(project),
      ),
    );
  }

  void addTask(Project project, Task task) {
    setState(() {
      project.tasks.add(task);
    });
  }

  void addErrand(Project project, String taskName, Errand errand) {
    for (var task in project.tasks) {
      if (task.name == taskName) {
        setState(() {
          task.errands.add(errand);
        });
        break;
      }
    }
  }

  void updateUI() {
    setState(() {});
  }
}