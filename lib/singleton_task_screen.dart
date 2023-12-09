import 'package:flutter/material.dart';
import 'models.dart';
import 'package:intl/intl.dart'; // Import the intl package

class SingletonTaskScreen extends StatefulWidget {
  final Task task;
  final VoidCallback updateSingletonTask;

  SingletonTaskScreen({required this.task, required this.updateSingletonTask});

  @override
  _SingletonTaskScreenState createState() => _SingletonTaskScreenState();
}

class _SingletonTaskScreenState extends State<SingletonTaskScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Priority _selectedPriority;
  late Deadline? _selectedDeadline;
  late RepetitionType _selectedRepetition;

  @override
  void initState() {
    super.initState();

    // Initialize controllers and selected values
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _selectedPriority = widget.task.priority;
    _selectedDeadline = widget.task.deadline ?? null;
    _selectedRepetition = widget.task.repetitiontype;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDeadline = _formatDeadline();

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showEditTaskDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Name: ${widget.task.name}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Task ID: ${widget.task.id}'),
            SizedBox(height: 10),
            Text('Priority: ${widget.task.priority.toString().split('.').last}'),
            SizedBox(height: 10),
            Text('Repetition Type: ${widget.task.repetitiontype.toString().split('.').last}'),
            SizedBox(height: 10),
            Text('Deadline: $formattedDeadline'),
            SizedBox(height: 10),
            Text('Description: ${widget.task.description ?? 'No Description'}'),
            SizedBox(height: 10),
            Text('Color:'),
            Container(
              width: 50,
              height: 20,
              color: widget.task.color,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDeadline() {
    if (widget.task.deadline != null) {
      Deadline deadline = widget.task.deadline!;
      String formattedDate = deadline.date != null
          ? DateFormat.yMd().format(deadline.date!)
          : 'No Date';

      String formattedTime = deadline.time != null
          ? deadline.time!.format(context)
          : 'No Time';

      return '$formattedDate $formattedTime';
    } else {
      return 'No Deadline';
    }
  }

  Future<void> _showEditTaskDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Task Name'),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                DropdownButtonFormField<Priority>(
                  value: _selectedPriority,
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                  items: Priority.values.map((priority) {
                    return DropdownMenuItem<Priority>(
                      value: priority,
                      child: Text(priority.toString().split('.').last),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Priority'),
                ),
                DropdownButtonFormField<RepetitionType>(
                  value: _selectedRepetition,
                  onChanged: (value) {
                    setState(() {
                      _selectedRepetition = value!;
                    });
                  },
                  items: RepetitionType.values.map((repetition) {
                    return DropdownMenuItem<RepetitionType>(
                      value: repetition,
                      child: Text(repetition.toString().split('.').last),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Repetition Type'),
                ),
                // Add date and time pickers for Deadline
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save edited task
                _saveEditedTask();
                widget.updateSingletonTask();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveEditedTask() {
    // Update the task with edited values
    setState(() {
      widget.task.name = _nameController.text;
      widget.task.description = _descriptionController.text;
      widget.task.priority = _selectedPriority;
      widget.task.deadline = _selectedDeadline;
      widget.task.repetitiontype = _selectedRepetition;

      // Update the color based on priority
      widget.task.color = _getColorForPriority(_selectedPriority);
    });
  }

  Color _getColorForPriority(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
      case Priority.none:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
