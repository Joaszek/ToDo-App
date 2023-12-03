// project_list_screen.dart

import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'models.dart';
import 'package:flutter/services.dart'; //for 'FilteringTextInputFormatter in deadline functionality
import 'main_view.dart';
import 'calendar_view_multi.dart';

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
  TextEditingController _freeMonthController = TextEditingController(text:"0");
  TextEditingController _freeDayController = TextEditingController(text:"0");
  bool isCheckboxChecked = false;
  DateTime selectedDate = DateTime.now(); // Variable to store the selected date from tablecalendar CalendarPopUp
  TimeOfDay selectedTime = TimeOfDay.now(); // Variable to store the selected time from TimePickerPopUp
  Priority selectedPriority = Priority.none;

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
          null,
          deadline: null
          ),
      Task('Task 1.2', [], null, null, deadline:Deadline(
        date: DateTime(2023, 12, 30), // specify the date component
        time: TimeOfDay(hour: 14, minute: 30), // Specify the time component
      )),
    ]),
    Project('Project 2', [
      Task('Task 2.1', [], null, null, deadline:Deadline(
        date: DateTime(2023, 12, 30), // specify the date component
        time: TimeOfDay(hour: 14, minute: 30), // Specify the time component
      )),
      Task(
          'Task 2.2',
          [
            Errand('Errand 2.2.1', false),
            Errand('Errand 2.2.2', false),
          ],
          null,
          null,
          deadline:Deadline(
          date: DateTime(2023, 12, 31), // specify the date component
          time: TimeOfDay(hour: 15, minute: 30)) // Specify the time component
      ),
    ]),
  ];

  final List<Task> singleTasks = [];

  void addProject(String projectName) {
    setState(() {
      projects.add(Project(projectName, []));
    });
  }

  int findProjectIndex(String projectName) {
    for (int i = 0; i < projects.length; i++) {
      if (projects[i].name == projectName) {
        return i;
      }
    }
    return -1; // Return -1 if the project is not found
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

  // Function to convert DateTime to String with the format yyyy-MM-dd
  String formatDate(DateTime dateTime) {
    String year = dateTime.year.toString();
    String month = dateTime.month.toString().padLeft(2, '0');
    String day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
  // Function to convert TimeOfDay to String with the format HH:mm
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final String hour = timeOfDay.hour.toString().padLeft(2, '0');
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
                                                          setState: setState,
                                                          onDaySelected: (day) {
                                                            selectedDate = day; // Capture the selected date
                                                            _dateController.text = formatDate(day);
                                                          }
                                                      );
                                                    },
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        print('Selected Date from tablecalendar: $selectedDate');
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: const Text('Select'),
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
                                                            setState: setState,
                                                            onTimeSelected: (time) {
                                                              selectedTime = time;
                                                              print('Selected Time hehe: $selectedTime'); // Handle the selected time
                                                              _timeController.text = formatTimeOfDay(time);
                                                            }
                                                        );
                                                      },
                                                    ),
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
                                            controller: _freeMonthController,
                                            decoration: const InputDecoration(
                                              labelText: '(MM)',
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [TwoDigitInputFormatter()],
                                          ),),
                                          const Text("Month"),
                                          Flexible( child: TextField(
                                            enabled: isCheckboxChecked,
                                            controller: _freeDayController,
                                            decoration: const InputDecoration(
                                              labelText: '(dd)',
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [TwoDigitInputFormatter()],
                                          ),),
                                          const Text("Day"),
                                        ]
                                    ),
                                    const SizedBox(height: 50),
                                    const Text('Priority'),
                                    PriorityScroll(
                                      onPrioritySelected: (priority) {
                                        // Use the selectedPriority as needed
                                        print('Selected Priority: $priority');
                                        selectedPriority = priority;
                                      },
                                    ),

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
                              child: const Text('Create', style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                String taskName = singleTaskController.text;
                                if (taskName.isNotEmpty) {
                                  print("Task name is $taskName");
                                  if(isCheckboxChecked) {
                                    if (_freeDayController.text == "0" && _freeMonthController.text == "0") {
                                      singleTasks.add(Task(taskName, [], null, null, deadline: null, priority: Priority.none));
                                    }
                                    else {
                                      int nMonth = int.parse(_freeMonthController.text);
                                      int nDay = int.parse(_freeDayController.text);
                                      print("month is $nMonth, day is $nDay");
                                      final now = DateTime.now();
                                      final timeNow = TimeOfDay.now();
                                      final freeDeadlineDate = now.add(Duration(days: nMonth * 30 + nDay));
                                      singleTasks.add(Task(taskName, [], null, null, deadline:
                                        Deadline(date: freeDeadlineDate, time: timeNow),
                                        priority: selectedPriority));
                                    }
                                  }
                                  else {
                                    if (_dateController.text == "") {
                                      singleTasks.add(Task(taskName, [], null, null, deadline: null, priority: Priority.none));
                                    }
                                    else {
                                      singleTasks.add(Task(taskName, [], null, null, deadline:
                                        Deadline(date: selectedDate,time: selectedTime),
                                        priority: selectedPriority));
                                    }
                                  }

                                  // Update the UI callback directly here
                                  setState(() {
                                    print("Single Tasks has been created");
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
                  MaterialPageRoute(builder: (context) => CalendarViewMultiPage(projects: projects))
              );
              print('calendar opened!');
            },
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.lightBlue, // Set the color of the larger container
                  child: DateList(projects: projects),
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
                      print('visibility pressed for Item 1');
                      int index = findProjectIndex(project.name);
                      String projectNameToFind = project.name;
                      print('Project "$projectNameToFind" found at index: $index');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainViewPage(project: projects[index])),
                      );

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
