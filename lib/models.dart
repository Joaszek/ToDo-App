// models.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // used for calendar widget
import 'package:flutter/services.dart'; //for 'FilteringTextInputFormatter in calendar and clock widget
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as local_notification;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;



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
  String name;
  final List<Errand> errands;
  File? file; // File associated with the task (can be a single file)
  String? link; // Link associated with the task (can be a single link)
  Deadline? deadline; // use ? so that it can be a null value
  Priority priority;
  Color color;
  String? description;
  RepetitionType repetitiontype;
  final int id;


  Task(this.name, this.errands, this.file, this.link, this.id, {this.deadline, Priority priority = Priority.low, this.description, RepetitionType repetitionType = RepetitionType.none})
      : priority = priority,
        color = _getColorForPriority(priority),
        repetitiontype = repetitionType;

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
  String description;
  final int id;

  Project(this.name, this.tasks, this.description, this.id);
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

enum RepetitionType {
  none,
  minutely,
  hourly,
  daily,
  weekly,
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
  final List<Task> singletonTasks;

  const DateList({Key? key, required this.projects, required this.singletonTasks}) : super(key: key);

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
    widget.singletonTasks.forEach((task) {
      if(task.deadline != null) {
        if ( isSameDate(task.deadline!.date!, day)/*task.deadline!.date!.isAtSameMomentAs(day)*/ ) {
          numEvents.add(Event(task.name, priority: task.priority));
        } else {
          //print("no events for this date");//[Event('Task 1', priority: Priority.low)];
        }
      }
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


//***************FOR REPETITION SCROLL***********************//
class RepetitionScroll extends StatefulWidget {
  final void Function(RepetitionType) onRepetitionSelected;

  RepetitionScroll({required this.onRepetitionSelected});

  @override
  _RepetitionScrollState createState() => _RepetitionScrollState();
}

class _RepetitionScrollState extends State<RepetitionScroll> {
  RepetitionType selectedRepetition = RepetitionType.none;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: RepetitionType.values.map((repetition) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Checkbox(
                  value: selectedRepetition == repetition,
                  onChanged: (value) {
                    setState(() {
                      selectedRepetition = repetition;
                      widget.onRepetitionSelected(repetition); // Notify the parent widget
                    });
                  },
                  activeColor: getRepetitionColor(repetition), // Set checkbox color
                ),
                Text(
                  repetitionToString(repetition),
                  style: TextStyle(
                    color: getRepetitionColor(repetition), // Set text color
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color getRepetitionColor(RepetitionType repetition) {
    switch (repetition) {
      case RepetitionType.none:
        return Colors.purple.shade300;
      case RepetitionType.minutely:
        return Colors.purple.shade400;
      case RepetitionType.hourly:
        return Colors.purple.shade500;
      case RepetitionType.daily:
        return Colors.purple.shade600;
      case RepetitionType.weekly:
        return Colors.purple.shade800;
      default:
        return Colors.black;
    }
  }

  String repetitionToString(RepetitionType repetition) {
    switch (repetition) {
      case RepetitionType.none:
        return 'None';
      case RepetitionType.minutely:
        return 'Minutely';
      case RepetitionType.hourly:
        return 'Hourly';
      case RepetitionType.daily:
        return 'Daily';
      case RepetitionType.weekly:
        return 'Weekly';
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


// TO WORK WITH NOTIFICATION
// add this to pubspec.yaml: flutter_local_notifications: ^13.0.0
// add logo to android/app/src/main/res/drawable/flutter_icon.png
// in main.dart, modify your void main() into:
//void main() async {
//  WidgetsFlutterBinding.ensureInitialized();
//  await NotificationService().initNotification();
//
//  runApp(const MyApp());
//}
// that is to solve the error ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: PlatformException(error, Attempt to invoke virtual method 'int java.lang.Integer.intValue()' on a null object reference, null, java.lang.NullPointerException: Attempt to invoke virtual method 'int java.lang.Integer.intValue()' on a null object reference
// you dont actually need to modify AndroidManifest.xml
// provide a sound file in android/app/src/main/res/raw. create raw directory if it does not exist
// or you can just use the default
// WICHTIGE PUNKTE: https://pub.dev/packages/flutter_local_notifications
// Do the relevant things except the buildscript part.
// use the foreground service as well so that notification can be run while the app is closed


class NotificationService {
  final local_notification.FlutterLocalNotificationsPlugin notificationsPlugin = local_notification.FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    local_notification.AndroidInitializationSettings initializationSettingsAndroid =
    const local_notification.AndroidInitializationSettings('flutter_logo');

    var initializationSettingsIOS = local_notification.DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = local_notification.InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (local_notification.NotificationResponse notificationResponse) async {});

    final androidPlugin = notificationsPlugin.resolvePlatformSpecificImplementation<local_notification.AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      androidPlugin.requestNotificationsPermission();
      androidPlugin.requestExactAlarmsPermission();
    } else {
      // Handle the case where the Android plugin is not available
      print("Android plugin is not available");
    }


  }

  notificationDetails() {
    return const local_notification.NotificationDetails(
        android: local_notification.AndroidNotificationDetails('channelId', 'channelName',
          importance: local_notification.Importance.max,
          sound: local_notification.RawResourceAndroidNotificationSound('notification_sound_sample'),),
        iOS: local_notification.DarwinNotificationDetails());
  }

  Future scheduleNotification(
      {int id = 1,
        String? title,
        String? body,
        String? payLoad,
        required DateTime scheduledNotificationDateTime}) async {
    return notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledNotificationDateTime,
          tz.local,
        ),
        await notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        local_notification.UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future showPeriodicallyNotification(
      {int id = 1,
        String? title,
        String? body,
        String? payLoad,
        required RepetitionType repetitionType}
      ) async {
    local_notification.RepeatInterval repeatInterval;
    if(repetitionType == RepetitionType.none) {
      repeatInterval = local_notification.RepeatInterval.everyMinute;
      print("created periodic notification for SingleTask ${title} with repetition type none");
    }
    else if(repetitionType == RepetitionType.minutely) {
      repeatInterval = local_notification.RepeatInterval.everyMinute;
      print("created periodic notification for SingleTask ${title} with repetition type minutely");
    }
    else if(repetitionType == RepetitionType.hourly) {
      repeatInterval = local_notification.RepeatInterval.hourly;
      print("created periodic notification for SingleTask ${title} with repetition type hourly");
    }
    else if(repetitionType == RepetitionType.daily) {
      repeatInterval = local_notification.RepeatInterval.daily;
      print("created periodic notification for SingleTask ${title} with repetition type daily");
    }
    else {
      repeatInterval = local_notification.RepeatInterval.weekly;
      print("created periodic notification for SingleTask ${title} with repetition type weekly");
    }



    return notificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      repeatInterval, // RepeatInterval.everyMinute is used for testing
      local_notification.NotificationDetails(
        android: local_notification.AndroidNotificationDetails(
          'channelId',
          'channelName',
          channelDescription: 'Your channel description',
          importance: local_notification.Importance.max,
          priority: local_notification.Priority.high,  // Set the priority to high for heads-up notification (optional)
          enableVibration: true,  // Enable vibration
          sound: local_notification.RawResourceAndroidNotificationSound('notification_sound_sample'),  // Specify a custom sound
        ),
      ),
      androidAllowWhileIdle: true,
    );
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

}

