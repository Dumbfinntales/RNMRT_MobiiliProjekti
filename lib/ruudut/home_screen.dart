import 'package:flutter/material.dart'; // Flutterin widgetit
import 'add_task_screen.dart'; // Tuodaan tehtävänlisäys-/muokkausnäyttö
import 'package:shared_preferences/shared_preferences.dart'; // Tallennusta varten
import 'dart:convert'; // JSON data muotoilua varten
import 'package:intl/intl.dart'; // Kirjasto päivämäärän muotoiluun

// Etusivun StatefulWidget, jossa tehtävälista näkyy
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _tasks = []; // Lista tallennetuista tehtävistä
  List<String> _selectedPriorities = ['high', 'medium', 'low']; // Valitut prioriteetit
  String _statusFilter = 'all'; // Suodatuksen oletusarvo
  String _searchQuery = ''; // Haku
  bool _darkMode = false; // Seuraa teemaa, vaalea tai tumma

  // Jokainen tehtävä on Map, jossa on avaimet 'tehtava', 'paivamaara' ja 'priority'
  void _toggleTaskDone(int index) async {
    final task = _filteredTasks()[index];
    final originalIndex = _tasks.indexOf(task); // Etsitään alkuperäinen indeksi

    setState(() {
      _tasks[originalIndex]['done'] = !_tasks[originalIndex]['done'];
      _sortTasks();
    });
    await _saveTasks(); // Tallennetaan
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();  // Ladataan tallennetut tehtävät sovelluksen käynnistyessä
  }
  // Avaa tehtävänlisäysnäytön ja lisää uuden tehtävän paluun jälkeen
  Future<void> _navigateAndAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen(darkMode: _darkMode)),
    );

    // Jos tuloksena saatiin tehtävädataa
    if (result != null) {
      setState(() {
        _tasks.add(result); // Lisätään uusi tehtävä listaan
        _sortTasks();
      });
      await _saveTasks();  // Tallennetaan päivitetty tehtävälista
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
          darkMode: _darkMode,
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
    final taskToRemove = _filteredTasks()[index];
    final originalIndex = _tasks.indexOf(taskToRemove); // Etsitään alkuperäinen indeksi

    setState(() {
      _tasks.removeAt(originalIndex);
    });
    _saveTasks();
  }

  // Määrittää prioriteettiin liittyvän värin
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Color(0xFFE6564C);
      case 'medium':
        return Color(0xFFFEDA7A);
      case 'low':
        return Color(0xFFA2E8BE);
      default:
        return Colors.grey;
    }
  }
  // Muotoilee päivämäärän dd-MM-yyyy ja kellonajan HH:mm -muotoon
  String _formatDate(DateTime date) {
    final datePart = DateFormat('dd.MM.yy').format(date); // Päivämäärä
    final timePart = DateFormat('HH:mm').format(date); // Aika 24h muodossa
    return '$datePart \nKlo $timePart'; // Lisää "klo"
  }

  // HAKU & SUODATUS
  // Palauttaa suodatetun tehtävälistan suodattimen ja hakusanan perusteella
  List<Map<String, dynamic>> _filteredTasks() {
    return _tasks.where((task) {
      // Tarkistaa täsmääkö tehtävän prioriteetti suodattimeen, tai jos suodatin on 'all'
      final matchesPriority = _selectedPriorities.contains(task['priority']);
      final matchesDone =
          _statusFilter == 'all' ||
          (_statusFilter == 'done' && task['done'] == true) ||
          (_statusFilter == 'not_done' && task['done'] != true);

      // Muutetaan pieniksi kirjaimiksi
      final tehtavaTeksti =
          task['tehtava'].toLowerCase();
           // Muodostetaan numero tekstimuotoon
      final paivamaaraTeksti =
          _formatDate(task['paivamaara']).toLowerCase();

      // Tarkistetaan täsmääkö hakusana joko tehtävän tekstissä tai päivämäärässä
      final matchesSearch = tehtavaTeksti.contains(_searchQuery.toLowerCase()) ||
          paivamaaraTeksti.contains(_searchQuery.toLowerCase());
       // Palautetaan true vain jos molemmat ehdot täyttyvät: prioriteettisuodatin ja hakusana
      return matchesPriority && matchesDone && matchesSearch;
    }).toList(); // Muutetaan tulos listaksi ja palautetaan
  }

  // Järjestää tehtävät niin että tekemättömät ovat ensin
  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a['done'] == b['done']) return 0;
      return a['done'] ? 1 : -1;
    });
  }

  // Näyttää suodatusikkunan, jossa käyttäjä voi valita:
  // - Prioriteetit (kiireelliset, tärkeät, ei kiireelliset)
  // - Tilan (kaikki, tehdyt, tekemättömät)
  // Valinnat vaikuttavat tehtävälistan näkymään
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Suodattimet"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Prioriteetti:"),
                    ...['high', 'medium', 'low'].map((priority) {
                      return CheckboxListTile(
                        activeColor: Color(0xFF444444),
                        title: Text(
                          priority == 'high'
                              ? 'Kiireelliset'
                              : priority == 'medium'
                                  ? 'Tärkeät'
                                  : 'Ei kiireelliset',
                        ),
                        value: _selectedPriorities.contains(priority),
                        onChanged: (value) {
                          setStateDialog(() {
                            if (value == true) {
                              _selectedPriorities.add(priority);
                            } else {
                              _selectedPriorities.remove(priority);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                    Divider(),
                    Text("Tila:"),
                    ...['all', 'done', 'not_done'].map((status) {
                      return RadioListTile<String>(
                        activeColor: Color(0xFF444444),
                        title: Text(
                          status == 'all'
                              ? 'Kaikki tehtävät'
                              : status == 'done'
                                  ? 'Tehdyt'
                                  : 'Tekemättömät',
                        ),
                        value: status,
                        groupValue: _statusFilter,
                        onChanged: (value) {
                          setStateDialog(() {
                            _statusFilter = value!;
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Sulje"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTasks();

    return Scaffold(
       // Taustan väri riippuen moodista
      backgroundColor: _darkMode ? const Color.fromARGB(200, 0, 0, 0) : Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Otsikko + Switch
          Padding(
            padding: const EdgeInsets.only(top: 80, bottom: 8.0, left: 28, right: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ToDo',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
                  color: _darkMode ? Colors.white : Colors.black), // Väri muuttuu riippuen moodista
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      _darkMode ? Icons.nightlight_round : Icons.wb_sunny, // Aurinko tai kuu ikoni
                    color: _darkMode ? Colors.yellowAccent : Colors.orange, // Väri riippuu moodista
                    ),
                    SizedBox(width: 8),
                    Switch(
                      value: _darkMode,
                      onChanged: (bool newValue) {
                        setState(() {
                          _darkMode = newValue;
                        });
                      },
                      activeColor: Colors.orange[900],
                      inactiveThumbColor: Colors.orange[300],
                    ),
                  ],
                )
              ],
            ),
          ),

          // Hakukenttä + Suodatusvalikko
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              children: [
                TextField(
                  style: TextStyle(
                    fontSize: 18,
                    color: _darkMode ? Colors.white : Colors.black, // Muuttuu moodin mukaan
                  ),
                  decoration: InputDecoration(
                    hintText: 'Hae',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: _darkMode ? Colors.white : Colors.black,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 24,
                      color: _darkMode ? Colors.white70 : Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: _darkMode ? Colors.white : Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                  cursorColor: _darkMode ? Colors.white : Colors.black,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showFilterDialog(),
                      icon: Icon(Icons.filter_list),
                      label: Text("Suodattimet"),
                      style: ElevatedButton.styleFrom(
                        iconColor: _darkMode ? Colors.white : Colors.black, // Ikonin väri riippuu moodista
                        backgroundColor: _darkMode ? Colors.orange[900] : Colors.orange[300], // Napin väri riippuu moodista
                        foregroundColor: _darkMode ? Colors.white : Colors.black, // Tekstin väri riippuu moodista
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                    ),
                  ],
                )
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
                  margin: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                  // Taskin väri vaihtuu vihertäväksi riippuen onko sitä painettu
                  // Korttien default taustaväri riippuu moodista
                  color: task['done'] ? Color(0xFF73E19F) : (_darkMode ? Colors.grey[600] : Colors.white),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    onTap: () => _toggleTaskDone(index),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task['priority']),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      task['tehtava'],
                      style: TextStyle(
                        fontSize: 20,
                        decoration: task['done']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationThickness: 1,
                        color: task['done'] ? Color(0xFF696868) : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      _formatDate(task['paivamaara']),
                      style: TextStyle(
                        fontSize: 16,
                        decoration: task['done']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationThickness: 1,
                        color: task['done'] ? Color(0xFF696868) : Colors.black,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, size: 24),
                          onPressed: () => _editTask(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 24),
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


      // Uuden tehtävän lisäys
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAndAddTask,
        icon: Icon(Icons.add, color: _darkMode ? Colors.white : Colors.black), // Ikoni moodin mukaan
        backgroundColor: _darkMode ? Colors.orange[900] : Colors.orange[300], // Väri riippuu moodista
        label: Text('Lisää tehtävä',
            style: TextStyle(color: _darkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
