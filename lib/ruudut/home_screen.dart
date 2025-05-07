import 'package:flutter/material.dart';
import 'add_task_screen.dart'; // Importataan AddTaskScreen, jotta sitä voi käyttää

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> tehtavat = []; // Määritetään tehtävät listaksi, joka sisältää sekä tehtävän tekstin että päivämäärän

  // Funktio tehtävän lisäämiseen
  void _addTask(String uusiTehtava, DateTime paivamaara) {
    setState(() {
      tehtavat.add({
        'tehtava': uusiTehtava,
        'paivamaara': paivamaara,
      });
      // Järjestetään tehtävät aikajärjestykseen 
      tehtavat.sort((a, b) => a['paivamaara'].compareTo(b['paivamaara']));
    });
  }

  // Funktio tehtävän poistamiseen
  void _removeTask(int index) {
    setState(() {
      tehtavat.removeAt(index); // Poistaa valitun tehtävän ja päivittää näkymän
    });
  }

  // Funktio tehtävän muokkaamiseen
  void _editTask(int index, String uusiTehtava, DateTime paivamaara) {
    setState(() {
      tehtavat[index] = {
        'tehtava': uusiTehtava,
        'paivamaara': paivamaara,
      };
      tehtavat.sort((a, b) => a['paivamaara'].compareTo(b['paivamaara']));
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
              itemBuilder: (context, index) {
                final tehtava = tehtavat[index];
                final paiva = tehtava['paivamaara'] as DateTime;

                return ListTile(
                  // Päivämäärä
                  title: Text('${paiva.day}.${paiva.month}.${paiva.year}',
                  style: TextStyle(fontSize: 14)
                  ), 
                  // Tehtävä
                  subtitle: Text(tehtava['tehtava'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ), 
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
                                alkuperainenTehtava: tehtava['tehtava'],
                                alkuperainenPaivamaara: paiva,
                              ),
                            ),
                          );
                          if (muokattu != null &&
                              muokattu is Map &&
                              muokattu['tehtava'] != null &&
                              muokattu['paivamaara'] != null) {
                            _editTask(index, muokattu['tehtava'], muokattu['paivamaara']);
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
                );
              },
            ),
      // Lisää tehtävä -painike, joka avaa AddTaskScreen ruudun
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Lisää tehtävä'),
        onPressed: () async {
          final tulos = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen()),
          );
          if (tulos != null &&
              tulos is Map &&
              tulos['tehtava'] != null &&
              tulos['paivamaara'] != null) {
            _addTask(tulos['tehtava'], tulos['paivamaara']);
          }
        },
      ),
    );
  }
}
