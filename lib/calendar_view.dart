import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'models.dart';

class CalendarViewPage extends StatefulWidget {
  @override
  _CalendarViewPageState createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _events = {
      DateTime(2023, 11, 25): [
        Event('Task 1', priority: Priority.high),
        Event('Task 2', priority: Priority.medium),
      ],
      DateTime(2023, 11, 30): [
        Event('Task 3', priority: Priority.low),
      ],
      // Add more events as needed
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar view'),
      ),
      body: Center(
        child: SfCalendar(
          view: CalendarView.month,
          dataSource: _getCalendarDataSource(),
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.calendarCell) {
              DateTime selectedDate = details.date!;
              List<Event> events = _events[selectedDate] ?? [];
              print('Selected date: $selectedDate');
              print('Events: $events');
              // Handle day selection as needed
            }
          },
          monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          ),
        ),
      ),
    );
  }

  _DataSource _getCalendarDataSource() {
    List<Appointment> appointments = [];

    _events.forEach((date, events) {
      events.forEach((event) {
        appointments.add(Appointment(
          startTime: date,
          endTime: date.add(Duration(hours: 1)),
          subject: event.title,
          color: event.color,
        ));
      });
    });

    return _DataSource(appointments);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}


