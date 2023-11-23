// project_list_screen.dart

import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'models.dart';
import 'package:flutter/services.dart'; //for 'FilteringTextInputFormatter in deadline functionality
import 'main_view.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController singleTaskController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  bool isCheckboxChecked = false;

  late TimeInputFormatter _timeInputFormatter;
  _ProjectListScreenState() {
    // Initialize _timeInputFormatter in the constructor
    _timeInputFormatter = TimeInputFormatter();
  }

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

// Define the addTask function
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

  // Define the addErrand function
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

// Define the updateUI function
  void updateUI() {
    setState(() {});
  }

  MaterialPageRoute<void> exploreProject(Project project) {
    return MaterialPageRoute<void>(
      builder: (context) => TaskListScreen(
        project: project,
        addTaskCallback: addTask,
        updateUICallback: updateUI,
        addErrandCallback: addErrand,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do app'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Explore',
            onPressed: () {
              // Implement the desired action when the Explore button is pressed
              print('Explore button pressed');
            },
          ),
        ],
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Create a New Project'),
                          content: TextField(
                            controller: projectNameController,
                            decoration:
                                const InputDecoration(labelText: 'Project Name'),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Create',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                String projectName = projectNameController.text;
                                if (projectName.isNotEmpty) {
                                  addProject(projectName);
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Create a New Task'),
                          content: SingleChildScrollView(
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: singleTaskController,
                                      decoration:
                                      const InputDecoration(labelText: 'Task Name'),
                                    ),
                                    const SizedBox(height: 100),
                                    const Text('Deadline'),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .start,
                                      children: [
                                        const Text('Date:'),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: TextField(
                                            controller: _dateController,
                                            decoration: const InputDecoration(
                                              labelText: 'YYYY-MM-DD',
                                            ),
                                            keyboardType: TextInputType
                                                .datetime,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  10),
                                              // Add custom input formatter for date format
                                              DateInputFormatter(),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.calendar_month),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Select date'),
                                                  content: StatefulBuilder(
                                                    builder: (
                                                        BuildContext context,
                                                        StateSetter setState) {
                                                      return CalendarPopup(
                                                          setState: setState);
                                                    },
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                          'Select'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          const Text('Time:'),
                                          const SizedBox(width: 5),
                                          Flexible(child: TextField(
                                            controller: _timeController,
                                            decoration: const InputDecoration(
                                              labelText: 'Enter time (HH:MM)',
                                            ),
                                            keyboardType: TextInputType
                                                .datetime,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  4),
                                              _timeInputFormatter,
                                            ],
                                          ),),
                                          IconButton(
                                            icon: Icon(Icons.access_time),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (
                                                    BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Select time'),
                                                    content: StatefulBuilder(
                                                      builder: (
                                                          BuildContext context,
                                                          StateSetter setState) {
                                                        return TimePickerPopup(
                                                            setState: setState);
                                                      },
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            'Select'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ]
                                    ),
                                    Row(
                                      children: [
                                        const Text('Free deadline'),
                                        Checkbox(
                                          value: isCheckboxChecked,
                                          onChanged: (value) {
                                            setState(() {
                                              isCheckboxChecked =
                                                  value ?? false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                        children: [
                                          Flexible(child: TextField(
                                            enabled: isCheckboxChecked,
                                          ),
                                          ),
                                          const Text("Month"),
                                          Flexible( child: TextField(
                                            enabled: isCheckboxChecked,
                                          ),
                                          ),
                                          const Text("Day"),
                                        ]
                                    )

                                  ],
                                );
                              },
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Create',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                String taskName = singleTaskController.text;
                                if (taskName.isNotEmpty) {
                                  // Update the UI callback directly here
                                  setState(() {
                                    singleTasks
                                        .add(Task(taskName, [], null, null));
                                  });
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainViewPage())
              );
              print('calendar opened!');
            },
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.lightBlue, // Set the color of the larger container
                  child: const DateList(),
                )
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
                    icon: const Icon(Icons.visibility),
                    tooltip: 'Explore',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainViewPage()),
                      );
                      print('visibility pressed for Item 1');
                    },
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      exploreProject(project),
                    );

                    // When returning from the TaskListScreen, update the UI to
                    // reflect the new task completion status.
                    setState(() {});
                  },
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
