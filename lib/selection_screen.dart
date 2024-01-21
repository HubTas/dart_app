import 'package:dartapp/login_or_register_page.dart';
import 'package:dartapp/stats.dart';
import 'package:dartapp/tournament_creation.dart';
import 'package:dartapp/tournaments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  int _current_index = 0;
  PageController _pageController = PageController();
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _current_index = index;
    });
  }

  void _onBottomNavigationBarTap(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Get.to(
      const LoginOrRegisterPage(),
      transition: Transition.fadeIn,
      // Unikalny tag dla Hero
      arguments: "login_or_register_page_tag",
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const TournamentCreation(),
      const Tournaments(),
      const Stats(),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 123, 193, 255),
        title: const Text(
          'Dart App',
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 123, 193, 255),
        currentIndex: _current_index,
        onTap: _onBottomNavigationBarTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Nowy turniej',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Turnieje',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statystyki',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
    );
  }
}
