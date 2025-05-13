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
  DateTime? _selectedDate;             // Valittu päivämäärä
  String _selectedPriority = 'medium'; // Oletusprioriteetti on "medium" (keltainen)

  @override
  void initState() {
    super.initState();
    // Alustetaan tekstikenttä ja muut arvot muokkaustilanteessa
    _controller.text = widget.alkuperainenTehtava ?? '';
    _selectedDate = widget.alkuperainenPaivamaara ?? DateTime.now();
    _selectedPriority = widget.alkuperainenPrioriteetti ?? 'medium';
  }

  // Funktio päivämäärän valintaan kalenterin kautta
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Muotoilee päivämäärän dd-MM-yyyy -muotoon
  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Näytön otsikko riippuen siitä, onko kyseessä lisäys vai muokkaus
        title: Text(widget.alkuperainenTehtava == null ? 'Lisää tehtävä' : 'Muokkaa tehtävää'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Päivämääräkenttä (vain luettava), jossa on kalenteripainike
            TextField(
              controller: TextEditingController(text: formatDate(_selectedDate!)),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Päivämäärä',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
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
                Navigator.pop(context, {
                  'tehtava': _controller.text,
                  'paivamaara': _selectedDate,
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
