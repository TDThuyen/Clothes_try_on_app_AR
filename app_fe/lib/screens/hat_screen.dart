import 'package:flutter/material.dart';

class HatScreen extends StatelessWidget {
  const HatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Áo'), backgroundColor: Colors.black),
      body: const Center(child: Text('Danh sách Áo')),
    );
  }
}
