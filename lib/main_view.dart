import 'package:flutter/material.dart';
import 'due_date_priority_view.dart';
import 'priority_view.dart';
import 'calendar_view.dart';

class MainViewPage extends StatefulWidget {
  const MainViewPage({super.key});

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
        children: const [
          CalendarViewPage(),
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
