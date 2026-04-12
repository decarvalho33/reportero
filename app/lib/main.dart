import 'package:flutter/material.dart';

void main() => runApp(const ReporteroApp());

class ReporteroApp extends StatelessWidget {
  const ReporteroApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unicamp Safety',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const ReportForm(),
    );
  }
}

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});
  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Denúncia')),
      body: const Center(child: Text('Formulário em construção...')),
    );
  }
}