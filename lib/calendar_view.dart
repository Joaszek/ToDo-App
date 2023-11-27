import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'models.dart';

class CalendarViewPage extends StatefulWidget {
  final Project project;

  const CalendarViewPage({Key? key, required this.project}) : super(key: key);

  @override
  _CalendarViewPageState createState() => _CalendarViewPageState();
}

class _CalendarViewPageState extends State<CalendarViewPage> {
  Map<DateTime, List<Event>> _events = {};

  void _addProjectEvents(Project project) {
    // Assuming your Project, Task, and Errand classes have deadline information
    project.tasks.forEach((task) {
      // Check if the task has a deadline
      if (task.deadline != null) {
        DateTime deadlineDate = task.deadline!.date ?? DateTime.now();
        TimeOfDay deadlineTime = task.deadline!.time ?? TimeOfDay.now();

        DateTime deadlineDateTime = DateTime(
          deadlineDate.year,
          deadlineDate.month,
          deadlineDate.day,
          deadlineTime.hour,
          deadlineTime.minute,
        );

        _events.putIfAbsent(deadlineDateTime, () => []);
        _events[deadlineDateTime]!.add(Event(task.name, priority: task.priority));
      }
    });

    setState(() {
      // Update the calendar after adding events
    });
  }

  @override
  void initState() {
    super.initState();
    _addProjectEvents(widget.project);
    """
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
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar view'),
      ),
      body: Center(
        child: SfCalendar(
          view: CalendarView.month,
          dataSource: _getCalendarDataSource(),
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.calendarCell) {
              DateTime selectedDate = details.date!;
              print(selectedDate);
              // Handle day selection as needed
            }

            // sample usecase
            //print(widget.project.name);
            //widget.project.tasks.forEach((task) {
            //  print(task.name);
            //  print('Task Deadline Date: ${task.deadline?.date}');
            //  print('Task Deadline Time: ${task.deadline?.time}');
            //  task.errands.forEach((errand) {
            //    print(errand.name);
            //  });
            //});


          },
          monthViewSettings: const MonthViewSettings(
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
          endTime: date.add(const Duration(hours: 1)),
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


