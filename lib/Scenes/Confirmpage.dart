import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ConfirmPage extends StatelessWidget {
  final List<Map<String, dynamic>> selectedItems;
  final VoidCallback onConfirm;
  final Map<String, Map<String, double>> ingredientCounts;
  final File countFile;

  const ConfirmPage({super.key, 
    required this.selectedItems,
    required this.onConfirm,
    required this.ingredientCounts,
    required this.countFile,
  });

  Future<void> _decreaseIngredients(List<Map<String, dynamic>> selectedItems, Map<String, Map<String, double>> ingredientCounts, File countFile) async {
    final String currentDate = DateTime.now().toIso8601String().split('T').first;

    for (var item in selectedItems) {
      for (var ingredient in item['ingredients'].entries) {
        final ingredientId = ingredient.key;
        final requiredQuantity = ingredient.value * item['count'];

        print('Decreasing ingredient: $ingredientId by $requiredQuantity');
        if (ingredientCounts.containsKey(ingredientId)) {
          if (ingredientCounts[ingredientId]!.containsKey(currentDate)) {
            ingredientCounts[ingredientId]![currentDate] =
                (ingredientCounts[ingredientId]![currentDate] ?? 0) - requiredQuantity;
          } else {
            // Create a new entry for currentDate
            ingredientCounts[ingredientId]![currentDate] = -requiredQuantity;
          }
        } else {
          // Create a new entry for ingredientId and currentDate
          ingredientCounts[ingredientId] = {currentDate: -requiredQuantity};
        }
      }
    }

    await _saveCountsToFile(ingredientCounts, countFile);
  }

  Future<void> _saveCountsToFile(Map<String, Map<String, double>> ingredientCounts, File countFile) async {
    final jsonData = ingredientCounts.map((key, value) => MapEntry(key, value.map((k, v) => MapEntry(k, v))));
    await countFile.writeAsString(json.encode(jsonData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ยืนยันการสั่งอาหาร'),
        backgroundColor: const Color.fromARGB(255, 199, 232, 213),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: selectedItems.length,
                itemBuilder: (context, index) => Card(
                  key: ValueKey(selectedItems[index]["id"]),
                  color: Colors.grey[200],
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Image.asset(
                          selectedItems[index]["picture"],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedItems[index]['name'],
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'จำนวน: ${selectedItems[index]["count"].toString()} จาน',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Reset the counts
                  for (var item in selectedItems) {
                    item['count'] = 0;
                  }

                  // Call the onConfirm callback
                  onConfirm();

                  // Decrease ingredient counts
                  await _decreaseIngredients(selectedItems, ingredientCounts, countFile);

                  // Navigate back to the MenuPage
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor:
                      const Color.fromARGB(255, 199, 232, 213), // Button color
                ),
                child: const Text(
                  'ยืนยัน',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
