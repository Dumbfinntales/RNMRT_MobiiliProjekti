import 'package:flutter/material.dart';
import 'add_task_screen.dart'; // Tuodaan tehtävänlisäys-/muokkausnäyttö
import 'package:shared_preferences/shared_preferences.dart'; // Tallennusta varten
import 'dart:convert'; // JSON data muotoilua varten

// Etusivun StatefulWidget, jossa tehtävälista näkyy
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _tasks = []; // Lista tallennetuista tehtävistä
  // Jokainen tehtävä on Map, jossa on avaimet 'tehtava', 'paivamaara' ja 'priority'
  void _toggleTaskDone(int index) async {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done'];
      _tasks.sort((a, b) {
        if (a['done'] == b['done']) return 0;
        return a['done'] ? 1 : -1; // Done items to bottom
      });
    });
    await _saveTasks(); // Save changes
  }
  @override
  void initState() {
    super.initState();
    _loadTasks(); // Ladataan tallennetut tehtävät sovelluksen käynnistyessä
  }

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
      await _saveTasks(); // Tallennetaan päivitetty tehtävälista
    }
  }

  // Tallentaa tehtävät pysyvästi SharedPreferencesiin
  Future<void> _saveTasks() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Muutetaan jokainen tehtävä JSON-merkkijonoksi
    final List<String> taskJsonList = _tasks.map((task) {
      final taskCopy = Map<String, dynamic>.from(task);

      if (taskCopy['paivamaara'] is DateTime) {
        taskCopy['paivamaara'] = (taskCopy['paivamaara'] as DateTime).toIso8601String();
      }

      return jsonEncode(taskCopy); // Muutetaan Map JSON-merkkijonoksi
    }).toList();

    await prefs.setStringList('tasks', taskJsonList); // Tallennetaan laitteelle
    print("Tehtävä tallennettu: $taskJsonList"); // Tulostus testausta varten
  } catch (e) {
    print("Virhe tallennuksessa: $e");
  }
}

  // Tehtävien latuas SharedPreferencesista
  Future<void> _loadTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? storedTasks = prefs.getStringList('tasks');

  if (storedTasks != null) {
    final List<Map<String, dynamic>> loadedTasks = storedTasks.map((jsonStr) {
      final Map<String, dynamic> decoded = Map<String, dynamic>.from(jsonDecode(jsonStr));
      decoded['paivamaara'] = DateTime.parse(decoded['paivamaara']); // Muutetaan merkkijono takaisin DateTime-tyyppiseksi
      decoded['done'] = decoded['done'] ?? false;
      return decoded;
    }).toList();

    setState(() {
      _tasks = loadedTasks; // Päivitetään tehtävälista ladatuilla tiedoilla
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
      await _saveTasks(); // Tallennetaan muutokset
    }
  }

  // Poistaa tehtävän listalta
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index); // Poistetaan valittu tehtävä
    });
    _saveTasks(); // Tallennetaan muutokset
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
          final task = _tasks[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              onTap: () => _toggleTaskDone(index),
              leading: Container(
                width: 10,
                height: double.infinity,
                color: _getPriorityColor(task['priority']),
              ),
              title: Text(
                task['tehtava'],
                style: TextStyle(
                  decoration: task['done'] ? TextDecoration.lineThrough : TextDecoration.none,
                  color: task['done'] ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text('Päivämäärä: ${_formatDate(task['paivamaara'])}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editTask(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTask(index),
                  ),
                ],
              ),
            )
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
