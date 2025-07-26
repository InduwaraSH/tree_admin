import 'package:flutter/material.dart';

class enterDetail extends StatefulWidget {
  const enterDetail({super.key});

  @override
  State<enterDetail> createState() => _EnterDetailsState();
}

class _EnterDetailsState extends State<enterDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Details')),
      body: const Center(child: Text('Details Entry Form Goes Here')),
    );
  }
}
