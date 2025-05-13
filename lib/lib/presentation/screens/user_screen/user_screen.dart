import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text('UN', style: TextStyle(fontSize: 30)),
            ),
            SizedBox(height: 20),
            Text('User Name', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('user@example.com'),
          ],
        ),
      ),
    );
  }
}
