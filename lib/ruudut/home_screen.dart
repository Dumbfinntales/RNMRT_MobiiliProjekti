import 'package:flutter/material.dart';
import 'add_task_screen.dart'; // Importataan AddTaskScreen, jotta sitä voi käyttää

// HomeScreen on sovelluksen päänäkymä, jossa käyttäjä voi lisätä ja poistaa tehtäviä
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> tehtavat = []; // Tehtävälista, lista on tyhjä aluksi kunnes sinne lisätään tehtäviä

  void _addTask(String uusiTehtava) {
    setState(() {
      tehtavat.add(uusiTehtava); // Lisää tehtävän ja päivittää näkymän
    });
  }

  void _removeTask(int index) {
    setState(() {
      tehtavat.removeAt(index); // Poistaa valitun tehtävän ja päivittää näkymän
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tehtävät')),

      // Näytä tehtävälista tai ilmoitus, jos lista on tyhjä
      body: tehtavat.isEmpty
          ? Center(child: Text("Ei tehtäviä, lisää uusi tehtävä!"))
          // Näytä tehtävälista, jos tehtäviä on
          : ListView.builder(
              itemCount: tehtavat.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(tehtavat[index]),

                // Poistoikoni, joka poistaa tehtävän
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeTask(index),
                ),
              ),
            ),

      // Lisää tehtävä -painike, joka avaa AddTaskScreen ruudun
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final tulos = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen()),
          );

          if (tulos != null && tulos is String && tulos.trim().isNotEmpty) {
            _addTask(tulos.trim());
          }
        },
      ),
    );
  }
}