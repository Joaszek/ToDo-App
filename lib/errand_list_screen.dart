// errand_list_screen.dart

import 'package:flutter/material.dart';
import 'models.dart';

class ErrandListScreen extends StatefulWidget {
  final Project project;
  final Task task;
  final Function(String, String, Errand) addErrandCallback;
  final VoidCallback updateUICallback;

  ErrandListScreen({
    required this.project,
    required this.task,
    required this.addErrandCallback,
    required this.updateUICallback,
  });

  @override
  _ErrandListScreenState createState() => _ErrandListScreenState();
}

class _ErrandListScreenState extends State<ErrandListScreen> {
  final TextEditingController errandNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blue.shade800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: taskDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Task Description',
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
                    'Errand List',
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
                            title: Text('Create a New Errand'),
                            content: SingleChildScrollView(
                              child: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextField(
                                        controller: errandNameController,
                                        decoration: InputDecoration(
                                          labelText: 'Errand Name',
                                        ),
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
                                  String errandName = errandNameController.text;
                                  if (errandName.isNotEmpty) {
                                    widget.addErrandCallback(
                                      widget.project.name,
                                      widget.task.name,
                                      Errand(errandName, false),
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
                itemCount: widget.task.errands.length,
                itemBuilder: (context, index) {
                  final errand = widget.task.errands[index];

                  return Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle tapping on errands
                      },
                      style: ElevatedButton.styleFrom(
                        primary:
                        errand.isComplete ? Colors.green : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(double.infinity, 0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              errand.name,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors.transparent,
                                ),
                                child: Checkbox(
                                  value: errand.isComplete,
                                  onChanged: (value) {
                                    // Handle changing the errand completion status
                                    setState(() {
                                      errand.isComplete = value ?? false;
                                      widget.updateUICallback();
                                    });
                                  },
                                  checkColor: Colors.black,
                                  activeColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
