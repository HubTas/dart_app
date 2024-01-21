import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartapp/match_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatchItem extends StatefulWidget {
  const MatchItem({
    super.key,
    required this.matchId,
  });

  final String matchId;

  @override
  State<MatchItem> createState() => _MatchItemState();
}

class _MatchItemState extends State<MatchItem> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;
  late String firstPlayerId;
  late String secondPlayerId;
  late String firstPlayer = '';
  late String secondPlayer = '';
  late int pointsToScore;
  late int maxLegs;
  late int maxSets;
  late String format;
  late bool isSetFormat;
  late String tournamentId;
  late String winner;
  late bool isFinshed;
  late int firstPlayerLegs;
  late int secondPlayerLegs;
  late int firstPlayerSets;
  late int secondPlayerSets;
  late int round;

  Future<void> getMatch() async {
    try {
      CollectionReference matchesCollection =
          FirebaseFirestore.instance.collection('matches');

      DocumentReference matchRef = await matchesCollection.doc(widget.matchId);

      DocumentSnapshot match = await matchRef.get();

      if (match.exists) {
        Map<String, dynamic>? matchData = match.data() as Map<String, dynamic>?;

        if (matchData != null) {
          firstPlayerId = matchData['firstPlayer'];
          secondPlayerId = matchData['secondPlayer'];
          pointsToScore = matchData['pointsToScore'];
          maxLegs = matchData['maxLegs'];
          maxSets = matchData['maxSets'];
          format = matchData['format'];
          isSetFormat = matchData['isSetFormat'];
          tournamentId = matchData['tournamentId'];
          winner = matchData['winner'];
          isFinshed = matchData['isFinished'];
          firstPlayerLegs = matchData['firstPlayerLegs'];
          secondPlayerLegs = matchData['secondPlayerLegs'];
          firstPlayerSets = matchData['firstPlayerSets'];
          secondPlayerSets = matchData['secondPlayerSets'];
          round = matchData['round'];
        }
      }
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      DocumentSnapshot player1 = await usersCollection.doc(firstPlayerId).get();
      DocumentSnapshot player2 =
          await usersCollection.doc(secondPlayerId).get();

      if (player1.exists) {
        Map<String, dynamic>? player1Data =
            player1.data() as Map<String, dynamic>?;

        if (player1Data != null) {
          firstPlayer = player1Data['username'];
        }
      }
      if (player2.exists) {
        Map<String, dynamic>? player2Data =
            player2.data() as Map<String, dynamic>?;

        if (player2Data != null) {
          secondPlayer = player2Data['username'];
        }
      }
    } catch (e) {
      print('Wystąpił błąd podczas pobierania danych z Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      uid = user!.uid;
    }
    return FutureBuilder<void>(
        future: getMatch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Wystąpił błąd: ${snapshot.error}');
          } else {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                color: isFinshed
                    ? const Color.fromARGB(125, 123, 193, 255)
                    : const Color.fromARGB(255, 123, 193, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    if ((uid == firstPlayerId || uid == secondPlayerId) &&
                        !isFinshed) {
                      Get.to(
                        MatchScreen(
                          matchId: widget.matchId,
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: 70,
                                  child: Center(
                                    child: Text(
                                      firstPlayer,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                isSetFormat
                                    ? SizedBox(
                                        width: 30,
                                        child: Text(
                                            '${firstPlayerSets.toString()}:${secondPlayerSets.toString()}'),
                                      )
                                    : SizedBox(
                                        width: 30,
                                        child: Text(
                                            '${firstPlayerLegs.toString()}:${secondPlayerLegs.toString()}'),
                                      ),
                                const SizedBox(
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 70,
                                  child: Center(
                                    child: Text(
                                      secondPlayer,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Runda: ${round.toString()}'),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Text(format),
                            Text(pointsToScore.toString()),
                            Row(
                              children: [
                                Text('Legi: ${maxLegs.toString()}'),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text('Sety: ${maxSets.toString()}'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
