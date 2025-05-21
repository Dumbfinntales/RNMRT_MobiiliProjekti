import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Kirjasto päivämäärän muotoiluun

// Näytön luokka uuden tehtävän lisäämiseen tai olemassa olevan muokkaamiseen
class AddTaskScreen extends StatefulWidget {
  final String? alkuperainenTehtava;       // Mahdollinen aiempi tehtäväteksti muokkauksessa
  final DateTime? alkuperainenPaivamaara;  // Mahdollinen aiempi päivämäärä muokkauksessa
  final String? alkuperainenPrioriteetti;  // Mahdollinen aiempi prioriteetti muokkauksessa

  AddTaskScreen({
    this.alkuperainenTehtava,
    this.alkuperainenPaivamaara,
    this.alkuperainenPrioriteetti,
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
              primary: Color(0xFF4395F9), // Oletus violetti väri siniseksi
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
              primary: Color(0xFF4395F9),
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
    return DateFormat('dd-MM-yyyy HH:mm').format(full);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alkuperainenTehtava == null ? 'Lisää tehtävä' : 'Muokkaa tehtävää'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Päivämäärä + aika (vain luettava)
            TextField(
              controller: TextEditingController(text: formatDate()),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Päivämäärä & aika',
                border: OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Tehtävän tekstikenttä
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Tehtävä',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Prioriteetin valintavalikko (Dropdown)
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Prioriteetti',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'high', child: Text('Kiireellinen (Punainen)')),
                DropdownMenuItem(value: 'medium', child: Text('Tärkeä (Keltainen)')),
                DropdownMenuItem(value: 'low', child: Text('Ei kiireellinen (Vihreä)')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!; // Päivitetään valittu prioriteetti
                });
              },
            ),
            SizedBox(height: 20),

            // Tallenna-painike, joka palauttaa annetut tiedot takaisin edelliselle näytölle
            ElevatedButton(
              child: Text('Tallenna'),
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
      ),
    );
  }
}
