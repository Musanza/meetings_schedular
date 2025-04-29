import 'package:flutter/material.dart';
import 'package:meetings_scheduler/congregation/congregation_screen.dart';
import 'package:meetings_scheduler/home/home_screen.dart';
import 'package:meetings_scheduler/publishers/publishers_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0; // Track the current tab index

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    const HomeScreen(),
    const PublishersScreen(),
    const CongregationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlight the active tab
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current tab index
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Publishers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.church),
            label: 'Congregation',
          ),
        ],
      ),
    );
  }
}
