import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartapp/login_or_register_page.dart';
import 'package:dartapp/match_item.dart';
import 'package:dartapp/player_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({
    super.key,
    required this.tournamentId,
  });

  final String tournamentId;

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  int currentRound = 1;
  User? user = FirebaseAuth.instance.currentUser;
  List<String> playersIdList = [];
  Set<String> roundWinners = {};
  List<String> firstRoundWinners = [];
  List<String> secondRoundWinners = [];
  List<String> thirdRoundWinners = [];
  List<String> fourthRoundWinners = [];
  Set<String> playersSet = {};
  List<String> playersList = [];
  Set<String> matchSet = {};
  List<String> matchList = [];
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
  String uid = '';
  late bool isSeed;
  late int tournamentsNumber = 0;
  bool isFirstRoundEnd = false;
  bool isSecondRoundEnd = false;
  bool isThirdRoundEnd = false;
  bool isFourthRoundEnd = false;
  bool pom1 = true;
  bool pom2 = true;
  bool pom3 = true;
  bool pom4 = true;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Get.to(
      const LoginOrRegisterPage(),
      transition: Transition.fadeIn,
      // Unikalny tag dla Hero
      arguments: "login_or_register_page_tag",
    );
  }

  Future<void> getTournament() async {
    try {
      CollectionReference tournamentsCollection =
          FirebaseFirestore.instance.collection('tournaments');

      DocumentReference tournamentRef =
          await tournamentsCollection.doc(widget.tournamentId);

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
          uid = tournamentData['creatorId'];
          isSeed = tournamentData['isSeed'];
        }
      }

      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      for (var i = 0; i < playersIdList.length; i++) {
        DocumentReference usersRef =
            await usersCollection.doc(playersIdList[i]);

        DocumentSnapshot users = await usersRef.get();

        if (users.exists) {
          Map<String, dynamic>? usersData =
              users.data() as Map<String, dynamic>?;

          if (usersData != null) {
            playersSet.add(usersData['username']);
            tournamentsNumber = usersData['tournaments'];
          }
        }
      }
      playersList = playersSet.toList();
      if (playersIdList.length == playersNumber) {
        await setSeedToTrue();
      }
      if (isSeed) {
        await drawTournament();
      }
    } catch (e) {
      print('Wystąpił błąd podczas pobierania danych z Firebase: $e');
    }
    await getMatchList();
  }

  Future<void> updateUser() async {
    try {
      DocumentReference users =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);

      await users.update({
        'tournaments': tournamentsNumber + 1,
      });
    } catch (e) {
      print('Wystąpił błąd podczas dodawania do Firebase: $e');
    }
  }

  Future<void> setSeedToTrue() async {
    try {
      CollectionReference collection =
          FirebaseFirestore.instance.collection('tournaments');

      DocumentReference tournamentRef = collection.doc(widget.tournamentId);

      await tournamentRef.update({
        'isSeed': true,
      });
    } catch (e) {
      print('Wystąpił błąd podczas dodawania do Firebase: $e');
    }
  }

  Future<void> getMatchList() async {
    bool endOfFirstRound = true;
    bool endOfSecondRound = true;
    bool endOfThirdRound = true;
    bool endOfFourthRound = true;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('tournamentId', isEqualTo: widget.tournamentId)
          .get();

      querySnapshot.docs.forEach((doc) {
        matchSet.add(doc.id);
        if (doc['round'] == 1 && doc['isFinished']) {
          endOfFirstRound = false;
        } else if (doc['round'] == 2 && doc['isFinished']) {
          endOfSecondRound = false;
        } else if (doc['round'] == 3 && doc['isFinished']) {
          endOfThirdRound = false;
        } else if (doc['round'] == 4 && doc['isFinished']) {
          endOfFirstRound = false;
        }
      });
      matchList = matchSet.toList();

      if (currentRound == 1) {
        isFirstRoundEnd = endOfFirstRound;
      } else if (currentRound == 2) {
        isSecondRoundEnd = endOfSecondRound;
      } else if (currentRound == 3) {
        isThirdRoundEnd = endOfThirdRound;
      } else if (currentRound == 4) {
        isFourthRoundEnd = endOfFourthRound;
      }
    } catch (e) {
      print('Błąd: $e');
    }
  }

  Future<void> drawTournament() async {
    if (playersNumber == 2) {
      if (currentRound == 1 && playersIdList.length == 2) {
        await createMatch(
          playersIdList[0],
          playersIdList[1],
          1,
        );
      }
    } else if (playersNumber == 4) {
      if (currentRound == 1 && playersIdList.length == 4) {
        await createMatch(
          playersIdList[0],
          playersIdList[1],
          1,
        );
        await createMatch(
          playersIdList[2],
          playersIdList[3],
          1,
        );
      }
      if (!isFirstRoundEnd && pom1) {
        await getWinnerList(1);
        if (currentRound == 2 && firstRoundWinners.length == 2) {
          print('tworze 3 mecz');
          await createMatch(
            firstRoundWinners[0],
            firstRoundWinners[1],
            2,
          );
          pom1 = false;
          print('stworzylem 3 mecz');
        }
      }
    } else if (playersNumber == 8) {
      if (currentRound == 1 && playersIdList.length == 8) {
        await createMatch(
          playersIdList[0],
          playersIdList[1],
          1,
        );
        await createMatch(
          playersIdList[2],
          playersIdList[3],
          1,
        );
        await createMatch(
          playersIdList[4],
          playersIdList[5],
          1,
        );
        await createMatch(
          playersIdList[6],
          playersIdList[7],
          1,
        );
        pom1 = false;
      }
      if (!isFirstRoundEnd && pom1) {
        await getWinnerList(1);
        if (currentRound == 2 && firstRoundWinners.length == 4) {
          await createMatch(
            firstRoundWinners[0],
            firstRoundWinners[1],
            2,
          );
          await createMatch(
            firstRoundWinners[2],
            firstRoundWinners[3],
            2,
          );
          pom2 = false;
        }
      }
      if (!isSecondRoundEnd && pom2) {
        await getWinnerList(2);
        if (currentRound == 3 && secondRoundWinners.length == 2) {
          await createMatch(
            secondRoundWinners[0],
            secondRoundWinners[1],
            3,
          );
        }
      }
    } else if (playersNumber == 16) {
      if (currentRound == 1 && playersIdList.length == 16) {
        await createMatch(
          playersIdList[0],
          playersIdList[1],
          1,
        );
        await createMatch(
          playersIdList[2],
          playersIdList[3],
          1,
        );
        await createMatch(
          playersIdList[4],
          playersIdList[5],
          1,
        );
        await createMatch(
          playersIdList[6],
          playersIdList[7],
          1,
        );
        await createMatch(
          playersIdList[8],
          playersIdList[9],
          1,
        );
        await createMatch(
          playersIdList[10],
          playersIdList[11],
          1,
        );
        await createMatch(
          playersIdList[12],
          playersIdList[13],
          1,
        );
        await createMatch(
          playersIdList[14],
          playersIdList[15],
          1,
        );
        pom1 = false;
      }
      if (!isFirstRoundEnd && pom1) {
        await getWinnerList(1);
        if (currentRound == 2 && firstRoundWinners.length == 8) {
          await createMatch(
            firstRoundWinners[0],
            firstRoundWinners[1],
            2,
          );
          await createMatch(
            firstRoundWinners[2],
            firstRoundWinners[3],
            2,
          );
          await createMatch(
            firstRoundWinners[4],
            firstRoundWinners[5],
            2,
          );
          await createMatch(
            firstRoundWinners[6],
            firstRoundWinners[7],
            2,
          );
          pom2 = false;
        }
      }
      if (!isSecondRoundEnd && pom2) {
        await getWinnerList(2);
        if (currentRound == 3 && secondRoundWinners.length == 4) {
          await createMatch(
            secondRoundWinners[0],
            secondRoundWinners[1],
            3,
          );
          await createMatch(
            secondRoundWinners[2],
            secondRoundWinners[3],
            3,
          );
          pom3 = false;
        }
      }
      if (!isThirdRoundEnd && pom3) {
        await getWinnerList(3);
        if (currentRound == 4 && thirdRoundWinners.length == 2) {
          await createMatch(
            thirdRoundWinners[0],
            thirdRoundWinners[1],
            4,
          );
        }
      }
    } else if (playersNumber == 32) {
      if (currentRound == 1 && playersIdList.length == 32) {
        await createMatch(
          playersIdList[0],
          playersIdList[1],
          1,
        );
        await createMatch(
          playersIdList[2],
          playersIdList[3],
          1,
        );
        await createMatch(
          playersIdList[4],
          playersIdList[5],
          1,
        );
        await createMatch(
          playersIdList[6],
          playersIdList[7],
          1,
        );
        await createMatch(
          playersIdList[8],
          playersIdList[9],
          1,
        );
        await createMatch(
          playersIdList[10],
          playersIdList[11],
          1,
        );
        await createMatch(
          playersIdList[12],
          playersIdList[13],
          1,
        );
        await createMatch(
          playersIdList[14],
          playersIdList[15],
          1,
        );
        await createMatch(
          playersIdList[16],
          playersIdList[17],
          1,
        );
        await createMatch(
          playersIdList[18],
          playersIdList[19],
          1,
        );
        await createMatch(
          playersIdList[20],
          playersIdList[21],
          1,
        );
        await createMatch(
          playersIdList[22],
          playersIdList[23],
          1,
        );
        await createMatch(
          playersIdList[24],
          playersIdList[25],
          1,
        );
        await createMatch(
          playersIdList[26],
          playersIdList[27],
          1,
        );
        await createMatch(
          playersIdList[28],
          playersIdList[29],
          1,
        );
        await createMatch(
          playersIdList[30],
          playersIdList[31],
          1,
        );
        pom1 = false;
      }
      if (!isFirstRoundEnd && pom1) {
        await getWinnerList(1);
        if (currentRound == 2 && firstRoundWinners.length == 16) {
          await createMatch(
            firstRoundWinners[0],
            firstRoundWinners[1],
            2,
          );
          await createMatch(
            firstRoundWinners[2],
            firstRoundWinners[3],
            2,
          );
          await createMatch(
            firstRoundWinners[4],
            firstRoundWinners[5],
            2,
          );
          await createMatch(
            firstRoundWinners[6],
            firstRoundWinners[7],
            2,
          );
          await createMatch(
            firstRoundWinners[8],
            firstRoundWinners[9],
            2,
          );
          await createMatch(
            firstRoundWinners[10],
            firstRoundWinners[11],
            2,
          );
          await createMatch(
            firstRoundWinners[12],
            firstRoundWinners[13],
            2,
          );
          await createMatch(
            firstRoundWinners[14],
            firstRoundWinners[15],
            2,
          );
          pom2 = false;
        }
      }
      if (!isSecondRoundEnd && pom2) {
        await getWinnerList(2);
        if (currentRound == 3 && secondRoundWinners.length == 8) {
          await createMatch(
            secondRoundWinners[0],
            secondRoundWinners[1],
            3,
          );
          await createMatch(
            secondRoundWinners[2],
            secondRoundWinners[3],
            3,
          );
          await createMatch(
            secondRoundWinners[4],
            secondRoundWinners[5],
            3,
          );
          await createMatch(
            secondRoundWinners[6],
            secondRoundWinners[7],
            3,
          );
          pom3 = false;
        }
      }
      if (!isThirdRoundEnd && pom3) {
        await getWinnerList(3);
        if (currentRound == 4 && thirdRoundWinners.length == 4) {
          await createMatch(
            thirdRoundWinners[0],
            thirdRoundWinners[1],
            4,
          );
          await createMatch(
            thirdRoundWinners[2],
            thirdRoundWinners[3],
            4,
          );
        }
        pom4 = false;
      }
      if (!isFourthRoundEnd && pom4) {
        await getWinnerList(4);
        if (currentRound == 5 && fourthRoundWinners.length == 2) {
          await createMatch(
            fourthRoundWinners[0],
            fourthRoundWinners[1],
            5,
          );
        }
      }
    } else {
      print('Nie pasująca liczba graczy');
    }
  }

  Future<void> getWinnerList(int round) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('tournamentId', isEqualTo: widget.tournamentId)
          .where('round', isEqualTo: round)
          .get();

      querySnapshot.docs.forEach((doc) {
        if (doc['winner'] != '') {
          roundWinners.add(doc['winner']);
        }
      });
      if (round == 1) {
        firstRoundWinners = roundWinners.toList();
      } else if (round == 2) {
        secondRoundWinners = roundWinners.toList();
      } else if (round == 3) {
        thirdRoundWinners = roundWinners.toList();
      } else if (round == 4) {
        fourthRoundWinners = roundWinners.toList();
      }
      setState(() {
        currentRound++;
      });
    } catch (e) {
      print('Błąd: $e');
    }
  }

  Future<bool> checkIfMatchExist(
      String firstPlayer, String secondPlayer) async {
    bool isExist = false;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('tournamentId', isEqualTo: widget.tournamentId)
          .get();

      querySnapshot.docs.forEach((doc) {
        if (doc['firstPlayer'] == firstPlayer &&
            doc['secondPlayer'] == secondPlayer) {
          isExist = true;
        }
      });
    } catch (e) {
      print('Błąd: $e');
    }
    return isExist;
  }

  Future<String> createMatch(
      String firstPlayer, String secondPlayer, int round) async {
    String match = '';
    if (await checkIfMatchExist(firstPlayer, secondPlayer)) {
      return '';
    }

    int firstPlayerMatchNumber;
    int secondPlayerMatchNumber;
    try {
      CollectionReference collection =
          FirebaseFirestore.instance.collection('matches');

      await collection.add({
        'firstPlayer': firstPlayer,
        'secondPlayer': secondPlayer,
        'pointsToScore': score,
        'maxLegs': legsNumber,
        'maxSets': setsNumber,
        'format': endingType,
        'isSetFormat': (setsNumber == 1) ? false : true,
        'tournamentId': widget.tournamentId,
        'setCounter': 0,
        'legCounter': 0,
        'firstPlayerScore': 0,
        'secondPlayerScore': 0,
        'helpDartCounter': 0,
        'firstPlayerSets': 0,
        'secondPlayerSets': 0,
        'firstPlayerLegs': 0,
        'secondPlayerLegs': 0,
        'firstPlayerDarts': List<int>.filled(3, 0, growable: false),
        'secondPlayerDarts': List<int>.filled(3, 0, growable: false),
        'isFirstPlayer': true,
        'doubleNextValue': false,
        'tripleNextValue': false,
        'isFinished': false,
        'winner': '',
        'round': round,
      });
      match = collection.id;

      DocumentReference firstUserRef =
          FirebaseFirestore.instance.collection('users').doc(firstPlayer);

      DocumentSnapshot firstUser = await firstUserRef.get();

      if (firstUser.exists) {
        Map<String, dynamic>? firstUserData =
            firstUser.data() as Map<String, dynamic>?;

        if (firstUserData != null) {
          firstPlayerMatchNumber = firstUserData['tournaments'];
          await firstUserRef.update({
            'match': firstPlayerMatchNumber + 1,
          });
        }
      }

      DocumentReference secondUserRef =
          FirebaseFirestore.instance.collection('users').doc(secondPlayer);

      DocumentSnapshot secondUser = await secondUserRef.get();

      if (secondUser.exists) {
        Map<String, dynamic>? secondUserData =
            secondUser.data() as Map<String, dynamic>?;

        if (secondUserData != null) {
          secondPlayerMatchNumber = secondUserData['tournaments'];
          await secondUserRef.update({
            'match': secondPlayerMatchNumber + 1,
          });
        }
      }
    } catch (e) {
      print('Wystąpił błąd podczas dodawania do Firebase: $e');
    }
    return match;
  }

  void joinTournament() async {
    if (user != null) {
      String uid = user!.uid;

      CollectionReference collection =
          FirebaseFirestore.instance.collection('tournaments');
      DocumentReference tournamentRef = collection.doc(widget.tournamentId);

      try {
        await tournamentRef.update({
          'playersList': FieldValue.arrayUnion([uid])
        });
        await updateUser();
      } catch (e) {
        print('Wystąpił błąd podczas dodawania użytkownika do listy: $e');
      }
    } else {
      print('Użytkownik nie jest zalogowany.');
    }
  }

  void _showPasswordDialog(BuildContext context) async {
    String wprowadzoneHaslo = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Podaj hasło'),
          content: Column(
            children: <Widget>[
              TextField(
                obscureText: true,
                onChanged: (value) {
                  wprowadzoneHaslo = value;
                },
                decoration: const InputDecoration(labelText: 'Hasło'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie dialogu
              },
              child: Text('Anuluj'),
            ),
            TextButton(
              onPressed: () {
                if (wprowadzoneHaslo == password) {
                  joinTournament();
                  Navigator.of(context).pop();
                  _showSuccessDialog(context);
                } else {
                  _showErrorDialog(
                      context, "Niepoprawne hasło. Spróbuj ponownie.");
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    await getTournament();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sukces'),
          content: Text('Hasło poprawne!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie dialogu
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Błąd'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknięcie dialogu
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> refresh() async {
    await getTournament();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: getTournament(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 123, 193, 255),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Wystąpił błąd: ${snapshot.error}');
        } else {
          print(isSeed);
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: signUserOut,
                  icon: const Icon(Icons.logout),
                ),
              ],
              backgroundColor: const Color.fromARGB(255, 123, 193, 255),
              title: const Text(
                'Dart App',
              ),
            ),
            body: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: RefreshIndicator(
                onRefresh: refresh,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: 270,
                            child: Center(
                              child: Text(
                                name,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: 50,
                            child: Icon(
                              icon == 1
                                  ? Icons.emoji_events
                                  : icon == 2
                                      ? Icons.star
                                      : Icons.favorite,
                              color: iconColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Text(
                            'Id:',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            widget.tournamentId,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Text(
                            'Hasło:',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            isPrivate ? 'wymagane' : 'nie wymagane',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Text(
                            'Typ:',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Text(
                            'Sposób zakończenia:',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            endingType,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Text(
                            'Liczba legów potrzebna do wygrania seta:',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            legsNumber.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Text(
                            'Liczba setów potrzebna do wygrania meczu:',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            setsNumber.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Text(
                            'Liczba punktów potrzebna do wygrania lega:',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            score.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Text(
                            'Gracze:',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            '${playersIdList.length}/${playersNumber.toString()}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    !isSeed
                        ? ListView.builder(
                            itemCount: playersSet.length,
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) {
                              return PlayerItem(
                                playerName: playersList[index],
                              );
                            })
                        : ListView.builder(
                            itemCount: matchList.length,
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) {
                              return MatchItem(
                                matchId: matchList[index],
                              );
                            }),
                    const SizedBox(
                      height: 200,
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: (playersSet.length < playersNumber &&
                    !playersIdList.contains(user!.uid))
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 30,
                        ),
                        child: SizedBox(
                          width: 150,
                          child: FloatingActionButton(
                            heroTag: 'button6',
                            backgroundColor:
                                const Color.fromARGB(255, 123, 193, 255),
                            onPressed: () {
                              if (isPrivate) {
                                _showPasswordDialog(context);
                              } else {
                                joinTournament();
                              }
                            },
                            child: const Text(
                              'Dołącz',
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          );
        }
      },
    );
  }
}
