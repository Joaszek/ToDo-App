// task_list_screen.dart

import 'package:flutter/material.dart';
import 'errand_list_screen.dart';
import 'models.dart';
import 'package:flutter/services.dart'; //for 'FilteringTextInputFormatter in deadline functionality

class TaskListScreen extends StatefulWidget {
  final Project project;
  final Function(String, Task) addTaskCallback;
  final Function(String, String, Errand) addErrandCallback;
  final VoidCallback updateUICallback;
  final VoidCallback updateTaskList;
  final Function(String, String, String) deleteErrandCallback;
  final Function(String, String) deleteTaskCallback;
  final Function(String) deleteProjectCallback;

  const TaskListScreen({super.key,
    required this.project,
    required this.addTaskCallback,
    required this.updateUICallback,
    required this.addErrandCallback,
    required this.updateTaskList,
    required this.deleteErrandCallback,
    required this.deleteTaskCallback,
    required this.deleteProjectCallback,
  });

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescController = TextEditingController(text:"");
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  TextEditingController _freeMonthController = TextEditingController(text:"0");
  TextEditingController _freeDayController = TextEditingController(text:"0");
  TextEditingController projectDescriptionController = TextEditingController();
  bool isCheckboxChecked = false;
  DateTime selectedDate = DateTime.now(); // Variable to store the selected date from tablecalendar
  TimeOfDay selectedTime = TimeOfDay.now(); // Variable to store the selected time from TimePickerPopUp
  Priority selectedPriority = Priority.none;

  late SpeechRecognitionService _speechRecognitionService;
  String recognizedText = ''; // State variable to hold the recognized text


  late TimeInputFormatter _timeInputFormatter;
  _TaskListScreenState() {
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





  double calculateProjectProgress() {
    int totalPoints = 0;
    int completedPoints = 0;

    // Calculate total available points and completed points
    for (Task task in widget.project.tasks) {
      for (Errand errand in task.errands) {
        totalPoints += getPointsForPriority(task.priority);
        if (errand.isComplete) {
          completedPoints += getPointsForPriority(task.priority);
        }
      }
    }

    // Calculate progress percentage
    double progressPercentage = totalPoints != 0 ? (completedPoints / totalPoints) * 100 : 0.0;

    return progressPercentage;
  }

  int getPointsForPriority(Priority priority) {
    switch (priority) {
      case Priority.none:
        return 1;
      case Priority.low:
        return 2;
      case Priority.medium:
        return 3;
      case Priority.high:
        return 4;
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Explore',
            onPressed: () {
              // Implement the desired action when the Explore button is pressed
              print('Speech-to-text button pressed');
              if (!_speechRecognitionService.isListening) {
                _speechRecognitionService.startListening();
              } else {
                _speechRecognitionService.stopListening();

                recognizedText = _speechRecognitionService.recognizedText;
                print("in task_list_screen: $recognizedText");

                // Check for specific words
                // Check for specific words and extract text after "name"
                if (containsWords(['create', 'task', 'name'], recognizedText)) {
                  String textAfterName = extractTextAfterKeyword('name', recognizedText);
                  if (textAfterName.isNotEmpty) {
                    // Perform actions with the extracted text
                    print('Text after "name": $textAfterName');
                    widget.addTaskCallback(widget.project.name,
                        Task(textAfterName, [], null, null, widget.project.tasks.length+1, deadline: null, priority: Priority.none));

                    // Reset recognizedText to avoid creating another project instantly
                    recognizedText = '';
                  }
                }

                _speechRecognitionService.reset(); // Reset the service after stopping listening
              }
              setState(() {});

            },
          ),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Show AlertDialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm Deletion"),
                      content: Text("Are you sure you want to delete the project?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // User pressed 'Yes', perform deletion logic here
                            print("Deleting the project");
                            widget.deleteProjectCallback(widget.project.name);
                            Navigator.of(context).pop(); // Close the AlertDialog
                            Navigator.of(context).pop();
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
              }
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlue,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: projectDescriptionController,
                  decoration: InputDecoration(
                    labelText: widget.project.description,
                    fillColor: Colors.lightBlue,
                    filled: true,
                  ),
                ),
              ),


              const SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Project Progress: ${calculateProjectProgress().toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(calculateProjectProgress()),
                  ),
                ),
              ),


              const SizedBox(height: 75),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                  color: Colors.blue.shade500, // Set the background color
                ),
                padding: EdgeInsets.all(16.0), // Adjust the padding as needed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            'Task List',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () {  //*********************** START OF ADD TASK BUTTON
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
                                                controller: taskNameController,
                                                decoration:
                                                const InputDecoration(labelText: 'Task Name'),
                                              ),
                                              TextField(
                                                controller: taskDescController,
                                                decoration:
                                                const InputDecoration(labelText: 'Task Description'),
                                              ),
                                              const SizedBox(height: 50),
                                              const Text('Deadline'),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
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
                                                      icon: const Icon(Icons.access_time),
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
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Create'),
                                        onPressed: () {
                                          String taskName = taskNameController.text;
                                          String taskDesc = taskDescController.text;
                                          int id = int.parse('${widget.project.id}${widget.project.tasks.length + 1}');
                                          if (taskName.isNotEmpty) {
                                            print("Task name is $taskName");
                                            if(isCheckboxChecked) {
                                              if (_freeDayController.text == "0" && _freeMonthController.text == "0") {
                                                widget.addTaskCallback(widget.project.name,
                                                    Task(taskName, [], null, null, id, deadline: null, priority: Priority.none, description: taskDesc));
                                              }
                                              else {
                                                int nMonth = int.parse(_freeMonthController.text);
                                                int nDay = int.parse(_freeDayController.text);
                                                print("month is $nMonth, day is $nDay");
                                                final now = DateTime.now();
                                                final timeNow = TimeOfDay.now();
                                                final freeDeadlineDate = now.add(Duration(days: nMonth * 30 + nDay));
                                                widget.addTaskCallback(widget.project.name,
                                                    Task(taskName, [], null, null, id,
                                                        deadline: Deadline(date: freeDeadlineDate, time: timeNow),
                                                        priority: selectedPriority,
                                                        description: taskDesc));
                                              }
                                            }
                                            else {
                                              if (_dateController.text == "") {
                                                widget.addTaskCallback(widget.project.name,
                                                    Task(taskName, [], null, null, id, deadline: null, priority: Priority.none, description: taskDesc));
                                              }
                                              else {
                                                widget.addTaskCallback(widget.project.name,
                                                    Task(taskName, [], null, null, id,
                                                        deadline: Deadline(date: selectedDate, time: selectedTime),
                                                        priority: selectedPriority,
                                                        description: taskDesc));
                                              }
                                            }
                                            // Update the UI callback directly here
                                            setState(() {
                                              widget.updateUICallback();
                                            });
                                          }
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ); //*********************** FINISH OF ADD TASK BUTTON
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(
                                side: BorderSide(
                                  color: Colors.black, // Set the border color
                                  width: 2.0, // Set the border width
                                ),
                              ),
                              padding: EdgeInsets.all(5),
                            ),
                            child: Icon(Icons.add, size: 30, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('To Do'),
                    Divider(color: Colors.black),
                    Container(
                      height: 175,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.project.tasks.length,
                        itemBuilder: (context, index) {
                          final task = widget.project.tasks[index];
                          final allErrandsComplete = task.errands.isNotEmpty &&
                              task.errands.every((errand) => errand.isComplete);

                          if (allErrandsComplete) {
                            // If all errands are complete, don't display it in the current container.
                            return Container();
                          }

                          return Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ErrandListScreen(
                                      widget.project,
                                      task,
                                      widget.addErrandCallback,
                                      widget.updateUICallback,
                                      widget.updateTaskList,
                                      widget.deleteErrandCallback,
                                      widget.deleteTaskCallback,
                                    ),
                                  ),
                                );
                                // Trigger the updateTaskList callback after returning from ErrandListScreen
                                setState(() {
                                  widget.updateTaskList();
                                  widget.updateUICallback();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: allErrandsComplete ? Colors.green : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: Size(double.infinity, 0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  task.name,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Completed'),
                    Divider(color: Colors.black),
                    Container(
                      height: 175,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.project.tasks.length,
                        itemBuilder: (context, index) {
                          final task = widget.project.tasks[index];
                          final allErrandsComplete = task.errands.isNotEmpty &&
                              task.errands.every((errand) => errand.isComplete);

                          if (!allErrandsComplete) {
                            // If not all errands are complete, don't display it in the current container.
                            return Container();
                          }

                          return Container(
                            margin: EdgeInsets.all(8),
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ErrandListScreen(
                                      widget.project,
                                      task,
                                      widget.addErrandCallback,
                                      widget.updateUICallback,
                                      widget.updateTaskList,
                                      widget.deleteErrandCallback,
                                      widget.deleteTaskCallback,
                                    ),
                                  ),
                                );
                                // Trigger the updateTaskList callback after returning from ErrandListScreen
                                setState(() {
                                  widget.updateTaskList();
                                  widget.updateUICallback();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green, // Display completed tasks in green
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: Size(double.infinity, 0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  task.name,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),



            ]
        ),
      ),
    );
  }
  Color _getProgressColor(double progress) {
    if (progress < 40) {
      return Colors.red;
    } else if (progress < 80) {
      return Colors.yellow;
    } else if (progress == 100) {
      return Colors.purple;
    } else {
      return Colors.green;
    }
  }
}
