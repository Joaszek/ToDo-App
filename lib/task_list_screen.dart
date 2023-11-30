// task_list_screen.dart

import 'package:flutter/material.dart';
import 'errand_list_screen.dart';
import 'models.dart';
import 'package:flutter/services.dart';

class TaskListScreen extends StatefulWidget {
  final Project project;
  final Function(String, Task) addTaskCallback;
  final Function(String, String, Errand) addErrandCallback;
  final VoidCallback updateUICallback;

  TaskListScreen({
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
  final TextEditingController projectDescriptionController =
  TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  bool isCheckboxChecked = false;

  late TimeInputFormatter _timeInputFormatter;

  _TaskListScreenState() {
    _timeInputFormatter = TimeInputFormatter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: projectDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Project Description',
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            Divider(color: Colors.black),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    'Task List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Create a New Task'),
                            content: SingleChildScrollView(
                              child: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: taskNameController,
                                        decoration: InputDecoration(
                                            labelText: 'Task Name'),
                                      ),
                                      SizedBox(height: 100),
                                      Text('Deadline'),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Text('Date:'),
                                          SizedBox(width: 5),
                                          Flexible(
                                            child: TextField(
                                              controller: _dateController,
                                              decoration: InputDecoration(
                                                labelText: 'YYYY-MM-DD',
                                              ),
                                              keyboardType:
                                              TextInputType.datetime,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    10),
                                                DateInputFormatter(),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.calendar_month),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('Select date'),
                                                    content: StatefulBuilder(
                                                      builder: (
                                                          BuildContext context,
                                                          StateSetter setState,
                                                          ) {
                                                        return CalendarPopup(
                                                            setState: setState);
                                                      },
                                                    ),
                                                    actions: <Widget>[
                                                      new TextButton(
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
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Text('Time:'),
                                          SizedBox(width: 5),
                                          Flexible(
                                            child: TextField(
                                              controller: _timeController,
                                              decoration: InputDecoration(
                                                labelText: 'Enter time (HH:MM)',
                                              ),
                                              keyboardType:
                                              TextInputType.datetime,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    4),
                                                _timeInputFormatter,
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.access_time),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (
                                                    BuildContext context,
                                                    ) {
                                                  return AlertDialog(
                                                    title: Text('Select time'),
                                                    content: StatefulBuilder(
                                                      builder: (
                                                          BuildContext context,
                                                          StateSetter setState,
                                                          ) {
                                                        return TimePickerPopup(
                                                            setState: setState);
                                                      },
                                                    ),
                                                    actions: <Widget>[
                                                      new TextButton(
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
                                      Row(
                                        children: [
                                          Text('Free deadline'),
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
                                          Flexible(
                                            child: TextField(
                                              enabled: isCheckboxChecked,
                                            ),
                                          ),
                                          Text("Month"),
                                          Flexible(
                                            child: TextField(
                                              enabled: isCheckboxChecked,
                                            ),
                                          ),
                                          Text("Day"),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
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
                                  String taskName = taskNameController.text;
                                  if (taskName.isNotEmpty) {
                                    widget.addTaskCallback(
                                      widget.project.name,
                                      Task(taskName, [], null, null),
                                    );
                                    setState(() {
                                      widget.updateUICallback();
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
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15),
                    ),
                    child: Icon(Icons.add, size: 30),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.black),
            Expanded(
              child: ListView.builder(
                itemCount: widget.project.tasks.length,
                itemBuilder: (context, index) {
                  final task = widget.project.tasks[index];
                  final allErrandsComplete = task.errands.isNotEmpty &&
                      task.errands.every((errand) => errand.isComplete);

                  return Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ErrandListScreen(
                              project: widget.project,
                              task: task,
                              addErrandCallback: widget.addErrandCallback,
                              updateUICallback: widget.updateUICallback,
                            ),
                          ),
                        );

                        widget.updateUICallback();
                      },
                      style: ElevatedButton.styleFrom(
                        primary:
                        allErrandsComplete ? Colors.green : Colors.black,
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
                            color: Colors.white,
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
    );
  }
}
