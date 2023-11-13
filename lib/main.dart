import 'package:flutter/material.dart';
import 'project_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: HomePage(title: 'Title'),
      home: ProjectListScreen(),
    );
  }
}

