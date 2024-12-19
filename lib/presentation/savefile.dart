import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enrollment Results')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('enrollments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No enrollments found.'));
          }
          final enrollments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: enrollments.length,
            itemBuilder: (context, index) {
              final enrollment = enrollments[index];
              final subjects = List<Map<String, dynamic>>.from(
                enrollment['subjects'],
              );
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Enrollment ${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...subjects.map((subject) => Text(
                          '${subject['name']} (${subject['credits']} Credits)')),
                      SizedBox(height: 8.0),
                      Text(
                        'Total Credits: ${enrollment['totalCredits']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
