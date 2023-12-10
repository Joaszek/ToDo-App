// project_list_screen.dart

import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'models.dart';
import 'package:flutter/services.dart'; //for 'FilteringTextInputFormatter in deadline functionality
import 'main_view.dart';
import 'calendar_view_multi.dart';
import 'singleton_task_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectDescController = TextEditingController();
  final TextEditingController singleTaskController = TextEditingController();
  final TextEditingController singleTaskDescController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _freeMonthController = TextEditingController(text:"0");
  TextEditingController _freeDayController = TextEditingController(text:"0");
  bool isCheckboxChecked = false;
  DateTime selectedDate = DateTime.now(); // Variable to store the selected date from tablecalendar CalendarPopUp
  TimeOfDay selectedTime = TimeOfDay.now(); // Variable to store the selected time from TimePickerPopUp
  Priority selectedPriority = Priority.none;
  RepetitionType selectedRepetition = RepetitionType.none;
  int createdProjects = 2;
  int createdTasks = 4;
  int createdSingletonTask = 0;


  late SpeechRecognitionService _speechRecognitionService;
  String recognizedText = ''; // State variable to hold the recognized text

  late TimeInputFormatter _timeInputFormatter;
  _ProjectListScreenState() {
    // Initialize _timeInputFormatter in the constructor
    _timeInputFormatter = TimeInputFormatter();
    _speechRecognitionService = SpeechRecognitionService(
      onRecognitionComplete: () {},
    );
    initSpeechRecognizer();
  }

  Future<void> initSpeechRecognizer() async {
    bool available = await _speechRecognitionService.initSpeechRecognizer();

    if (available) {
      print('****************************Speech recognizer initialized successfully.');
    } else {
      print('----------------------------Speech recognizer initialization failed.');
    }
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
          11,
          deadline: null,
          description: "Task 1.1 description"
          ),
      Task('Task 1.2', [], null, null, 12, deadline:Deadline(
        date: DateTime(2023, 12, 30), // specify the date component
        time: TimeOfDay(hour: 14, minute: 30), // Specify the time component
      )),
    ], "project 1 description", 1),
    Project('Project 2', [
      Task('Task 2.1', [], null, null, 21, deadline:Deadline(
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
          22,
          deadline:Deadline(
          date: DateTime(2023, 12, 31), // specify the date component
          time: TimeOfDay(hour: 15, minute: 30)), // Specify the time component
          description: "Task 2.2 description"
      ),
    ], "project 2 description", 2),
  ];

  final List<Task> singleTasks = [];

  void deleteSingleTasks(String SingleTaskName) {
    setState(() {
      singleTasks.removeWhere((task) => task.name == SingleTaskName);
    });
  }

  void addProject(String projectName, [String? projectDesc]) {
    setState(() {
      projects.add(Project(projectName, [], projectDesc ?? "", createdProjects+1));
      createdProjects += 1;
    });
  }

  void deleteProject(String projectName) {
    setState(() {
      projects.removeWhere((project) => project.name == projectName);
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
          createdTasks += 1;
        });
        break;
      }
    }
  }

  void deleteTask(String projectName, String taskName) {
    for (var project in projects) {
      if (project.name == projectName) {
        setState(() {
          project.tasks.removeWhere((task) => task.name == taskName);
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

  void deleteErrand(String projectName, String taskName, String errandName) {
    for (var project in projects) {
      if (project.name == projectName) {
        for (var task in project.tasks) {
          if (task.name == taskName) {
            setState(() {
              task.errands.removeWhere((errand) => errand.name == errandName);
            });
            break;
          }
        }
      }
    }
  }

  // Define the updateUI function
  void updateUI() {
    setState(() {
      scheduleNotificationsForProjects(projects);
      schedulePeriodicNotificationsForTasks(singleTasks);
      print("finished creating a scheduled notification for all tasks");
    });
  }

  // Define the updateUI function for TaskListScreen
  void updateTaskList() {
    setState(() {
      scheduleNotificationsForProjects(projects);
      print("finished creating a scheduled notification for all tasks");
    });
  }

  // Define the updateUI function
  void updateSingletonTask() {
    setState(() {
      schedulePeriodicNotificationsForTasks(singleTasks);
      print("finished creating a periodic notification for all singleton tasks");
    });
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
        updateTaskList: updateTaskList,
        deleteErrandCallback: deleteErrand,
        deleteTaskCallback: deleteTask,
        deleteProjectCallback: deleteProject,
        createdTask: createdTasks,
      ),
    );
  }

  MaterialPageRoute<void> navigateToSingletonTaskScreen(Task task) {
    return MaterialPageRoute<void>(
      builder: (context) => SingletonTaskScreen(task: task, updateSingletonTask: updateSingletonTask,),
    );
  }

  void scheduleNotificationsForProjects(List<Project> projects) {
    for (Project project in projects) {
      scheduleNotificationsForTasks(project.tasks);
    }
  }

  void scheduleNotificationsForTasks(List<Task> tasks) {
    for (Task task in tasks) {
      if (task.deadline != null &&
          task.deadline!.date != null &&
          task.deadline!.time != null) {
        DateTime deadlineDateTime = DateTime(
          task.deadline!.date!.year,
          task.deadline!.date!.month,
          task.deadline!.date!.day,
          task.deadline!.time!.hour,
          task.deadline!.time!.minute,
        );

        // Schedule notification for the task deadline
        NotificationService().scheduleNotification(
          id: task.id,
          title: 'Task: ${task.name}',
          body: 'Don\'t forget about your task!',
          scheduledNotificationDateTime: deadlineDateTime,
        );
        print("successfully created notification for task ${task.name} with id ${task.id}");
      }
    }
  }

  void schedulePeriodicNotificationsForTasks(List<Task> tasks) {
    for (Task task in tasks) {
      if (task.repetitiontype != RepetitionType.none) {
        // Schedule periodic notification for the task
        NotificationService().showPeriodicallyNotification(
          id: task.id,
          title: 'SingletonTask: ${task.name}',
          body: 'Don\'t forget about your task!',
          repetitionType: task.repetitiontype,
        );
        print("Successfully created periodic notification for task ${task.name} with id ${task.id}");
      }
    }
  }



  @override
  void initState() {
    super.initState();

    // Call the function to schedule notifications when the widget is initialized
    scheduleNotificationsForProjects(projects);
    print("finished creating a scheduled notification for all tasks");
    print("projects length: ${projects.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do app'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Explore',
            onPressed: () async {
              // Implement the desired action when the Explore button is pressed
              print('Speech-to-text button pressed');

              if (!_speechRecognitionService.isListening) {
                _speechRecognitionService.startListening();
              } else {
                _speechRecognitionService.stopListening(); // Make sure to await the stopListening to ensure it completes before moving on

                recognizedText = _speechRecognitionService.recognizedText;
                print("in project_list_screen: $recognizedText");

                // Check for specific words
                // Check for specific words and extract text after "name"
                if (containsWords(['create', 'project', 'name'], recognizedText)) {
                  String textAfterName = extractTextAfterKeyword('name', recognizedText);
                  if (textAfterName.isNotEmpty) {
                    // Perform actions with the extracted text
                    print('Text after "name": $textAfterName');
                    addProject(textAfterName);

                    // Reset recognizedText to avoid creating another project instantly
                    recognizedText = '';
                  }
                }

                _speechRecognitionService.reset(); // Reset the service after stopping listening
              }

              setState(() {});
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
                          content: Column (
                            children: [
                              TextField(
                                controller: projectNameController,
                                decoration: const InputDecoration(labelText: 'Project Name'),
                              ),
                              TextField(
                                controller: projectDescController,
                                decoration: const InputDecoration(labelText: 'Project Description'),
                              ),
                            ],
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
                                  addProject(projectName, projectDescController.text);
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
                                    TextField(
                                      controller: singleTaskDescController,
                                      decoration:
                                      const InputDecoration(labelText: 'Task Description'),
                                    ),
                                    const SizedBox(height: 50),
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
                                    const Text('Repetition'),
                                    RepetitionScroll(
                                      onRepetitionSelected: (repetition) {
                                        // Use the selectedRepetition as needed
                                        print('Selected Priority: $repetition');
                                        selectedRepetition = repetition;
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
                                String taskDesc = singleTaskDescController.text;
                                int id = int.parse('999${createdSingletonTask+1}');
                                if (taskName.isNotEmpty) {
                                  print("Task name is $taskName");
                                  if(isCheckboxChecked) {
                                    if (_freeDayController.text == "0" && _freeMonthController.text == "0") {
                                      singleTasks.add(Task(taskName, [], null, null, id, deadline: null, priority: Priority.none, description: taskDesc, repetitionType: selectedRepetition));
                                    }
                                    else {
                                      int nMonth = int.parse(_freeMonthController.text);
                                      int nDay = int.parse(_freeDayController.text);
                                      print("month is $nMonth, day is $nDay");
                                      final now = DateTime.now();
                                      final timeNow = TimeOfDay.now();
                                      final freeDeadlineDate = now.add(Duration(days: nMonth * 30 + nDay));
                                      singleTasks.add(Task(taskName, [], null, null, id, deadline:
                                        Deadline(date: freeDeadlineDate, time: timeNow),
                                        priority: selectedPriority,
                                        description: taskDesc,
                                        repetitionType: selectedRepetition));
                                    }
                                  }
                                  else {
                                    if (_dateController.text == "") {
                                      singleTasks.add(Task(taskName, [], null, null, id, deadline: null, priority: Priority.none, description: taskDesc, repetitionType: selectedRepetition));
                                    }
                                    else {
                                      singleTasks.add(Task(taskName, [], null, null, id, deadline:
                                        Deadline(date: selectedDate,time: selectedTime),
                                        priority: selectedPriority,
                                        description: taskDesc,
                                        repetitionType: selectedRepetition));
                                    }
                                  }

                                  // Update the UI callback directly here
                                  setState(() {
                                    print("Single Tasks has been created");
                                    schedulePeriodicNotificationsForTasks(singleTasks);
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
                  MaterialPageRoute(builder: (context) => CalendarViewMultiPage(projects: projects, singletonTasks: singleTasks))
              );
              print('calendar opened!');
            },
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.lightBlue, // Set the color of the larger container
                  child: DateList(projects: projects, singletonTasks: singleTasks),
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Explore',
                    onPressed: () {
                      print('deleting singleton Task');
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm Deletion"),
                            content: Text("Are you sure you want to delete the singleton Task?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // User pressed 'Yes', perform deletion logic here
                                  print("Deleting the Singleton Task");
                                  deleteSingleTasks(task.name);
                                  NotificationService().cancelNotification(task.id);
                                  Navigator.of(context).pop(); // Close the AlertDialog
                                },
                                child: Text("Yes"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // User pressed 'No', close the AlertDialog
                                  Navigator.of(context).pop();
                                },
                                child: Text("No"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context, navigateToSingletonTaskScreen(task),
                    );

                    // When returning from the TaskListScreen, update the UI to
                    // reflect the new task completion status.
                    setState(() {});

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
