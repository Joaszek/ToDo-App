// models.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // used for calendar widget
import 'package:flutter/services.dart'; //for 'FilteringTextInputFormatter in calendar and clock widget


class Deadline {
  DateTime? date;
  TimeOfDay? time;

  Deadline({this.date, this.time});
}

class Errand {
  final String name;
  bool isComplete;

  Errand(this.name, this.isComplete);
}

class Task {
  final String name;
  final List<Errand> errands;
  String? file; // File associated with the task (can be a single file)
  String? link; // Link associated with the task (can be a single link)
  Deadline? deadline; // use ? so that it can be a null value
  final Priority priority;
  final Color color;

  Task(this.name, this.errands, this.file, this.link, {this.deadline, Priority priority = Priority.low})
      : priority = priority,
        color = _getColorForPriority(priority);

  static Color _getColorForPriority(Priority priority) {
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
        return Colors.blue;
    }
  }
}

class Project {
  final String name;
  final List<Task> tasks;

  Project(this.name, this.tasks);
}

class Event {
  final String title;
  final Priority priority;
  final Color color;

  Event(this.title, {required this.priority})
      : color = _getColorForPriority(priority);

  static Color _getColorForPriority(Priority priority) {
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
        return Colors.blue;
    }
  }
}

enum Priority {
  high,
  medium,
  low,
  none,
}


//************* USED FOR CLOCK WIDGET *************//

class TimePickerPopup extends StatefulWidget {
  final StateSetter setState;
  final void Function(TimeOfDay selectedTime) onTimeSelected;

  const TimePickerPopup({super.key, required this.setState, required this.onTimeSelected});

  @override
  _TimePickerPopupState createState() => _TimePickerPopupState();
}

class _TimePickerPopupState extends State<TimePickerPopup> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectTime(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Adjust the width as needed
      height: 300, // Adjust the height as needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 20),
          Text(
            'Selected Time: ${_selectedTime.format(context)}',
            style: const TextStyle(fontSize: 20.0),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      print('Selected Time: ${_selectedTime.format(context)}'); // Print the selected time
      widget.onTimeSelected(_selectedTime); // Call the callback with the selected time
    }
    Navigator.pop(context); // Close the popup after selecting the time
  }
}


class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newText.isNotEmpty) {
      if (newText.length >= 3) {
        final hour = newText.substring(0, 2);
        final minute = newText.substring(2);
        newText = '$hour:$minute';
      }
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
//************************************************//

//************* USED FOR CALENDAR WIDGET *************//
class CalendarPopup extends StatefulWidget {
  final StateSetter setState;
  final void Function(DateTime selectedDay) onDaySelected; //callback to get the selectedDay

  const CalendarPopup({super.key, required this.setState, required this.onDaySelected});

  @override
  _CalendarPopupState createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500, // Adjust the width as needed
      height: 500, // Adjust the height as needed
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 01, 01),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          widget.setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          widget.onDaySelected(selectedDay); // Call the callback
        },
      ),
    );
  }
}


class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Enforce a maximum length of 8 characters
    if (newText.length > 8) {
      newText = newText.substring(0, 8);
    }

    if (newText.length == 5 && !newText.contains('-')) {
      newText = '${newText.substring(0, 4)}-${newText.substring(4)}';
    } else if (newText.length == 8 && !newText.endsWith('-')) {
      newText = '${newText.substring(0, 4)}-${newText.substring(4, 6)}-${newText.substring(6)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
//***************************************************//


//************* USED FOR FREE DEADLINE *************//
class TwoDigitInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Enforce a maximum length of 2 characters
    if (newText.length > 2) {
      newText = newText.substring(0, 2);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
//***************************************************//


//************* USED FOR FRONT CALENDAR *************//
class DateList extends StatelessWidget {
  const DateList({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the first 50 dates starting from today
    List<DateTime> firstThirtyDates = List.generate(
      30,
          (index) => DateTime.now().add(Duration(days: index)),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: firstThirtyDates
            .map(
              (date) => DateItem(date: date, events: getSampleEvents(date.day)),
        )
            .toList(),
      ),
    );
  }

  // Sample function to generate events for demonstration purposes
  List<Event> getSampleEvents(int day) {
    if (day % 2 == 0) {
      return [Event('Task 1', priority: Priority.high), Event('Task 1', priority: Priority.medium)];
    } else {
      return [Event('Task 1', priority: Priority.low)];
    }
  }
}

class DateItem extends StatelessWidget {
  final DateTime date;
  final List<Event> events;

  const DateItem({super.key, required this.date, required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50, // Set a fixed width for the DateItem
      height: 70, // Set a fixed height for the DateItem
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white, // Set the background color of the smaller container
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            getMonthAbbreviation(date.month),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            '${date.day}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: events.map((event) {
              return Container(
                margin: const EdgeInsets.only(right: 4),
                width: 6, // Adjust the width of the dots
                height: 6, // Adjust the height of the dots
                decoration: BoxDecoration(
                  color: event.color,
                  shape: BoxShape.circle,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String getMonthAbbreviation(int month) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }
}
//***************************************************//