import 'package:advanced_dropdown/advanced_dropdown.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Dropdown Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Dropdown Example')),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: ExampleDropdown(),
        ),
      ),
    );
  }
}

class ExampleDropdown extends StatefulWidget {
  const ExampleDropdown({super.key});

  @override
  State<ExampleDropdown> createState() => _ExampleDropdownState();
}

class _ExampleDropdownState extends State<ExampleDropdown> {
  String? defaultSelected;
  String? singleSelected;
  List<String> multiSelected = [];
  String? decoratedSelected;
  List<String> searchSelected = [];

  final fruits = [
    'Apple',
    'Banana',
    'Orange',
    'Mango',
    'Pineapple',
    'Grapes',
    'Kiwi',
    'Strawberry',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Dropdown Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('1️⃣ Default Dropdown (single select)'),
            CustomDropdown(
              items: fruits,
              onChanged: (value) => setState(() => defaultSelected = value),
            ),


            const Text('2️⃣ Single Select Dropdown'),
            CustomDropdown(
              items: fruits,
              onChanged: (value) => setState(() => singleSelected = value),
            ),


            const Text('3️⃣ Multi Select Dropdown'),
            CustomDropdown(
              items: fruits,
              isMultiSelect: true,
              onChanged: (values) => setState(() => multiSelected = List<String>.from(values)),
            ),
            
            
            const Text('4️⃣ Searchable Dropdown (single)'),
            CustomDropdown(
              items: fruits,
              isSearch: true,
              onChanged: (value) => setState(() => decoratedSelected = value),
            ),
            
            
            const Text('5️⃣ Searchable Dropdown (multi)'),
            CustomDropdown(
              items: fruits,
              isSearch: true,
              isMultiSelect: true,
              onChanged: (values) => setState(() => searchSelected = List<String>.from(values)),
            ),
            
            
            const Text('6️⃣ Custom Decorated Dropdown'),
            CustomDropdown(
              items: fruits,
              isSearch: true,
              isMultiSelect: true,
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple, width: 2),
              ),
              dropdownDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              inputDecoration: const InputDecoration(
                hintText: 'Search fruits...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (values) => setState(() => searchSelected = List<String>.from(values)),
            ),
            
           
          ],
        ),
      ),
    );
  }
}