import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_signature_module/home.dart';

void main() => runApp(const MyApp());

/// The main application widget.
class MyApp extends StatelessWidget {
  /// The main application widget.
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signature Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const Home(),
    );
  }
}
