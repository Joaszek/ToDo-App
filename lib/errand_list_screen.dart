import 'package:flutter/material.dart';
import 'models.dart';

class ErrandListScreen extends StatefulWidget {
  final Project project;
  final Task task;
  final Function(String, String, Errand) addErrandCallback;
  final VoidCallback updateUICallback;

  const ErrandListScreen(
      this.project, this.task, this.addErrandCallback, this.updateUICallback, {super.key});

  @override
  _ErrandListScreenState createState() => _ErrandListScreenState();
}

class _ErrandListScreenState extends State<ErrandListScreen> {
  final TextEditingController errandNameController = TextEditingController();

  // Add a list of file and link controllers for the task
  final TextEditingController fileController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
      ),
      body: Column(
        children: [
          // Add the option to upload a file for the task
          ListTile(
            title: const Text("Upload File"),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Upload File'),
                    content: TextField(
                      controller: fileController,
                      decoration: const InputDecoration(labelText: 'File URL'),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Upload'),
                        onPressed: () {
                          String fileUrl = fileController.text;
                          if (fileUrl.isNotEmpty) {
                            setState(() {
                              widget.task.file = fileUrl;
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
          ),
          // Add the option to add a link for the task
          ListTile(
            title: const Text("Add Link"),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Add Link'),
                    content: TextField(
                      controller: linkController,
                      decoration: const InputDecoration(labelText: 'Link URL'),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Add'),
                        onPressed: () {
                          String linkUrl = linkController.text;
                          if (linkUrl.isNotEmpty) {
                            setState(() {
                              widget.task.link = linkUrl;
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Create a New Errand'),
                content: TextField(
                  controller: errandNameController,
                  decoration: const InputDecoration(labelText: 'Errand Name'),
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
                      String errandName = errandNameController.text;
                      if (errandName.isNotEmpty) {
                        widget.addErrandCallback(
                          widget.project.name,
                          widget.task.name,
                          Errand(errandName, false),
                        );

                        // Update the UI
                        widget.updateUICallback();
                      }
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
