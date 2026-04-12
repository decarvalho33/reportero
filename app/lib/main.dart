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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Denúncia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título da Ocorrência'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descrição detalhada'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {}, // Ainda sem ação
                child: const Text('Enviar Denúncia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}