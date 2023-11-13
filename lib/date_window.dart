import 'package:flutter/material.dart';
import 'calendar_screen.dart';

class DateWindow extends StatelessWidget {
  const DateWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30,
        itemBuilder: (context, index) {
          final currentDate = DateTime.now().add(Duration(days: index));
          final formattedDate = "${currentDate.day}/${currentDate.month}";
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(currentDate),
                ),
              );
            },
            child: Container(
              width: 80.0,
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
