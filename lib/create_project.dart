import 'package:flutter/material.dart';
import 'create_task.dart'; // Import create project page

class createProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Project'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Add your onPressed function here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => createTaskPage()),
                );
                print('new task Button pressed');
              },
              child: Text('New task Button'),
            ),
          ],
        ),
      ),
    );
  }
}