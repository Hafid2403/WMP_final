import 'package:flutter/material.dart';

import 'enrollment.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EnrollmentPage()),
            );
          },
          child: Text('Go to Enrollment Page'),
        ),
      ),
    );
  }
}
