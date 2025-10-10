import 'package:flutter/material.dart';
import 'package:advanced_dropdown/advanced_dropdown.dart';

class AdvancedDropdownDemo extends StatefulWidget {
  const AdvancedDropdownDemo({super.key});

  @override
  State<AdvancedDropdownDemo> createState() => _AdvancedDropdownDemoState();
}

class _AdvancedDropdownDemoState extends State<AdvancedDropdownDemo> {
  // Example data sources
  final List<Map<String, dynamic>> techList = [
    {'id': 1, 'name': 'Flutter'},
    {'id': 2, 'name': 'React'},
    {'id': 3, 'name': 'Vue'},
    {'id': 4, 'name': 'Angular'},
  ];

  final List<String> countryList = [
    'Bangladesh',
    'India',
    'USA',
    'Canada',
    'Germany',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Advanced Dropdown Example")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Single Select (with API data)
            const Text("Single Select (API data)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AdvancedDropdown(
              items: techList,
              displayField: 'name',
              valueField: 'id',
              initialValue: 2,
              onChanged: (value) {
                debugPrint("Selected ID: $value");
              },
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              selectedTextStyle: const TextStyle(fontSize: 15, color: Colors.black87),
            ),

            const SizedBox(height: 25),

            /// 🔹 Multi Select with Chips + Max Limit
            const Text("Multi Select with Chips & Limit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AdvancedDropdown(
              items: techList,
              displayField: 'name',
              valueField: 'id',
              isMultiSelect: true,
              isSearch: true,
              maxSelection: 3,
              initialValues: [1, 3], // preselected (backend)
              chipColor: Colors.blue.shade100,
              chipTextStyle: const TextStyle(color: Colors.black),
              onChanged: (values) {
                debugPrint("Selected IDs: $values");
              },
              dropdownDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              icon: const Icon(Icons.expand_more, color: Colors.blue),
            ),

            const SizedBox(height: 25),

            /// 🔹 String List (simple dropdown)
            const Text("Simple String List", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AdvancedDropdown(
              items: countryList,
              isSearch: true,
              hintText: "Select a country",
              onChanged: (value) {
                debugPrint("Selected Country: $value");
              },
              inputDecoration: const InputDecoration(
                hintText: 'Search country...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              selectedTextStyle: const TextStyle(color: Colors.black87, fontSize: 15),
            ),

            const SizedBox(height: 25),

            // 🔹 Custom Styled Multi Select
            const Text("Custom Styled Dropdown", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AdvancedDropdown(
              items: techList,
              displayField: 'name',
              valueField: 'id',
              isMultiSelect: true,
              isSearch: true,
              chipColor: Colors.teal.shade100,
              chipTextStyle: const TextStyle(color: Colors.teal),
              maxSelection: 4,
              inputDecoration: const InputDecoration(
                hintText: 'Search technologies...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (values) {
                debugPrint("Selected Technologies: $values");
              },
            ),
          ],
        ),
      ),
    );
  }
}