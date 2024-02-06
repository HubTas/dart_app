import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartapp/login_or_register_page.dart';
import 'package:dartapp/selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({
    super.key,
    required this.matchId,
  });

  final String matchId;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;
  late bool isUserFirstPlayer = false;
  bool isAllowedToThrow = false;
  bool isLoading = true;
  late RefreshController _refreshController;
  late int pointsToScore;
  late int maxLegs;
  late int maxSets;
  late bool isSetFormat;
  late String format; // double-out, single-out, triple-out
  late String firstPlayerId = '';
  late String secondPlayerId = '';
  late String firstPlayer;
  late String secondPlayer;
  late String tournamentId;
  late int setCounter;
  late int legCounter;
  late int firstPlayerScore;
  late int secondPlayerScore;
  late int helpDartCounter;
  late int firstPlayerSets;
  late int secondPlayerSets;
  late int firstPlayerLegs;
  late int secondPlayerLegs;
  late int round;
  late int firstPlayerScoreFromDatabase;
  late int secondPlayerScoreFromDatabase;
  late int firstPlayerDartsThrownFromDatabase;
  late int secondPlayerDartsThrownFromDatabase;
  late int firstPlayerMatchesWon;
  late int secondPlayerMatchesWon;
  late int firstPlayerMatches;
  late int secondPlayerMatches;
  int firstPlayerMatchScore = 0;
  int secondPlayerMatchScore = 0;
  int firstPlayerMatchDartsThrown = 0;
  int secondPlayerMatchDartsThrown = 0;
  List<int> firstPlayerDarts = List<int>.filled(3, 0, growable: false);
  List<int> secondPlayerDarts = List<int>.filled(3, 0, growable: false);
  bool isFirstPlayer = true;
  bool doubleNextValue = false;
  bool tripleNextValue = false;
  late Timer _timer;
  bool isFinished = false;

  _MatchScreenState() {
    // getMatch(widget.matchId);
    _refreshController = RefreshController(initialRefresh: false);
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Get.to(const LoginOrRegisterPage());
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    getUsers();

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
      await getMatch(widget.matchId);
    } catch (error) {
      print('Wystąpił błąd: $error');
    } finally {
      _refreshController.refreshCompleted();
    }
  }

  Future<void> getMatch(String id) async {
    try {
      CollectionReference matchesCollection =
          FirebaseFirestore.instance.collection('matches');

      DocumentReference matchRef = await matchesCollection.doc(id);

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
          setCounter = matchData['setCounter'];
          legCounter = matchData['legCounter'];
          firstPlayerScore = matchData['firstPlayerScore'];
          secondPlayerScore = matchData['secondPlayerScore'];
          helpDartCounter = matchData['helpDartCounter'];
          firstPlayerSets = matchData['firstPlayerSets'];
          secondPlayerSets = matchData['secondPlayerSets'];
          firstPlayerLegs = matchData['firstPlayerLegs'];
          secondPlayerLegs = matchData['secondPlayerLegs'];
          firstPlayerDarts = matchData['firstPlayerDarts'].cast<int>();
          secondPlayerDarts = matchData['secondPlayerDarts'].cast<int>();
          isFirstPlayer = matchData['isFirstPlayer'];
          doubleNextValue = matchData['doubleNextValue'];
          tripleNextValue = matchData['tripleNextValue'];
          round = matchData['round'];
          isFinished = matchData['isFinished'];
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
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Wystąpił błąd podczas pobierania danych z Firebase: $e');
    }
  }

  Future<void> updateMatch() async {
    try {
      DocumentReference match =
          FirebaseFirestore.instance.collection('matches').doc(widget.matchId);

      await match.update({
        'setCounter': setCounter,
        'legCounter': legCounter,
        'firstPlayerScore': firstPlayerScore,
        'secondPlayerScore': secondPlayerScore,
        'helpDartCounter': helpDartCounter,
        'firstPlayerSets': firstPlayerSets,
        'secondPlayerSets': secondPlayerSets,
        'firstPlayerLegs': firstPlayerLegs,
        'secondPlayerLegs': secondPlayerLegs,
        'firstPlayerDarts': firstPlayerDarts,
        'secondPlayerDarts': secondPlayerDarts,
        'isFirstPlayer': isFirstPlayer,
        'doubleNextValue': doubleNextValue,
        'tripleNextValue': tripleNextValue,
      });
    } catch (e) {
      print('Wystąpił błąd podczas dodawania do Firebase: $e');
    }
  }

  Future<void> getUsers() async {
    try {
      CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      DocumentReference firstUserRef = await usersCollection.doc(firstPlayerId);

      DocumentSnapshot firstUser = await firstUserRef.get();

      if (firstUser.exists) {
        Map<String, dynamic>? firstUserData =
            firstUser.data() as Map<String, dynamic>?;

        if (firstUserData != null) {
          firstPlayerScoreFromDatabase = firstUserData['tournaments'];
          firstPlayerDartsThrownFromDatabase = firstUserData['dartsThrown'];
          firstPlayerMatchesWon = firstUserData['matchesWon'];
          firstPlayerMatches = firstUserData['matches'];
        }
      }

      DocumentReference secondUserRef =
          await usersCollection.doc(secondPlayerId);

      DocumentSnapshot secondUser = await secondUserRef.get();

      if (secondUser.exists) {
        Map<String, dynamic>? secondUserData =
            secondUser.data() as Map<String, dynamic>?;

        if (secondUserData != null) {
          secondPlayerScoreFromDatabase = secondUserData['tournaments'];
          secondPlayerDartsThrownFromDatabase = secondUserData['dartsThrown'];
          secondPlayerMatchesWon = secondUserData['matchesWon'];
          secondPlayerMatches = secondUserData['matches'];
        }
      }
    } catch (e) {
      print('Wystąpił błąd podczas pobierania danych z Firebase: $e');
    }
  }

  Future<void> updateUser(int winnerNumber) async {
    if (winnerNumber == 1) {
      firstPlayerMatchesWon++;
    } else if (winnerNumber == 2) {
      secondPlayerMatchesWon++;
    }

    try {
      DocumentReference firstUser =
          FirebaseFirestore.instance.collection('users').doc(firstPlayerId);

      await firstUser.update({
        'score': firstPlayerMatchScore,
        'dartsThrown': firstPlayerMatchDartsThrown,
        'matchesWon': firstPlayerMatchesWon,
        'matches': firstPlayerMatches + 1,
      });

      DocumentReference secondUser =
          FirebaseFirestore.instance.collection('users').doc(secondPlayerId);

      await secondUser.update({
        'score': secondPlayerMatchScore,
        'dartsThrown': secondPlayerMatchDartsThrown,
        'matchesWon': secondPlayerMatchesWon,
        'matches': secondPlayerMatches + 1,
      });
    } catch (e) {
      print('Wystąpił błąd podczas dodawania do Firebase: $e');
    }
  }

  Future<void> addMatchWinner(int winnerNumber) async {
    try {
      DocumentReference match =
          FirebaseFirestore.instance.collection('matches').doc(widget.matchId);
      String? winner;

      if (winnerNumber == 1) {
        winner = firstPlayerId;
      } else if (winnerNumber == 2) {
        winner = secondPlayerId;
      }
      await match.update({
        'isFinished': true,
        'winner': winner,
      });
      updateUser(winnerNumber);
    } catch (e) {
      print('Wystąpił błąd podczas dodawania do Firebase: $e');
    }
  }

  void isLegEnd(int score) {
    if (score == pointsToScore) {
      switch (format) {
        case 'double-out':
          if (doubleNextValue && isFirstPlayer) {
            setState(() {
              firstPlayerMatchScore = firstPlayerMatchScore + firstPlayerScore;
              secondPlayerMatchScore =
                  secondPlayerMatchScore + secondPlayerScore;
              firstPlayerLegs++;
              legCounter++;
              helpDartCounter = 0;
              firstPlayerScore = 0;
              secondPlayerScore = 0;
              switch (legCounter % 2) {
                case 0:
                  isFirstPlayer = false;
                  break;
                case 1:
                  isFirstPlayer = true;
                  break;
                default:
                  break;
              }
              firstPlayerDarts = List<int>.filled(3, 0);
              secondPlayerDarts = List<int>.filled(3, 0);
            });
          } else if (doubleNextValue && !isFirstPlayer) {
            setState(() {
              firstPlayerMatchScore = firstPlayerMatchScore + firstPlayerScore;
              secondPlayerMatchScore =
                  secondPlayerMatchScore + secondPlayerScore;
              secondPlayerLegs++;
              legCounter++;
              helpDartCounter = 0;
              firstPlayerScore = 0;
              secondPlayerScore = 0;
              switch (legCounter % 2) {
                case 0:
                  isFirstPlayer = false;
                  break;
                case 1:
                  isFirstPlayer = true;
                  break;
                default:
                  break;
              }
              firstPlayerDarts = List<int>.filled(3, 0);
              secondPlayerDarts = List<int>.filled(3, 0);
            });
          } else {
            const Dialog(
              child: Text('Rzucono nieprawidłową wartość'),
            );
            if (isFirstPlayer) {
              print('rzucono zla wartosc - gracz 1');
              setState(() {
                firstPlayerScore = firstPlayerScore -
                    firstPlayerDarts[0] -
                    firstPlayerDarts[1] -
                    firstPlayerDarts[2];
                secondPlayerDarts = List<int>.filled(3, 0);
                helpDartCounter = 0;
              });
            } else {
              print('rzucono zla wartosc - gracz 2');
              setState(() {
                secondPlayerScore = secondPlayerScore -
                    secondPlayerDarts[0] -
                    secondPlayerDarts[1] -
                    secondPlayerDarts[2];
                firstPlayerDarts = List<int>.filled(3, 0);
                helpDartCounter = 0;
              });
            }
          }
          break;
        case 'single-out':
          if (!doubleNextValue && !tripleNextValue && isFirstPlayer) {
            setState(() {
              firstPlayerMatchScore = firstPlayerMatchScore + firstPlayerScore;
              secondPlayerMatchScore =
                  secondPlayerMatchScore + secondPlayerScore;
              firstPlayerLegs++;
              legCounter++;
              helpDartCounter = 0;
              firstPlayerScore = 0;
              secondPlayerScore = 0;
              switch (legCounter % 2) {
                case 0:
                  isFirstPlayer = false;
                  break;
                case 1:
                  isFirstPlayer = true;
                  break;
                default:
                  break;
              }
              firstPlayerDarts = List<int>.filled(3, 0);
              secondPlayerDarts = List<int>.filled(3, 0);
            });
          } else if (!doubleNextValue && !tripleNextValue && !isFirstPlayer) {
            setState(() {
              firstPlayerMatchScore = firstPlayerMatchScore + firstPlayerScore;
              secondPlayerMatchScore =
                  secondPlayerMatchScore + secondPlayerScore;
              secondPlayerLegs++;
              legCounter++;
              helpDartCounter = 0;
              firstPlayerScore = 0;
              secondPlayerScore = 0;
              switch (legCounter % 2) {
                case 0:
                  isFirstPlayer = false;
                  break;
                case 1:
                  isFirstPlayer = true;
                  break;
                default:
                  break;
              }
              firstPlayerDarts = List<int>.filled(3, 0);
              secondPlayerDarts = List<int>.filled(3, 0);
            });
          } else {
            const Dialog(
              child: Text('Rzucono nieprawidłową wartość'),
            );
            if (isFirstPlayer) {
              setState(() {
                firstPlayerScore = firstPlayerScore -
                    firstPlayerDarts[0] -
                    firstPlayerDarts[1] -
                    firstPlayerDarts[2];
                secondPlayerDarts = List<int>.filled(3, 0);
                helpDartCounter = 0;
              });
            } else {
              setState(() {
                secondPlayerScore = secondPlayerScore -
                    secondPlayerDarts[0] -
                    secondPlayerDarts[1] -
                    secondPlayerDarts[2];
                firstPlayerDarts = List<int>.filled(3, 0);
                helpDartCounter = 0;
              });
            }
          }
          break;
        case 'triple-out':
          if (tripleNextValue && isFirstPlayer) {
            setState(() {
              firstPlayerMatchScore = firstPlayerMatchScore + firstPlayerScore;
              secondPlayerMatchScore =
                  secondPlayerMatchScore + secondPlayerScore;
              firstPlayerLegs++;
              legCounter++;
              helpDartCounter = 0;
              firstPlayerScore = 0;
              secondPlayerScore = 0;
              switch (legCounter % 2) {
                case 0:
                  isFirstPlayer = false;
                  break;
                case 1:
                  isFirstPlayer = true;
                  break;
                default:
                  break;
              }
              firstPlayerDarts = List<int>.filled(3, 0);
              secondPlayerDarts = List<int>.filled(3, 0);
            });
          } else if (tripleNextValue && !isFirstPlayer) {
            setState(() {
              firstPlayerMatchScore = firstPlayerMatchScore + firstPlayerScore;
              secondPlayerMatchScore =
                  secondPlayerMatchScore + secondPlayerScore;
              secondPlayerLegs++;
              legCounter++;
              helpDartCounter = 0;
              firstPlayerScore = 0;
              secondPlayerScore = 0;
              switch (legCounter % 2) {
                case 0:
                  isFirstPlayer = false;
                  break;
                case 1:
                  isFirstPlayer = true;
                  break;
                default:
                  break;
              }
              firstPlayerDarts = List<int>.filled(3, 0);
              secondPlayerDarts = List<int>.filled(3, 0);
            });
          } else {
            const Dialog(
              child: Text('Rzucono nieprawidłową wartość'),
            );
            if (isFirstPlayer) {
              setState(() {
                firstPlayerScore = firstPlayerScore -
                    firstPlayerDarts[0] -
                    firstPlayerDarts[1] -
                    firstPlayerDarts[2];
                secondPlayerDarts = List<int>.filled(3, 0);
                helpDartCounter = 0;
              });
            } else {
              setState(() {
                secondPlayerScore = secondPlayerScore -
                    secondPlayerDarts[0] -
                    secondPlayerDarts[1] -
                    secondPlayerDarts[2];
                firstPlayerDarts = List<int>.filled(3, 0);
                helpDartCounter = 0;
              });
            }
          }
          break;
        default:
          print('Nieznany format');
          break;
      }
    } else if (score > pointsToScore) {
      const Dialog(
        child: Text('Błąd, rzucono za wysoką liczbę'),
      );
      if (isFirstPlayer) {
        setState(() {
          firstPlayerScore = firstPlayerScore -
              firstPlayerDarts[0] -
              firstPlayerDarts[1] -
              firstPlayerDarts[2];
          secondPlayerDarts = List<int>.filled(3, 0);
          helpDartCounter = 0;
        });
      } else {
        setState(() {
          secondPlayerScore = secondPlayerScore -
              secondPlayerDarts[0] -
              secondPlayerDarts[1] -
              secondPlayerDarts[2];
          firstPlayerDarts = List<int>.filled(3, 0);
          helpDartCounter = 0;
        });
      }
    } else if (format == 'double-out' && (pointsToScore - score) == 1) {
      const Dialog(
        child: Text('Błąd, rzucono za wysoką liczbę'),
      );
      if (isFirstPlayer) {
        setState(() {
          firstPlayerScore = firstPlayerScore -
              firstPlayerDarts[0] -
              firstPlayerDarts[1] -
              firstPlayerDarts[2];
          secondPlayerDarts = List<int>.filled(3, 0);
          helpDartCounter = 0;
        });
      } else {
        setState(() {
          secondPlayerScore = secondPlayerScore -
              secondPlayerDarts[0] -
              secondPlayerDarts[1] -
              secondPlayerDarts[2];
          firstPlayerDarts = List<int>.filled(3, 0);
          helpDartCounter = 0;
        });
      }
    } else if (format == 'triple-out' &&
        ((pointsToScore - score) == 1 || (pointsToScore - score) == 2)) {
      const Dialog(
        child: Text('Błąd, rzucono za wysoką liczbę'),
      );
      if (isFirstPlayer) {
        setState(() {
          firstPlayerScore = firstPlayerScore -
              firstPlayerDarts[0] -
              firstPlayerDarts[1] -
              firstPlayerDarts[2];
          secondPlayerDarts = List<int>.filled(3, 0);
          helpDartCounter = 0;
        });
      } else {
        setState(() {
          secondPlayerScore = secondPlayerScore -
              secondPlayerDarts[0] -
              secondPlayerDarts[1] -
              secondPlayerDarts[2];
          firstPlayerDarts = List<int>.filled(3, 0);
          helpDartCounter = 0;
        });
      }
    }

    if (isSetFormat) {
      if (firstPlayerLegs == maxLegs) {
        setState(() {
          firstPlayerSets++;
          firstPlayerLegs = 0;
          secondPlayerLegs = 0;
          legCounter = 0;
          setCounter++;
          switch (setCounter % 2) {
            case 0:
              isFirstPlayer = false;
              break;
            case 1:
              isFirstPlayer = true;
              break;
            default:
              break;
          }
        });
      }
      if (firstPlayerSets == maxSets) {
        addMatchWinner(1);
        const Dialog(
          child: Text('Gratulacje 1 gracz zwyciężył mecz'),
        );
        Get.to(
          const SelectionScreen(),
        );
      }

      if (secondPlayerLegs == maxLegs) {
        setState(() {
          secondPlayerSets++;
          firstPlayerLegs = 0;
          secondPlayerLegs = 0;
          legCounter = 0;
          setCounter++;
          switch (setCounter % 2) {
            case 0:
              isFirstPlayer = false;
              break;
            case 1:
              isFirstPlayer = true;
              break;
            default:
              break;
          }
        });
      }
      if (secondPlayerSets == maxSets) {
        addMatchWinner(2);
        const Dialog(
          child: Text('Gratulacje 2 gracz zwyciężył mecz'),
        );
        Get.to(
          const SelectionScreen(),
        );
      }
    } else {
      if (firstPlayerLegs == maxLegs) {
        addMatchWinner(1);
        const Dialog(
          child: Text('Gratulacje 1 gracz zwyciężył mecz'),
        );
        Get.to(
          const SelectionScreen(),
        );
      }

      if (secondPlayerLegs == maxLegs) {
        addMatchWinner(2);
        const Dialog(
          child: Text('Gratulacje 2 gracz zwyciężył mecz'),
        );
        Get.to(
          const SelectionScreen(),
        );
      }
    }
  }

  void addValueToScore(int value) {
    if (isFirstPlayer) {
      firstPlayerMatchDartsThrown++;
    } else {
      secondPlayerMatchDartsThrown++;
    }

    setState(() {
      if (doubleNextValue) {
        value = value * 2;
      }
      if (tripleNextValue) {
        value = value * 3;
      }
      if (isFirstPlayer) {
        firstPlayerScore += value;
      } else {
        secondPlayerScore += value;
      }
      switch (helpDartCounter % 3) {
        case 0:
          if (isFirstPlayer) {
            firstPlayerDarts[0] = value;
          } else {
            secondPlayerDarts[0] = value;
          }
          break;
        case 1:
          if (isFirstPlayer) {
            firstPlayerDarts[1] = value;
          } else {
            secondPlayerDarts[1] = value;
          }
          break;
        case 2:
          if (isFirstPlayer) {
            firstPlayerDarts[2] = value;
          } else {
            secondPlayerDarts[2] = value;
          }
          break;

        default:
          print('Błędna kalkulacja ilości rzutów');
          break;
      }
      helpDartCounter++;
      if (isFirstPlayer) {
        isLegEnd(firstPlayerScore);
      } else {
        isLegEnd(secondPlayerScore);
      }
      doubleNextValue = false;
      tripleNextValue = false;
      if (helpDartCounter % 3 == 0) {
        isFirstPlayer = !isFirstPlayer;
        if (isFirstPlayer) {
          firstPlayerDarts = List<int>.filled(3, 0);
        } else {
          secondPlayerDarts = List<int>.filled(3, 0);
        }
      }
    });
    updateMatch();
  }

  void doubleValue() {
    setState(() {
      doubleNextValue = !doubleNextValue;
    });
    updateMatch();
  }

  void tripleValue() {
    setState(() {
      tripleNextValue = !tripleNextValue;
    });
    updateMatch();
  }

  final buttonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(
      const Color.fromARGB(255, 123, 193, 255),
    ),
    minimumSize: MaterialStateProperty.all<Size>(
      Size.square(50.0),
    ),
    shape: MaterialStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      uid = user!.uid;
    }
    if (uid == firstPlayerId) {
      isUserFirstPlayer = true;
    } else if (uid == secondPlayerId) {
      isUserFirstPlayer = false;
    }
    if (isFirstPlayer && isUserFirstPlayer) {
      isAllowedToThrow = true;
    } else if (!isFirstPlayer && !isUserFirstPlayer) {
      isAllowedToThrow = true;
    } else {
      isAllowedToThrow = false;
    }

    return SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: () async {
          await _loadData();
        },
        child: Scaffold(
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
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: Text(
                                  firstPlayer,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    firstPlayerSets.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ),
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    firstPlayerLegs.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                (pointsToScore - firstPlayerScore).toString(),
                                style: const TextStyle(
                                  fontSize: 32,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      firstPlayerDarts[0].toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                      ),
                                      child: Text(
                                        firstPlayerDarts[1].toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      firstPlayerDarts[2].toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 100,
                        ),
                        SizedBox(
                          width: 120,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: Text(
                                  secondPlayer,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    secondPlayerSets.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    secondPlayerLegs.toString(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                (pointsToScore - secondPlayerScore).toString(),
                                style: const TextStyle(
                                  fontSize: 32,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      secondPlayerDarts[0].toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        right: 8,
                                      ),
                                      child: Text(
                                        secondPlayerDarts[1].toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      secondPlayerDarts[2].toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    isFirstPlayer
                        ? Text(
                            'Rzuca gracz $firstPlayer',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          )
                        : Text(
                            'Rzuca gracz $secondPlayer',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Runda: ${round.toString()}',
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    doubleNextValue
                                        ? const Color.fromARGB(
                                            125, 123, 193, 255)
                                        : const Color.fromARGB(
                                            255, 123, 193, 255),
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                    const Size.square(50.0),
                                  ),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (!tripleNextValue && isAllowedToThrow) {
                                    doubleValue();
                                  }
                                },
                                child: const Text('x2'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    tripleNextValue
                                        ? const Color.fromARGB(
                                            125, 123, 193, 255)
                                        : const Color.fromARGB(
                                            255, 123, 193, 255),
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                    const Size.square(50.0),
                                  ),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (!doubleNextValue && isAllowedToThrow) {
                                    tripleValue();
                                  }
                                },
                                child: const Text('x3'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    tripleNextValue
                                        ? const Color.fromARGB(
                                            125, 123, 193, 255)
                                        : const Color.fromARGB(
                                            255, 123, 193, 255),
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                    const Size.square(50.0),
                                  ),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (!tripleNextValue && isAllowedToThrow) {
                                    addValueToScore(25);
                                  }
                                },
                                child: const Text('25'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    (tripleNextValue || doubleNextValue)
                                        ? const Color.fromARGB(
                                            125, 123, 193, 255)
                                        : const Color.fromARGB(
                                            255, 123, 193, 255),
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                    const Size.square(50.0),
                                  ),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (!(tripleNextValue || doubleNextValue) &&
                                      isAllowedToThrow) {
                                    addValueToScore(0);
                                  }
                                },
                                child: const Text('0'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    const Color.fromARGB(125, 123, 193, 255),
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                    const Size.square(50.0),
                                  ),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  // ZAIMPLEMENTOWAĆ COFNIĘCIE POPRZEDNIEGO RZUTU W PRZYSZLOSCI
                                },
                                child: const Icon(Icons.arrow_back),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(1);
                                  }
                                },
                                child: const Text('1'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(2);
                                  }
                                },
                                child: const Text('2'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(3);
                                  }
                                },
                                child: const Text('3'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(4);
                                  }
                                },
                                child: const Text('4'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(5);
                                  }
                                },
                                child: const Text('5'),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(6);
                                  }
                                },
                                child: const Text('6'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(7);
                                  }
                                },
                                child: const Text('7'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(8);
                                  }
                                },
                                child: const Text('8'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(9);
                                  }
                                },
                                child: const Text('9'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(10);
                                  }
                                },
                                child: const Text('10'),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(11);
                                  }
                                },
                                child: const Text('11'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(12);
                                  }
                                },
                                child: const Text('12'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(13);
                                  }
                                },
                                child: const Text('13'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(14);
                                  }
                                },
                                child: const Text('14'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(15);
                                  }
                                },
                                child: const Text('15'),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(16);
                                  }
                                },
                                child: const Text('16'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(17);
                                  }
                                },
                                child: const Text('17'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(18);
                                  }
                                },
                                child: const Text('18'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(19);
                                  }
                                },
                                child: const Text('19'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (isAllowedToThrow) {
                                    addValueToScore(20);
                                  }
                                },
                                child: const Text('20'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
        ));
  }
}
