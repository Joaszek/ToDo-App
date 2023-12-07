// errand_list_screen.dart

import 'package:flutter/material.dart';
import 'models.dart';
import 'package:intl/intl.dart';
import 'dart:io';



class ErrandListScreen extends StatefulWidget {
  final Project project;
  final Task task;
  final Function(String, String, Errand) addErrandCallback;
  final VoidCallback updateUICallback;
  final VoidCallback updateTaskListCallback;

  const ErrandListScreen(
      this.project, this.task, this.addErrandCallback, this.updateUICallback,  this.updateTaskListCallback, {super.key});

  @override
  _ErrandListScreenState createState() => _ErrandListScreenState();
}

class _ErrandListScreenState extends State<ErrandListScreen> {
  final TextEditingController errandNameController = TextEditingController();
  final TextEditingController taskDescriptionController = TextEditingController();

  // Add a list of file and link controllers for the task
  final TextEditingController fileController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  late SpeechRecognitionService _speechRecognitionService;
  String recognizedText = ''; // State variable to hold the recognized text

  String selectedFileName = '';
  String selectedFilePath = '';

  _ErrandListScreenState() {
    // Initialize _timeInputFormatter in the constructor
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
        centerTitle: true,
        backgroundColor: Colors.blue.shade500,
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
                print("in errand_list_screen: $recognizedText");

                // Check for specific words
                // Check for specific words and extract text after "name"
                if (containsWords(['create', 'errand', 'name'], recognizedText)) {
                  String textAfterName = extractTextAfterKeyword('name', recognizedText);
                  if (textAfterName.isNotEmpty) {
                    // Perform actions with the extracted text
                    print('Text after "name": $textAfterName');
                    widget.addErrandCallback(
                      widget.project.name,
                      widget.task.name,
                      Errand(textAfterName, false),
                    );

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
      body: Container(
        color: Colors.blue.shade500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: taskDescriptionController,
                decoration: InputDecoration(
                  labelText: widget.task.description,
                  fillColor: Colors.blue.shade500,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('  Deadline: ', style: TextStyle(fontSize: 16),),
                const SizedBox(width: 5),
                if (widget.task.deadline != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ' ${DateFormat('yyyy-MM-dd').format(widget.task.deadline!.date ?? DateTime.now())}',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                else
                  const Text(' None ', style: TextStyle(fontSize: 16),),
              ]
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                color: Colors.deepPurpleAccent, // Set the background color
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
                          'Errand List',
                          style: TextStyle(
                            color: Colors.black,
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
                  const SizedBox(height: 15),
                  const Text('To Do'),
                  Divider(color: Colors.black),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      itemCount: widget.task.errands.length,
                      itemBuilder: (context, index) {
                        final errand = widget.task.errands[index];
                        if (errand.isComplete) {
                          // If all errands are complete, don't display it in the current container.
                          return Container();
                        }

                        return Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle tapping on errands
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: errand.isComplete ? Colors.green : Colors.black,
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
                                    width: 24, // Adjust the width as needed for the circle size
                                    height: 24, // Adjust the height as needed for the circle size
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Colors.white,
                                    ),
                                    child: Theme(
                                      data: ThemeData(
                                        unselectedWidgetColor: Colors.transparent,
                                      ),
                                      child: Transform.scale(
                                        scale: 1.5,
                                        child: Checkbox(
                                          value: errand.isComplete,
                                          onChanged: (value) {
                                            // Handle changing the errand completion status
                                            setState(() {
                                              errand.isComplete = value ?? false;

                                              // Check if all errands are complete after updating
                                              bool allErrandsComplete = widget.task.errands.every((errand) => errand.isComplete);

                                              if(allErrandsComplete) {
                                                print("All errands are complete. Updating task list...");
                                                widget.updateTaskListCallback();
                                              }

                                              widget.updateUICallback();
                                            });
                                          },
                                          checkColor: Colors.black,
                                          activeColor: Colors.white,
                                        ),
                                      )
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
                  const SizedBox(height: 20),
                  const Text('Completed'),
                  Divider(color: Colors.black),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      itemCount: widget.task.errands.length,
                      itemBuilder: (context, index) {
                        final errand = widget.task.errands[index];
                        if (!errand.isComplete) {
                          // If all errands are complete, don't display it in the current container.
                          return Container();
                        }

                        return Container(
                          margin: EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle tapping on errands
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: errand.isComplete ? Colors.green : Colors.black,
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
                                    width: 24, // Adjust the width as needed for the circle size
                                    height: 24, // Adjust the height as needed for the circle size
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Colors.white,
                                    ),
                                    child: Theme(
                                        data: ThemeData(
                                          unselectedWidgetColor: Colors.transparent,
                                        ),
                                        child: Transform.scale(
                                          scale: 1.5,
                                          child: Checkbox(
                                            value: errand.isComplete,
                                            onChanged: (value) {
                                              // Handle changing the errand completion status
                                              setState(() {
                                                errand.isComplete = value ?? false;

                                                // Check if all errands are complete after updating
                                                bool allErrandsComplete = widget.task.errands.every((errand) => errand.isComplete);

                                                if(allErrandsComplete) {
                                                  print("All errands are complete. Updating task list...");
                                                  widget.updateTaskListCallback();
                                                }

                                                widget.updateUICallback();
                                              });
                                            },
                                            checkColor: Colors.black,
                                            activeColor: Colors.white,
                                          ),
                                        )
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

            // Add the option to upload a file for the task
            FileSelectionWidget(
              task: widget.task,
              onFilePicked: (File? file) {
                widget.task.file = file;
              },
            ),
            // Add the option to add a link for the task
            LinkInsertionWidget(
              task: widget.task, // Replace 'yourTaskObject' with your actual Task object
              onLinkInserted: (String link) {
                // Handle the inserted link as needed
                print('Link inserted: $link');
              },
            )
          ],
        ),
      )


    );
  }
}
