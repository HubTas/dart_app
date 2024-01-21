import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartapp/tournament_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';

class TournamentCreation extends StatefulWidget {
  const TournamentCreation({
    super.key,
  });

  @override
  State<TournamentCreation> createState() => _TournamentCreationState();
}

class _TournamentCreationState extends State<TournamentCreation> {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController playersNumberController = TextEditingController();
  final TextEditingController endingTypesController = TextEditingController();
  final TextEditingController legsNumberController = TextEditingController();
  final TextEditingController setsNumberController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();
  String? selectedType;
  String? endingType;
  int? selectedNumber;
  int? setNumber;
  int? legNumber;
  int? score;
  int selectedIcon = 1; // Icons.emoji_events;
  Color selectedColor = const Color.fromARGB(255, 255, 255, 0);
  bool isPressed = false;
  Color pickerColor = const Color(0xff443a49);
  bool isPrivate = true;
  bool accept = false;
  User? user = FirebaseAuth.instance.currentUser;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void dispose() {
    typeController.dispose();
    nameController.dispose();
    playersNumberController.dispose();
    super.dispose();
  }

  void createTournament() async {
    try {
      CollectionReference collection =
          FirebaseFirestore.instance.collection('tournaments');

      String uid = user!.uid;

      DocumentReference tournament = await collection.add({
        'name': nameController.text,
        'password': passwordController.text,
        'type': typeController.text,
        'playersNumber': playersNumberController.text,
        'endingType': endingTypesController.text,
        'legsNumber': legsNumberController.text,
        'setsNumber': setsNumberController.text,
        'scoreNumber': scoreController.text,
        'isPrivate': isPrivate,
        'icon': selectedIcon,
        'iconColor': selectedColor.value.toString(),
        'creatorId': uid,
        'playersList': <String>[],
        'isSeed': false,
      });

      String tournamentId = tournament.id;

      Get.to(
        TournamentScreen(
          tournamentId: tournamentId,
        ),
      );
    } catch (e) {
      print('Wystąpił błąd podczas dodawania do Firebase: $e');
    }
  }

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _pickedFile;
  String _iconUrl = '';

  Future<void> _pickIcon() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  Future<void> _uploadIcon() async {
    if (_pickedFile != null) {
      try {
        final Reference storageRef =
            FirebaseStorage.instance.ref().child('icons/icon.png');
        final File iconFile = File(_pickedFile!.path);

        await storageRef.putFile(iconFile);
        final String iconUrl = await storageRef.getDownloadURL();

        setState(() {
          _iconUrl = iconUrl;
        });

        print('Icon uploaded to Firebase Storage. URL: $_iconUrl');
      } catch (error) {
        print('Wystąpił błąd podczas dodawania do Firebase: $error');
      }
    }
  }

  Future<void> creationTournamentDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              textAlign: TextAlign.center,
              'Czy na pewno chcesz stworzyć turniej?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nazwa: ${nameController.text}\n',
              ),
              Text(
                'Hasło: ${passwordController.text}\n',
              ),
              Text(
                'Typ: ${typeController.text}\n',
              ),
              Text(
                'Liczba graczy: ${playersNumberController.text}\n',
              ),
              Text(
                'Sposób zakończenia meczu: ${endingTypesController.text}\n',
              ),
              Text(
                'Ilośc legów: ${legsNumberController.text}\n',
              ),
              Text(
                'Ilość setów: ${setsNumberController.text}\n',
              ),
              Text(
                'Ilość punktów: ${scoreController.text}\n',
              ),
              Text(
                'Dostępność: ${isPrivate ? 'prywatny' : 'publiczny'}\n',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ikona: ',
                  ),
                  Icon(
                    selectedIcon == 1
                        ? Icons.emoji_events
                        : selectedIcon == 2
                            ? Icons.star
                            : Icons.favorite,
                    color: selectedColor,
                  ),
                ],
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Tak'),
              onPressed: () {
                accept = true;
                Get.back();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Nie'),
              onPressed: () {
                accept = false;
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  void openColorPickerDialog() {
    showDialog(
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => selectedColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      context: context,
    );
  }

  Future<void> _showIconPickerDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: ListView(
            children: [
              const SizedBox(
                height: 15,
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text("Puchar"),
                onTap: () {
                  Navigator.pop(context, Icons.emoji_events);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text("Gwiazda"),
                onTap: () {
                  Navigator.pop(context, Icons.star);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text("Serce"),
                onTap: () {
                  Navigator.pop(context, Icons.favorite);
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        if (value == Icons.emoji_events) {
          setState(() {
            selectedIcon = 1;
          });
        } else if (value == Icons.star) {
          setState(() {
            selectedIcon = 2;
          });
        } else {
          setState(() {
            selectedIcon = 3;
          });
        }
      }
    });
  }

  void showValidateDialog(String errorMessage) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textAlign: TextAlign.center, errorMessage),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  bool validateAndProceed() {
    if (nameController.text.isEmpty) {
      showValidateDialog('Nazwa turnieju jest pusta');
      return false;
    }
    if (passwordController.text.isEmpty) {
      showValidateDialog('Hasło jest puste');
      return false;
    }
    if (typeController.text.isEmpty) {
      showValidateDialog('Typ jest pusty');
      return false;
    }
    if (playersNumberController.text.isEmpty) {
      showValidateDialog('Liczba graczy jest pusta');
      return false;
    }
    if (endingTypesController.text.isEmpty) {
      showValidateDialog('Sposób zakończenia jest pusty');
      return false;
    }
    if (legsNumberController.text.isEmpty) {
      showValidateDialog('Ilość legów jest pusta');
      return false;
    }
    if (setsNumberController.text.isEmpty) {
      showValidateDialog('Ilość setów jest pusta');
      return false;
    }
    if (scoreController.text.isEmpty) {
      showValidateDialog('Ilość punktów jest pusta');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<String> types = [
      // 'System kołowy',
      // 'System grupowy',
      // 'System szwajcarski',
      'System pucharowy',
      // 'System pucharowy do dwóch przegranych',
      // 'System mieszany',
    ];

    List<int> numbers = [
      2,
      4,
      8,
      16,
      32,
    ];

    List<String> endingTypes = [
      'single-out',
      'double-out',
      'triple-out',
    ];

    List<int> legs = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    ];

    List<int> sets = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    ];

    List<int> scores = [
      301,
      501,
      701,
    ];

    final List<DropdownMenuEntry<String>> typeEntries =
        <DropdownMenuEntry<String>>[];
    for (final String type in types) {
      typeEntries.add(
        DropdownMenuEntry<String>(
          label: type,
          value: type,
        ),
      );
    }

    final List<DropdownMenuEntry<int>> numberEntries =
        <DropdownMenuEntry<int>>[];
    for (final int number in numbers) {
      numberEntries.add(
        DropdownMenuEntry<int>(
          label: number.toString(),
          value: number,
        ),
      );
    }

    final List<DropdownMenuEntry<String>> endingTypesEntries =
        <DropdownMenuEntry<String>>[];
    for (final String type in endingTypes) {
      endingTypesEntries.add(
        DropdownMenuEntry<String>(
          label: type,
          value: type,
        ),
      );
    }

    final List<DropdownMenuEntry<int>> legsEntries = <DropdownMenuEntry<int>>[];
    for (final int leg in legs) {
      legsEntries.add(
        DropdownMenuEntry<int>(
          label: leg.toString(),
          value: leg,
        ),
      );
    }

    final List<DropdownMenuEntry<int>> setsEntries = <DropdownMenuEntry<int>>[];
    for (final int set in sets) {
      setsEntries.add(
        DropdownMenuEntry<int>(
          label: set.toString(),
          value: set,
        ),
      );
    }

    final List<DropdownMenuEntry<int>> scoreEntries =
        <DropdownMenuEntry<int>>[];
    for (final int score in scores) {
      scoreEntries.add(
        DropdownMenuEntry<int>(
          label: score.toString(),
          value: score,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            width: 350,
            height: 70,
            child: Text(
              textAlign: TextAlign.center,
              'Stwórz nowy turniej',
              style: TextStyle(
                fontSize: 26,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: 10,
            ),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                hintText: 'Nazwa',
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: 10,
            ),
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                hintText: 'Hasło',
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownMenu(
              width: 360,
              label: const Text('Typ'),
              dropdownMenuEntries: typeEntries,
              controller: typeController,
              onSelected: (String? type) {
                setState(() {
                  selectedType = type;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownMenu(
              width: 360,
              label: const Text('Liczba graczy'),
              dropdownMenuEntries: numberEntries,
              controller: playersNumberController,
              onSelected: (int? number) {
                setState(() {
                  selectedNumber = number;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownMenu(
              width: 360,
              label: const Text('Sposób zakończenia meczu'),
              dropdownMenuEntries: endingTypesEntries,
              controller: endingTypesController,
              onSelected: (String? type) {
                setState(() {
                  endingType = type;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownMenu(
              width: 360,
              label: const Text('Liczba legów'),
              dropdownMenuEntries: legsEntries,
              controller: legsNumberController,
              onSelected: (int? number) {
                setState(() {
                  legNumber = number;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownMenu(
              width: 360,
              label: const Text('Liczba setów'),
              dropdownMenuEntries: setsEntries,
              controller: setsNumberController,
              onSelected: (int? number) {
                setState(() {
                  setNumber = number;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownMenu(
              width: 360,
              label: const Text('Liczba punktów'),
              dropdownMenuEntries: scoreEntries,
              controller: scoreController,
              onSelected: (int? number) {
                setState(() {
                  score = number;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ToggleSwitch(
              minWidth: 150,
              minHeight: 40,
              cornerRadius: 20.0,
              activeBgColors: [
                [Colors.green[800]!],
                [Colors.red[800]!]
              ],
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              initialLabelIndex: 0,
              totalSwitches: 2,
              labels: const ['Prywatny', 'Publiczny'],
              radiusStyle: true,
              onToggle: (index) {
                if (index == 0) {
                  isPrivate = true;
                } else {
                  isPrivate = false;
                }
                print('switched to: $index');
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Wybierz ikone dla turnieju',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: _showIconPickerDialog,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Icon(
                      size: 120,
                      selectedIcon == 1
                          ? Icons.emoji_events
                          : selectedIcon == 2
                              ? Icons.star
                              : Icons.favorite,
                      color: selectedColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    openColorPickerDialog();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.indigo,
                          Colors.purple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 30,
            ),
            child: SizedBox(
              width: 150,
              child: FloatingActionButton(
                heroTag: 'button5',
                backgroundColor: const Color.fromARGB(255, 123, 193, 255),
                onPressed: () async {
                  if (validateAndProceed()) {
                    await creationTournamentDialog(context);
                    if (accept) {
                      createTournament();
                    }
                  }
                },
                child: const Text(
                  'Stwórz turniej',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
