import 'package:flutter/material.dart';

class ShirtScreen extends StatelessWidget {
  const ShirtScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Áo'), backgroundColor: Colors.black),
      body: const Center(child: Text('Danh sách Áo')),
    );
  }
}
