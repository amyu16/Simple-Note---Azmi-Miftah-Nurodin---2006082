import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_note/extension/date_formatter.dart';
import 'package:simple_note/util/app_routes.dart';
import '../model/note.dart';
import '../services/database_services.dart';
import 'package:hive_flutter/adapters.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService dbService = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Simple Note'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).pushNamed('add-note');
        },
        child: const Icon(
          Icons.post_add_rounded,
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.boxName).listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text("Tidak Ada Data"),
            );
          } else {
            return ListView.separated(
              itemBuilder: (context, index) {
                Note tempNote = box.getAt(index);
                return Dismissible(
                  key: Key(tempNote.key.toString()),
                  onDismissed: (_) {
                    dbService.deleteNote(tempNote).then(
                      (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                            content: Text("Note Telah Dihapus"),
                          ),
                        );
                      },
                    );
                  },
                  child: NoteCard(
                    note: tempNote,
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 0,
                );
              },
              itemCount: box.length,
            );
          }
        },
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
  });

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(255, 209, 209, 209),
      ),
      child: ListTile(
        onTap: () {
          GoRouter.of(context).pushNamed(
            AppRoutes.editNote,
            extra: note,
          );
        },
        title: Text(note.title),
        subtitle: Text(note.description),
        trailing: Text('Dibuat pada: \n${note.createdAt.toSunda()}'),
      ),
    );
  }
}
