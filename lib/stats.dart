import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  User? user = FirebaseAuth.instance.currentUser;
  late int dartsThrown = 0;
  late int score = 0;
  late int matches = 0;
  late int tournaments = 0;
  late int matchesWon = 0;
  double average = 0.0;
  double winPercentage = 0.0;
  late Timer _timer;
  late RefreshController _refreshController;
  bool isLoading = true;

  _StatsState() {
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void initState() {
    super.initState();
    _loadData();

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await getUsers();
    } catch (error) {
      print('Wystąpił błąd: $error');
    } finally {
      _refreshController.refreshCompleted();
    }
  }

  Future<void> getUsers() async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      DocumentReference userRef = await usersCollection.doc(user!.uid);

      DocumentSnapshot player = await userRef.get();

      if (player.exists) {
        Map<String, dynamic>? userData = player.data() as Map<String, dynamic>?;

        if (userData != null) {
          tournaments = userData['tournaments'];
          dartsThrown = userData['dartsThrown'];
          matchesWon = userData['matchesWon'];
          matches = userData['matches'];
          score = userData['score'];
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Wystąpił błąd podczas pobierania danych z Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    average = (score / dartsThrown).toDouble() * 3.0;
    winPercentage = (matchesWon / matches).toDouble() * 100.0;
    average = double.parse(average.toStringAsFixed(2));
    winPercentage = double.parse(winPercentage.toStringAsFixed(2));

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: () async {
        await _loadData();
      },
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        average.toString(),
                        style: const TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        'Średnia rzutu (na 3 lotki)',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tournaments.toString(),
                        style: const TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        'Liczba zagranych turniejów',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        matches.toString(),
                        style: const TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        'Liczba zagranych meczów',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${winPercentage.toString()} %',
                        style: const TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        'Procent wygranych meczy',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
