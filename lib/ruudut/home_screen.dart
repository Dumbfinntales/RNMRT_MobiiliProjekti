import 'package:flutter/material.dart';
import 'add_task_screen.dart'; // Importataan AddTaskScreen, jotta sitä voi käyttää

// HomeScreen on sovelluksen päänäkymä, jossa käyttäjä voi lisätä ja poistaa tehtäviä
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> tehtavat = []; // Tehtävälista, lista on tyhjä aluksi kunnes sinne lisätään tehtäviä

  // Funktio tehtävän lisäämiseen
  void _addTask(String uusiTehtava) {
    setState(() {
      tehtavat.add(uusiTehtava); // Lisää tehtävän ja päivittää näkymän
    });
  }

  // Funktio tehtävän poistamiseen
  void _removeTask(int index) {
    setState(() {
      tehtavat.removeAt(index); // Poistaa valitun tehtävän ja päivittää näkymän
    });
  }

  // Funktio tehtävän muokkaamiseen
  void _editTask(int index, String uusiTeksti) {
    setState(() {
      tehtavat[index] = uusiTeksti; // Päivittää muokatun tehtävän listassa
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tehtävät')),

      // Näytä tehtävälista tai ilmoitus, jos lista on tyhjä
      body: tehtavat.isEmpty
          ? Center(child: Text("Ei tehtäviä, lisää uusi tehtävä!"))
          : ListView.builder(
              itemCount: tehtavat.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(tehtavat[index]),

                // Poistoikoni, joka poistaa tehtävän
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Varmistaa, että ikoni ei vie liikaa tilaa
                  children: [
                    // Muokkausikoni
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final muokattu = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTaskScreen(
                              alkuperainenTehtava: tehtavat[index], // Siirrä alkuperäinen tehtävä muokkausruutuun
                            ),
                          ),
                        );
                        if (muokattu != null &&
                            muokattu is String &&
                            muokattu.trim().isNotEmpty) {
                          _editTask(index, muokattu.trim()); // Päivitä tehtävä listassa
                        }
                      },
                    ),
                    // Poistoikoni
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTask(index),
                    ),
                  ],
                ),
              ),
            ),

      // Lisää tehtävä -painike, joka avaa AddTaskScreen ruudun
      floatingActionButton: SizedBox(
        width: 180, // Muokattu leveämmäksi
        child: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('Lisää tehtävä'), // Teksti napissa
          onPressed: () async {
            final tulos = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddTaskScreen()),
            );
            if (tulos != null &&
                tulos is String &&
                tulos.trim().isNotEmpty) {
              _addTask(tulos.trim()); // Lisää uusi tehtävä listalle
            }
          },
        ),
      ),
    );
  }
}
