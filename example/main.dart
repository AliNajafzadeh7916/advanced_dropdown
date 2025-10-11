import 'package:flutter/material.dart';
import 'package:advanced_dropdown/advanced_dropdown.dart';

class AdvancedDropdownDemo extends StatefulWidget {
  const AdvancedDropdownDemo({super.key});

  @override
  State<AdvancedDropdownDemo> createState() => _AdvancedDropdownDemoState();
}

class _AdvancedDropdownDemoState extends State<AdvancedDropdownDemo> {
  // For single select
  dynamic _selectedFruit;

  // For multi select
  List<dynamic> _selectedColors = [];

  // For map-based dropdown
  dynamic _selectedCountry;
  List<dynamic> _selectedCities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Advanced Dropdown Example")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ---------------- SINGLE SELECT ----------------
            const Text(
              "Single Select Dropdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            AdvancedDropdown(
              items: ['Apple', 'Banana', 'Cherry', 'Mango', 'Orange'],
              initialValue: 'Cherry', // Preselected
              onChanged: (value) {
                setState(() => _selectedFruit = value);
              },
              hintText: "Select your favorite fruit",
              hintStyle: const TextStyle(color: Colors.grey),
              selectedTextStyle: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
              itemTextStyle: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text("Selected: ${_selectedFruit ?? "None"}"),

            const Divider(height: 40),

            /// ---------------- MULTI SELECT ----------------
            const Text(
              "Multi Select Dropdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            AdvancedDropdown(
            isSearch: true,
              items: ['Red', 'Blue', 'Green', 'Yellow', 'Black'],
              isMultiSelect: true,
              initialValues: [], // Preselected
              onChanged: (values) {
                setState(() => _selectedColors = values);
              },
              hintText: "Select colors",
              chipColor: Colors.blue.shade100,
              chipTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Selected: ${_selectedColors.join(", ")}"),

            const Divider(height: 40),

            /// ---------------- MAP BASED DROPDOWN (SINGLE) ----------------
            const Text(
              "Map-based Dropdown (Single Select)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            AdvancedDropdown(
              items: const [
                {'label': 'United States', 'value': 'US'},
                {'label': 'Bangladesh', 'value': 'BD'},
                {'label': 'India', 'value': 'IN'},
                {'label': 'Germany', 'value': 'DE'},
                {'label': 'Japan', 'value': 'JP'},
              ],
              labelBuilder: (item) => item['label'],
              valueBuilder: (item) => item['value'],
              initialValue: 'IN', // Preselected by value
              onChanged: (value) {
                setState(() => _selectedCountry = value);
              },
              hintText: "Select a country",
              selectedTextStyle: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w600,
              ),
              itemTextStyle: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text("Selected Country: ${_selectedCountry ?? "None"}"),

            const Divider(height: 40),

            /// ---------------- MAP BASED DROPDOWN (MULTI) ----------------
            const Text(
              "Map-based Dropdown (Multi Select)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            AdvancedDropdown(
              items: const [
                {'label': 'New York', 'value': 1},
                {'label': 'London', 'value': 2},
                {'label': 'Tokyo', 'value': 3},
                {'label': 'Delhi', 'value': 4},
              ],
              isMultiSelect: true,
              labelBuilder: (item) => item['label'],
              valueBuilder: (item) => item['value'],
              initialValues: [1, 4], // Preselected by value
              onChanged: (values) {
                setState(() => _selectedCities = values);
              },
              hintText: "Select cities",
              chipColor: Colors.teal.shade100,
              chipTextStyle: const TextStyle(color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Text("Selected Cities IDs: ${_selectedCities.join(", ")}"),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}