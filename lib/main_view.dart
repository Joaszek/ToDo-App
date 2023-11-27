import 'package:flutter/material.dart';
import 'due_date_priority_view.dart';
import 'priority_view.dart';
import 'calendar_view.dart';
import 'models.dart';

class MainViewPage extends StatefulWidget {
  final Project project;

  const  MainViewPage({Key? key, required this.project}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainViewPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          CalendarViewPage(project: widget.project), // widget. is to get the member from MainViewPage class
          PriorityViewPage(),
          DueDatePriorityViewPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );


          print(widget.project.name);
          widget.project.tasks.forEach((task) {
            print(task.name);
            print('Task Deadline Date: ${task.deadline?.date}');
            print('Task Deadline Time: ${task.deadline?.time}');
            task.errands.forEach((errand) {
              print(errand.name);
            });
          });


        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Priority',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm_rounded),
            label: 'Due Date',
          )
        ],
      ),
    );
  }
}
