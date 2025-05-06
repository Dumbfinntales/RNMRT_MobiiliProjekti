import 'package:flutter/material.dart';

// AddTaskScreen on erillinen ruutu, jossa voi syöttää tehtäviä, lisätä ne listaan tai liikkua taaksepäin
class AddTaskScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lisää tehtävä')),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Tehtävän nimi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Tallenna nappi
            ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: Text('Tallenna tehtävä'),
              onPressed: () {
                final newTask = _controller.text;
                Navigator.pop(context, newTask); // Palauttaa uuden tehtävän kotiruudulle
                // Jos käyttäjä ei syötä mitään, ei tehdä mitään
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}