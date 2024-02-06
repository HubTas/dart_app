import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartapp/tournament_item.dart';
import 'package:flutter/material.dart';

class Tournaments extends StatefulWidget {
  const Tournaments({super.key});

  @override
  State<Tournaments> createState() => _TournamentsState();
}

class _TournamentsState extends State<Tournaments> {
  final collectionReference =
      FirebaseFirestore.instance.collection('tournaments');
  List<String> idsList = [];

  Future<List<String>> fetchIds() async {
    QuerySnapshot querySnapshot = await collectionReference.get();

    querySnapshot.docs.forEach((doc) {
      if (!idsList.contains(doc.id)) {
        idsList.add(doc.id);
      }
    });

    return idsList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: fetchIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Wystąpił błąd: ${snapshot.error}');
        } else {
          return RefreshIndicator(
            onRefresh: fetchIds,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                  itemCount: idsList.length,
                  itemBuilder: (ctx, index) {
                    return TournamentItem(
                      tournamentId: idsList[index],
                    );
                  }),
            ),
          );
        }
      },
    );
  }
}
