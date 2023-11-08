import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //for 'FilteringTextInputFormatter
import 'package:table_calendar/table_calendar.dart';

/*content: StatefulBuilder(
builder: (BuildContext context, StateSetter setState) {
return CalendarPopup(setState: setState);
},
),*/

class createTaskPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    TextEditingController _dateController = TextEditingController();
    TextEditingController _timeController = TextEditingController();
    late TimeInputFormatter _timeInputFormatter;
    _timeInputFormatter = TimeInputFormatter();
    bool _value = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    bool _showCalendar = false;
                    return AlertDialog(
                      title: const Text('Deadline'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              labelText: 'Enter Date (YYYY-MM-DD)',
                            ),
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                              // Add custom input formatter for date format
                              _DateInputFormatter(),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_month),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Select date'),
                                    content: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return CalendarPopup(setState: setState);
                                      },
                                    ),
                                    actions: <Widget>[
                                      new TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Select'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          TextField(
                            controller: _timeController,
                            decoration: InputDecoration(
                              labelText: 'Enter time (HH:MM)',
                            ),
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _timeInputFormatter,
                            ],
                          ),
                          StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Row(
                                children: [
                                  Text('Free deadline'),
                                  Checkbox(
                                    value: _value,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _value = newValue!;
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          ),

                        ],
                      ),
                      actions: <Widget>[
                        new TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            print('The data are:');
                            print(_dateController.text);
                            print(_timeController.text);
                          },
                          child: const Text('Finish'),
                        ),
                      ],
                    );
                  },
                );
                print('Deadline Button pressed');
              },
              child: Text('Deadline Button'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarPopup extends StatefulWidget {
  final StateSetter setState;

  CalendarPopup({required this.setState});

  @override
  _CalendarPopupState createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
        },
      ),
    );
  }
}


class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;
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

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newText.length > 0) {
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












/*
class createTaskPage extends StatefulWidget {
  @override
  _createTaskPageState createState() => _createTaskPageState();
}

class _createTaskPageState extends State<createTaskPage> {
  bool _showCalendar = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      content: TableCalendar(
        firstDay: DateTime.utc(2020, 01, 01),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
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
                  MaterialPageRoute(builder: (context) => _buildPopupDialog(context)),
                );
                print('deadline Button pressed');
              },
              child: Text('Deadline'),
            ),
          ],
        ),
      ),
    );
  }
}*/