import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

/*content: StatefulBuilder(
builder: (BuildContext context, StateSetter setState) {
return CalendarPopup(setState: setState);
},
),*/

class CreateNewTask extends StatelessWidget {
  const CreateNewTask({super.key});


  @override
  Widget build(BuildContext context) {
    TextEditingController dateController = TextEditingController();
    TextEditingController timeController = TextEditingController();
    late TimeInputFormatter timeInputFormatter;
    timeInputFormatter = TimeInputFormatter();
    bool value = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
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
                    return AlertDialog(
                      title: const Text('Deadline'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: dateController,
                            decoration: const InputDecoration(
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
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Select date'),
                                    content: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return CalendarPopup(setState: setState);
                                      },
                                    ),
                                    actions: <Widget>[
                                      TextButton(
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
                            controller: timeController,
                            decoration: const InputDecoration(
                              labelText: 'Enter time (HH:MM)',
                            ),
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              timeInputFormatter,
                            ],
                          ),
                          StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Row(
                                children: [
                                  const Text('Free deadline'),
                                  Checkbox(
                                    value: value,
                                    onChanged: (newValue) {
                                      setState(() {
                                        value = newValue!;
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
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            print('The data are:');
                            print(dateController.text);
                            print(timeController.text);
                          },
                          child: const Text('Finish'),
                        ),
                      ],
                    );
                  },
                );
                print('Deadline Button pressed');
              },
              child: const Text('Deadline Button'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarPopup extends StatefulWidget {
  final StateSetter setState;

  const CalendarPopup({super.key, required this.setState});

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
