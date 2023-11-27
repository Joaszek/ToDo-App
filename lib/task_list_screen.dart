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

  const TaskListScreen({super.key,
    required this.project,
    required this.addTaskCallback,
    required this.updateUICallback,
    required this.addErrandCallback,
  });

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  TextEditingController _freeMonthController = TextEditingController();
  TextEditingController _freeDayController = TextEditingController();
  bool isCheckboxChecked = false;
  DateTime selectedDate = DateTime.now(); // Variable to store the selected date from tablecalendar
  TimeOfDay selectedTime = TimeOfDay.now(); // Variable to store the selected time from TimePickerPopUp

  late TimeInputFormatter _timeInputFormatter;
  _TaskListScreenState() {
    // Initialize _timeInputFormatter in the constructor
    _timeInputFormatter = TimeInputFormatter();
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
                  builder: (context) => ErrandListScreen(
                    widget.project,
                    task,
                    widget.addErrandCallback,
                    widget.updateUICallback,
                  ),
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
                          )

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
                      if (taskName.isNotEmpty) {
                          if(_dateController.text == "") {
                            widget.addTaskCallback(widget.project.name,
                                Task(taskName, [], null, null,
                                    deadline: null));
                          }
                          else {
                            widget.addTaskCallback(widget.project.name,
                                Task(taskName, [], null, null,
                                    deadline: Deadline(date: selectedDate,
                                        time: selectedTime)));
                          }
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
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
