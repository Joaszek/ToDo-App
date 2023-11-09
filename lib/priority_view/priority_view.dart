import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('HomePage')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PriorityView()));
                    },
                    icon: Icon(Icons.search),
                    tooltip: 'Explore',
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PriorityView()));
                  },
                  icon: Icon(Icons.search),
                  tooltip: 'Explore',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PriorityView()));
                  },
                  icon: Icon(Icons.search),
                  tooltip: 'Explore',
                ),
              )
            ],
          ),
        ));
  }
}

class PriorityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Priority Task List')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 8.0), // Dodaj padding, jeśli potrzebujesz
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Rozstawia dzieci równomiernie w poziomie
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back), // Ikona strzałki w lewo
                  onPressed: () {
                    // Akcja dla przycisku strzałki w lewo
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward), // Ikona strzałki w prawo
                  onPressed: () {
                    // Akcja dla przycisku strzałki w prawo
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: prioritySection(
                'High Priority', 5), // Liczba przycisków dla tej sekcji
          ),
          Expanded(
            child: prioritySection(
                'Medium Priority', 5), // Liczba przycisków dla tej sekcji
          ),
          Expanded(
            child: prioritySection(
                'Low Priority', 8), // Liczba przycisków dla tej sekcji
          ),
        ],
      ),
    );
  }

  Widget prioritySection(String title, int count) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24,
              )),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: count,
            itemBuilder: (context, index) {
              return ListTile(
                title: ElevatedButton(
                  onPressed: () {/* Do something */},
                  child: Text('Task ${index + 1} $title'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
