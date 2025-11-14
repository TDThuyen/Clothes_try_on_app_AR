import 'package:flutter/material.dart';

class TrouserScreen extends StatelessWidget {
  const TrouserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quần'), backgroundColor: Colors.black),
      body: const Center(child: Text('Danh sách Quần')),
    );
  }
}
