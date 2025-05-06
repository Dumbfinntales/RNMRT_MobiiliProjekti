import 'package:flutter/material.dart';

class AddTaskScreen extends StatelessWidget {
  final String? alkuperainenTehtava; // Valinnainen alkuperäinen tehtävä, jos muokataan

  AddTaskScreen({this.alkuperainenTehtava}); // Alkuperäinen tehtävä voidaan siirtää tähän

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller =
        TextEditingController(text: alkuperainenTehtava ?? ''); // Jos alkuperäinen tehtävä on olemassa, täytä kenttä

    return Scaffold(
      appBar: AppBar(
        title: Text(alkuperainenTehtava == null ? 'Lisää tehtävä' : 'Muokkaa tehtävää'), // Näytetään teksti sen mukaan, onko kyseessä lisäys vai muokkaus
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller, // Käytetään kontrolleria tekstin syöttämiseen
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Tehtävä', // Kentän selite
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Tallenna'),
              onPressed: () {
                Navigator.pop(context, _controller.text); // Sulkee ruudun ja lähettää syötetyn tekstin takaisin
              },
            ),
          ],
        ),
      ),
    );
  }
}
