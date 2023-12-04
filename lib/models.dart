// models.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // used for calendar widget
import 'package:flutter/services.dart'; //for 'FilteringTextInputFormatter in calendar and clock widget
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'dart:io';


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
  File? file; // File associated with the task (can be a single file)
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

class DateList extends StatefulWidget {
  final List<Project> projects;

  const DateList({Key? key, required this.projects}) : super(key: key);

  @override
  _DateListState createState() => _DateListState();
}


class _DateListState extends State<DateList> {
  late List<DateTime> firstThirtyDates;

  @override
  void initState() {
    super.initState();
    // Initialize the firstThirtyDates in the initState
    firstThirtyDates = List.generate(30,
          (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    if (date1.year == date2.year && date1.month == date2.month && date1.day == date2.day) {
      // Handle the case where either date is null (you might want to define how to handle this)
      return true;
    }
    else return false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: firstThirtyDates.map(
              (date) => DateItem(date: date, events: getSampleEvents(date)),
        ).toList(),
      ),
    );
  }

  // Sample function to generate events for demonstration purposes
  List<Event>? getSampleEvents(DateTime day) {
    // if 0,0 or "", deadline=null else deadline exist with the corresponding date
    List<Event> numEvents = [];
    widget.projects.forEach((project) {
      project.tasks.forEach((task) {
        if(task.deadline != null) {
          //print(task.deadline!.date!);
          //print(day);
          if ( isSameDate(task.deadline!.date!, day)/*task.deadline!.date!.isAtSameMomentAs(day)*/ ) {
            numEvents.add(Event(task.name, priority: task.priority));
            //return [Event('Task 1', priority: Priority.high), Event('Task 1', priority: Priority.medium)];
          } else {
            //print("no events for this date");//[Event('Task 1', priority: Priority.low)];
          }
        }

      });
    });
    return numEvents;
  }
}

class DateItem extends StatelessWidget {
  final DateTime date;
  final List<Event>? events;

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
            children: (events ?? []).map((event) {
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

//***************USED FOR PRIORITY SCROLL********************//
class PriorityScroll extends StatefulWidget {
  final void Function(Priority) onPrioritySelected;

  PriorityScroll({required this.onPrioritySelected});

  @override
  _PriorityScrollState createState() => _PriorityScrollState();
}

class _PriorityScrollState extends State<PriorityScroll> {
  Priority selectedPriority = Priority.none;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Priority.values.map((priority) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Checkbox(
                  value: selectedPriority == priority,
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = priority;
                      widget.onPrioritySelected(priority); // Notify the parent widget
                    });
                  },
                  activeColor: getPriorityColor(priority), // Set checkbox color
                ),
                Text(
                  priorityToString(priority),
                  style: TextStyle(
                    color: getPriorityColor(priority), // Set text color
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color getPriorityColor(Priority priority) {
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

  String priorityToString(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
      case Priority.none:
        return 'None';
      default:
        return '';
    }
  }
}
//***************************************************//

//*******************USED FOR SPEECH TO TEXT**********************//
class SpeechRecognitionService {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  VoidCallback onRecognitionComplete; // Callback function to be set in the home page

  SpeechRecognitionService({required this.onRecognitionComplete}) {
    _speech = stt.SpeechToText();
  }

  Future<bool> initSpeechRecognizer() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (error) => print('onError: $error'),
    );

    return available;
  }

  void startListening() {
    if (!_isListening) {
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _text = result.recognizedWords;
            print('Recognized: $_text');
            onRecognitionComplete(); // Invoke the callback function
          }
        },
      );
      _isListening = true;
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  void reset() {
    _text = '';
    _isListening = false;
  }

  bool get isListening => _isListening;
  String get recognizedText => _text;
}

// Function to check if a text contains specific words
bool containsWords(List<String> words, String text) {
  for (String word in words) {
    if (text.toLowerCase().contains(word)) {
      return true;
    }
  }
  return false;
}

// Function to extract text after a keyword
String extractTextAfterKeyword(String keyword, String text) {
  int keywordIndex = text.toLowerCase().indexOf(keyword.toLowerCase());
  if (keywordIndex != -1) {
    return text.substring(keywordIndex + keyword.length).trim();
  }
  return '';
}
//***************************************************//


//*******************USED FOR FILE PICKER WIDGET********************//
class FilePickerService {
  Future<Map<String, String>?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg'],
      );

      if (result != null && result.files.isNotEmpty) {
        // Return a map containing both the file name and path
        return {
          'name': result.files.single.name,
          'path': result.files.single.path!,
        };
      }
    } catch (e) {
      print('File picking error: $e');
    }

    // Return null if no file is selected or an error occurs
    return null;
  }
}


class FileSelectionWidget extends StatefulWidget {
  final Task task;
  final void Function(File? file) onFilePicked;

  FileSelectionWidget({required this.task, required this.onFilePicked});

  @override
  _FileSelectionWidgetState createState() => _FileSelectionWidgetState();
}

class _FileSelectionWidgetState extends State<FileSelectionWidget> {
  FilePickerService _filePickerService = FilePickerService();
  String selectedFileName = '';

  Future<void> _pickFile() async {
    Map<String, String>? fileData = await _filePickerService.pickFile();

    if (fileData != null) {
      setState(() {
        selectedFileName = fileData['name'] ?? '';
      });

      // Update the task's file using the callback function
      widget.onFilePicked(File(fileData['path'] ?? ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayFileName = widget.task.file != null ? getFileDisplayName(widget.task.file!) : '';

    return Container(
      child: Row(
        children: [
          Text('    Add File', style: TextStyle(fontSize: 17)),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.file_copy_outlined),
            onPressed: _pickFile,
          ),
          SizedBox(width: 10),
          Text(displayFileName),
        ],
      ),
    );
  }

  String getFileDisplayName(File file) {
    return file.uri.pathSegments.last; // Get the last segment of the path, which is the file name
  }
}



//***************************************************//

//**************USED FOR LINK INSERT WIDGET*******************//
class LinkInsertionWidget extends StatefulWidget {
  final Task task;
  final void Function(String link) onLinkInserted;

  LinkInsertionWidget({required this.task, required this.onLinkInserted});

  @override
  _LinkInsertionWidgetState createState() => _LinkInsertionWidgetState();
}

class _LinkInsertionWidgetState extends State<LinkInsertionWidget> {
  TextEditingController linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text('    Insert Link', style: TextStyle(fontSize: 17)),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.link),
            onPressed: _insertLink,
          ),
          SizedBox(width: 10),
          Text(widget.task.link ?? ''),
        ],
      ),
    );
  }

  void _insertLink() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insert Link'),
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
              child: const Text('Insert'),
              onPressed: () {
                String linkUrl = linkController.text;
                if (linkUrl.isNotEmpty) {
                  setState(() {
                    widget.task.link = linkUrl;
                  });
                  widget.onLinkInserted(linkUrl);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
//***************************************************//