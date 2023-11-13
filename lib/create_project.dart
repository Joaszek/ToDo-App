import 'package:flutter/material.dart';
import 'create_task.dart';

class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
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
                  MaterialPageRoute(builder: (context) => const CreateNewTask()),
                );
              },
              child: const Text('New task Button'),
            ),
          ],
        ),
      ),
    );
  }
}