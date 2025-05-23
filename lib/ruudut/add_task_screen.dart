import 'package:flutter/material.dart'; // Flutterin widgetit
import 'package:intl/intl.dart'; // Kirjasto päivämäärän muotoiluun

// Näytön luokka uuden tehtävän lisäämiseen tai olemassa olevan muokkaamiseen
class AddTaskScreen extends StatefulWidget {
  final String? alkuperainenTehtava;       // Mahdollinen aiempi tehtäväteksti muokkauksessa
  final DateTime? alkuperainenPaivamaara;  // Mahdollinen aiempi päivämäärä muokkauksessa
  final String? alkuperainenPrioriteetti;  // Mahdollinen aiempi prioriteetti muokkauksessa
  final bool darkMode; // Seuraa darkModen muutosta homeScreenistä

  AddTaskScreen({ // Muuttujat alkuperäiselle tehtävälle, päivämäärälle ja prioriteetille
    this.alkuperainenTehtava,
    this.alkuperainenPaivamaara,
    this.alkuperainenPrioriteetti,
    required this.darkMode,
  });

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _controller = TextEditingController(); // Tekstikentän ohjain
  DateTime? _selectedDate;  // Valittu päivämäärä
  TimeOfDay? _selectedTime; // Valittu kellonaika
  String _selectedPriority = 'medium'; // Oletusprioriteetti on "medium" (keltainen)

  @override
  void initState() {
    super.initState();
    // Alustetaan tekstikenttä ja muut arvot muokkaustilanteessa
    _controller.text = widget.alkuperainenTehtava ?? '';
    _selectedDate = widget.alkuperainenPaivamaara ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(widget.alkuperainenPaivamaara ?? DateTime.now());
    _selectedPriority = widget.alkuperainenPrioriteetti ?? 'medium';
  }

  // Funktio päivämäärän valintaan kalenterin kautta
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Color(0xFF444444), // Väri
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Funktio jolla valitaan aika
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Color(0xFF444444),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Muotoilee päivämäärän dd-MM-yyyy -muotoon ja lisää kellonajan samaan merkkijonoon
  String formatDate() {
    final date = _selectedDate!;
    final time = _selectedTime!;
    final full = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat('dd.MM.yyyy HH:mm').format(full);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Taustaväri muuttuu riippuen moodista
      backgroundColor: widget.darkMode ? Color.fromARGB(200, 0, 0, 0) : Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: widget.darkMode ? Color.fromARGB(20, 0, 0, 0) : Color(0xFFF5F5F5),
        iconTheme: IconThemeData(
          color: widget.darkMode ? Colors.white : Colors.black, // Takaisin-nuolen väri
        ),
        title: Text(widget.alkuperainenTehtava == null ? 'Lisää tehtävä' : 'Muokkaa tehtävää',
          style: TextStyle( // Muuttaa otsikon värin riippuen moodista
            color: widget.darkMode ? Colors.white : Colors.black
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        child:SingleChildScrollView(
        child: Column(
          children: [
            // Päivämäärä + aika (vain luettava)
            TextField(
              controller: TextEditingController(text: formatDate()),
              readOnly: true,
              // Tekstikentän väri muuttuu riippuen moodista
              style: TextStyle(
                color: widget.darkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Päivämäärä & aika',
                floatingLabelStyle: TextStyle(color: widget.darkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: widget.darkMode ? Colors.white70 : Colors.black54,),
                      onPressed: () => _selectDate(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.access_time, color: widget.darkMode ? Colors.white70 : Colors.black54,),
                      onPressed: () => _selectTime(context),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Prioriteetin valintavalikko (Dropdown)
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              dropdownColor: widget.darkMode ? Colors.black : Colors.white,
              // Tekstikentän väri muuttuu riippuen moodista
              style: TextStyle(
                color: widget.darkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Prioriteetti',
                floatingLabelStyle: TextStyle(color: widget.darkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'high',
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(0xFFE6564C),
                          shape: BoxShape.circle, // Pallo
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Kiireellinen'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(0xFFFEDA7A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Tärkeä'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'low',
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(0xFFA2E8BE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Ei kiireellinen'),
                    ],
                  ),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!; // Päivitetään valittu prioriteetti
                });
              },
            ),
            SizedBox(height: 20),

            // Tehtävän tekstikenttä
            TextField(
              controller: _controller,
              autofocus: true,
              // Tekstikentän väri muuttuu riippuen moodista
              style: TextStyle(
                color: widget.darkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Tehtävä',
                floatingLabelStyle: TextStyle(color: widget.darkMode ? Colors.white : Colors.black),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: widget.darkMode ? Colors.white : Colors.black, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Tallenna-painike, joka palauttaa annetut tiedot takaisin edelliselle näytölle
            ElevatedButton(
              style: ElevatedButton.styleFrom( // Värit muuttuvat riippuen moodista
                backgroundColor: widget.darkMode ? Colors.orange[900] : Colors.orange[300],
                foregroundColor: widget.darkMode ? Colors.white : Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Tallenna',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                final fullDateTime = DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                  _selectedTime!.hour,
                  _selectedTime!.minute,
                );

                Navigator.pop(context, {
                  'tehtava': _controller.text,
                  'paivamaara': fullDateTime,
                  'priority': _selectedPriority,
                  'done': false,
                });
              },
            ),
          ],
        ),
      ),)

    );
  }
}
