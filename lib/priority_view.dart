import 'package:flutter/material.dart';


class PriorityViewPage extends StatelessWidget {
  const PriorityViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Priority View'),
      ),
      body: const Center(
        child: Text('This is the Priority View'),
      ),
    );
  }
}