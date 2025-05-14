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
  String _selectedFilter = 'all'; // Suodatuksen oletusarvo

  // Jokainen tehtävä on Map, jossa on avaimet 'tehtava', 'paivamaara' ja 'priority'
  void _toggleTaskDone(int index) async {
    setState(() {
      _filteredTasks()[index]['done'] = !_filteredTasks()[index]['done'];
      _sortTasks();
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
        _sortTasks();
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
          taskCopy['paivamaara'] =
              (taskCopy['paivamaara'] as DateTime).toIso8601String();
        }

        return jsonEncode(taskCopy); // Muutetaan Map JSON-merkkijonoksi
      }).toList();

      await prefs.setStringList('tasks', taskJsonList); // Tallennetaan laitteelle
      print("Tehtävä tallennettu: $taskJsonList"); // Tulostus testausta varten
    } catch (e) {
      print("Virhe tallennuksessa: $e");
    }
  }

  // Tehtävien lataus SharedPreferencesista
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedTasks = prefs.getStringList('tasks');

    if (storedTasks != null) {
      final List<Map<String, dynamic>> loadedTasks = storedTasks.map((jsonStr) {
        final Map<String, dynamic> decoded =
            Map<String, dynamic>.from(jsonDecode(jsonStr));
        decoded['paivamaara'] = DateTime.parse(decoded['paivamaara']);
        decoded['done'] = decoded['done'] ?? false;
        return decoded;
      }).toList();

      setState(() {
        _tasks = loadedTasks;
        _sortTasks();
      });
    }
  }

  // Avaa tehtävänmuokkausnäytön ja päivittää olemassa olevan tehtävän
  Future<void> _editTask(int index) async {
    final taskToEdit = _filteredTasks()[index];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          alkuperainenTehtava: taskToEdit['tehtava'],
          alkuperainenPaivamaara: taskToEdit['paivamaara'],
          alkuperainenPrioriteetti: taskToEdit['priority'],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        int originalIndex = _tasks.indexOf(taskToEdit);
        _tasks[originalIndex] = result;
        _sortTasks();
      });
      await _saveTasks();
    }
  }

  // Poistaa tehtävän listalta
  void _deleteTask(int index) {
    setState(() {
      final taskToRemove = _filteredTasks()[index];
      _tasks.remove(taskToRemove);
    });
    _saveTasks();
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

  // Palauttaa suodatetun tehtävälistan valinnan perusteella
  List<Map<String, dynamic>> _filteredTasks() {
    if (_selectedFilter == 'all') return _tasks; // Ei suodatusta

    return _tasks.where((task) => task['priority'] == _selectedFilter).toList();
  }

  // Järjestää tehtävät niin että tekemättömät ovat ensin
  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a['done'] == b['done']) return 0;
      return a['done'] ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTasks();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tehtävälista'),
      ),
      body: Column(
        children: [
          // Suodatin Dropdown prioriteetin mukaan
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedFilter,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
              items: [
                DropdownMenuItem(value: 'all', child: Text('Kaikki')),
                DropdownMenuItem(value: 'high', child: Text('Kiireelliset')),
                DropdownMenuItem(value: 'medium', child: Text('Tärkeät')),
                DropdownMenuItem(value: 'low', child: Text('Ei kiireelliset')),
              ],
            ),
          ),

          // Tehtävälista
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final task = filtered[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: task['done'] ? Colors.green[100] : null,
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
                        decoration: task['done']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task['done'] ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                        'Päivämäärä: ${_formatDate(task['paivamaara'])}'),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndAddTask,
        child: Icon(Icons.add),
        tooltip: 'Lisää tehtävä',
      ),
    );
  }
}
