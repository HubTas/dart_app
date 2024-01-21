import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartapp/tournament_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TournamentItem extends StatefulWidget {
  const TournamentItem({
    super.key,
    required this.tournamentId,
  });

  final String tournamentId;

  @override
  State<TournamentItem> createState() => _TournamentItemState();
}

class _TournamentItemState extends State<TournamentItem> {
  late String name;
  late String password;
  late String type;
  late int playersNumber;
  late String endingType;
  late int legsNumber;
  late int setsNumber;
  late int score;
  late bool isPrivate;
  late int icon;
  late Color iconColor;
  List<String> playersIdList = [];

  Future<void> getTournament(String id) async {
    try {
      CollectionReference collection =
          FirebaseFirestore.instance.collection('tournaments');

      DocumentReference tournamentRef = await collection.doc(id);

      DocumentSnapshot tournament = await tournamentRef.get();

      if (tournament.exists) {
        Map<String, dynamic>? tournamentData =
            tournament.data() as Map<String, dynamic>?;

        if (tournamentData != null) {
          name = tournamentData['name'];
          password = tournamentData['password'];
          type = tournamentData['type'];
          playersNumber = int.parse(tournamentData['playersNumber']);
          endingType = tournamentData['endingType'];
          legsNumber = int.parse(tournamentData['legsNumber']);
          setsNumber = int.parse(tournamentData['setsNumber']);
          score = int.parse(tournamentData['scoreNumber']);
          isPrivate = tournamentData['isPrivate'];
          icon = tournamentData['icon'];
          iconColor = Color(int.parse(tournamentData['iconColor']));
          playersIdList = tournamentData['playersList'].cast<String>();
        }
      }
    } catch (e) {
      print('Wystąpił błąd podczas pobierania danych z Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: getTournament(widget.tournamentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Wystąpił błąd: ${snapshot.error}');
          } else {
            return Card(
              color: (playersIdList.length < playersNumber)
                  ? const Color.fromARGB(137, 0, 255, 0)
                  : const Color.fromARGB(137, 255, 0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () {
                  Get.to(
                    TournamentScreen(
                      tournamentId: widget.tournamentId,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: 130,
                            child: Column(
                              children: [
                                Text(
                                  name,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                                Text(
                                  widget.tournamentId,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: 140,
                            child: Column(
                              children: [
                                Text(
                                  type,
                                  softWrap: true,
                                ),
                                Text(
                                  '${playersIdList.length}/${playersNumber.toString()}',
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            icon == 1
                                ? Icons.emoji_events
                                : icon == 2
                                    ? Icons.star
                                    : Icons.favorite,
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isPrivate
                              ? 'Hasło jest wymagane'
                              : 'Hasło nie jest wymagane'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }
}
