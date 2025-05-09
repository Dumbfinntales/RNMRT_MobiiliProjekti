import 'package:flutter/material.dart';
import 'add_task_screen.dart'; // Tuodaan tehtävänlisäys-/muokkausnäyttö

// Etusivun StatefulWidget, jossa tehtävälista näkyy
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _tasks = []; // Lista tallennetuista tehtävistä

  // Avaa tehtävänlisäysnäytön ja lisää uuden tehtävän paluun jälkeen
  Future<void> _navigateAndAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen()),
    );

    // Jos tuloksena saatiin tehtävädataa
    if (result != null) {
      setState(() {
        _tasks.add(result); // Lisätään uusi tehtävä listaan
      });
    }
  }

  // Avaa tehtävänmuokkausnäytön ja päivittää olemassa olevan tehtävän
  Future<void> _editTask(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          alkuperainenTehtava: _tasks[index]['tehtava'],
          alkuperainenPaivamaara: _tasks[index]['paivamaara'],
          alkuperainenPrioriteetti: _tasks[index]['priority'],
        ),
      ),
    );

    // Jos käyttäjä teki muutoksia
    if (result != null) {
      setState(() {
        _tasks[index] = result; // Päivitetään tehtävän tiedot
      });
    }
  }

  // Poistaa tehtävän listalta
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index); // Poistetaan valittu tehtävä
    });
  }

  // Määrittää prioriteettiin liittyvän värin
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Muotoilee päivämäärän dd-MM-yyyy
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tehtävälista'), // Sovelluksen otsikko
      ),
      body: ListView.builder(
        itemCount: _tasks.length, // Listan koko
        itemBuilder: (context, index) {
          final tehtava = _tasks[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              // Väripalkki tehtävän prioriteetin mukaan
              leading: Container(
                width: 10,
                height: double.infinity,
                color: _getPriorityColor(tehtava['priority']),
              ),
              title: Text(tehtava['tehtava']),
              subtitle: Text('Päivämäärä: ${_formatDate(tehtava['paivamaara'])}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Muokkauspainike
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editTask(index),
                  ),
                  // Poistopainike
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTask(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // Plus-nappi uuden tehtävän lisäämiseen
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddTask,
        child: Icon(Icons.add),
        tooltip: 'Lisää tehtävä',
      ),
    );
  }
}
