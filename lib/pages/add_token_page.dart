import 'package:flutter/material.dart';

class AddTokenPage extends StatelessWidget {
  const AddTokenPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Token')),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
