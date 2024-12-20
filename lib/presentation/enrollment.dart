import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wmp_2/presentation/savefile.dart';

class EnrollmentPage extends StatefulWidget {
  @override
  _EnrollmentPageState createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _selectedSubjects = [];
  int _totalCredits = 0;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('subjects').get();
    setState(() {
      _subjects = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'credits': doc['credits'],
              })
          .toList();
    });
  }

  void _toggleSubject(Map<String, dynamic> subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
        _totalCredits -= (subject['credits'] as num).toInt();
      } else {
        if (_totalCredits + (subject['credits'] as num).toInt() <= 24) {
          _selectedSubjects.add(subject);
          _totalCredits += (subject['credits'] as num).toInt();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Credit limit exceeded!')),
          );
        }
      }
    });
  }

  Future<void> saveEnrollment() async {
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No subjects selected for enrollment!')),
      );
      return;
    }
    await FirebaseFirestore.instance.collection('enrollments').add({
      'subjects': _selectedSubjects,
      'totalCredits': _totalCredits,
      'timestamp': Timestamp.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enrollment saved successfully!')),
    );
  }

  Future<void> _addSubject() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController creditsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Subject Name'),
            ),
            TextField(
              controller: creditsController,
              decoration: InputDecoration(labelText: 'Credits'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String name = nameController.text.trim();
              int credits = int.tryParse(creditsController.text.trim()) ?? 0;

              if (name.isEmpty || credits <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid input!')),
                );
                return;
              }

              await FirebaseFirestore.instance.collection('subjects').add({
                'name': name,
                'credits': credits,
              });
              Navigator.pop(context);
              fetchSubjects();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Subject added successfully!')),
              );
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrollment Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addSubject,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _subjects.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _subjects.length,
                    itemBuilder: (context, index) {
                      final subject = _subjects[index];
                      final isSelected = _selectedSubjects.contains(subject);

                      return ListTile(
                        title: Text(subject['name']),
                        subtitle: Text('${subject['credits']} Credits'),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            _toggleSubject(subject);
                          },
                        ),
                        onTap: () {
                          _toggleSubject(subject);
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Credits: $_totalCredits / 24',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnrollmentResultPage(),
                    ));
              },
              child: Text('Go to See Result')),
          ElevatedButton(
            onPressed: saveEnrollment,
            child: Text('Save Enrollment'),
          ),
        ],
      ),
    );
  }
}
