import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Päivämäärä paketti

class AddTaskScreen extends StatefulWidget {
  final String? alkuperainenTehtava; // Valinnainen alkuperäinen tehtävä, jos muokataan
  final DateTime? alkuperainenPaivamaara; // Valinnainen alkuperäinen päivämäärä

  AddTaskScreen({this.alkuperainenTehtava, this.alkuperainenPaivamaara}); // Alkuperäinen tehtävä ja päivämäärä voidaan siirtää tähän

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.alkuperainenTehtava ?? ''; // Jos alkuperäinen tehtävä on olemassa, täytä kenttä
    _selectedDate = widget.alkuperainenPaivamaara ?? DateTime.now(); // Jos alkuperäinen päivämäärä on olemassa, käytä sitä, muuten kuluva päivä
  }

  // Funktio, joka avaa kalenterin
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      // Kalenterin vuosi rajat
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Päivitä valittu päivämäärä
      });
    }
  }

  // Funktio päivämäärän muotoiluun
  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date); // Päivämäärän muotoilu dd-MM-yyyy
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alkuperainenTehtava == null ? 'Lisää tehtävä' : 'Muokkaa tehtävää'), // Näytetään teksti sen mukaan, onko kyseessä lisäys vai muokkaus
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Päivämääräkenttä
            TextField(
              controller: TextEditingController(
                  text: formatDate(_selectedDate!)), // Näytetään valittu päivä
              readOnly: true, // Ei muokattavissa
              decoration: InputDecoration(
                labelText: 'Päivämäärä',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  // Iconi kalenterin aavaamiseen
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context), 
                ),
              ),
            ),
            SizedBox(height: 20),
            // Tehtäväkenttä
            TextField(
              controller: _controller, // Käytetään kontrolleria tekstin syöttämiseen
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Tehtävä',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Tallenna-painike
            ElevatedButton(
              child: Text('Tallenna'),
              onPressed: () {
                Navigator.pop(context, {
                  'tehtava': _controller.text,
                  'paivamaara': _selectedDate,
                }); // Sulkee ruudun ja lähettää tehtävän tekstin sekä päivämäärän takaisin
              },
            ),
          ],
        ),
      ),
    );
  }
}
