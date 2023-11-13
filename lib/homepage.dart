import 'package:flutter/material.dart';
import 'create_project.dart';
import 'create_task.dart';
import 'task_list_screen.dart';
import 'models.dart';
import 'calendar_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();

  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController singleTaskController = TextEditingController();

  final List<Project> projects = [
    Project('Project 1', [
      Task(
          'Task 1.1',
          [
            Errand('Errand 1.1.1', false),
            Errand('Errand 1.1.2', true),
          ],
          null,
          null),
      Task('Task 1.2', [], null, null),
    ]),
    Project('Project 2', [
      Task('Task 2.1', [], null, null),
      Task(
          'Task 2.2',
          [
            Errand('Errand 2.2.1', false),
            Errand('Errand 2.2.2', false),
          ],
          null,
          null),
    ]),
  ];

  final List<Task> singleTasks = [];

  void addProject(String projectName) {
    setState(() {
      projects.add(Project(projectName, []));
    });
  }

  void addTask(String projectName, Task task) {
    for (var project in projects) {
      if (project.name == projectName) {
        setState(() {
          project.tasks.add(task);
        });
        break;
      }
    }
  }

  void addSingleTask(Task task) {
    setState(() {
      singleTasks.add(task);
    });
  }

  void addErrand(String projectName, String taskName, Errand errand) {
    for (var project in projects) {
      if (project.name == projectName) {
        for (var task in project.tasks) {
          if (task.name == taskName) {
            setState(() {
              task.errands.add(errand);
            });
            break;
          }
        }
      }
    }
  }

  void exploreProject(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TaskListScreen(project, addTask, addErrand, updateUI),
      ),
    );
  }

  // This function will be called to update the UI
  void updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do app'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateProjectPage()),
                    );
                  },
                  child: const Text(
                    'New Project',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateNewTask()),
                  );
                  },
                  child: const Text(
                  'New Task',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  ),
                ),
            ],
          ),
          // Date Window
          SizedBox(
            height: 100, // Set the desired height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 30, // Change the number of days as needed
              itemBuilder: (context, index) {
                DateTime currentDate =
                    DateTime.now().add(Duration(days: index));
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = currentDate;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarScreen(selectedDate),
                      ),
                    );
                  },
                  child: Container(
                    width: 100, // Set the desired width for each cell
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${currentDate.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          AppBar(
            title: const Text('Projects', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                final allTasksComplete = project.tasks.isNotEmpty &&
                    project.tasks.every((task) =>
                        task.errands.isNotEmpty &&
                        task.errands.every((errand) => errand.isComplete));

                return ListTile(
                  title: Text(
                    project.name,
                    style: TextStyle(
                      color: allTasksComplete ? Colors.green : Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Explore',
                    onPressed: () {
                      exploreProject(project);
                    },
                  ),
                );
              },
            ),
          ),
          AppBar(
            title: const Text('Tasks', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: singleTasks.length,
              itemBuilder: (context, index) {
                final task = singleTasks[index];

                return ListTile(
                  title: Text(
                    task.name,
                  ),
                  onTap: () {
                    // Handle tap on single tasks here
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
