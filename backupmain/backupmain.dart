import 'package:flutter/material.dart';

void main() {
  runApp(MyMedsApp());
}

class MyMedsApp extends StatelessWidget {
  const MyMedsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddMedicationScreen(),
    );
  }
}

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

///////////////new added code/////////////
class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();

  String selectedTime = "";

  List<Map<String, String>> medications = [];

  Map<String, List<Map<String, String>>> groupMedications() {
    Map<String, List<Map<String, String>>> grouped = {
      "Morning": [],
      "Noon": [],
      "Afternoon": [],
      "Evening": [],
      "Night": [],
    };

    for (var med in medications) {
      final time = med["time"]!;

      final hour = int.tryParse(time.split(":")[0]) ?? 0;
      final isPM = time.contains("PM");

      if (!isPM && hour >= 5 && hour < 12) {
        grouped["Morning"]!.add(med);
      } else if (isPM && hour == 12) {
        grouped["Noon"]!.add(med);
      } else if (isPM && hour < 5) {
        grouped["Afternoon"]!.add(med);
      } else if (isPM && hour < 8) {
        grouped["Evening"]!.add(med);
      } else {
        grouped["Night"]!.add(med);
      }
    }

    return grouped;
  }

  ////////////////end//////////////////////////
  void saveMedication() {
    if (nameController.text.isEmpty ||
        dosageController.text.isEmpty ||
        selectedTime.isEmpty) {
      return;
    }

    setState(() {
      medications.add({
        "name": nameController.text,
        "dosage": dosageController.text,
        "time": selectedTime,
        "status": "pending",
      });

      nameController.clear();
      dosageController.clear();
      selectedTime = "";
    });
  }

  void pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MyMeds"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Medication Name"),
            ),
            TextField(
              controller: dosageController,
              decoration: InputDecoration(labelText: "Dosage"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickTime,
              child: Text(selectedTime.isEmpty ? "Select Time" : selectedTime),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveMedication,
              child: Text("Save Medication"),
            ),
            SizedBox(height: 20),

            /// LIST
            Expanded(
              child: ListView(
                children: groupMedications().entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      ...entry.value.map((med) {
                        return Card(
                          child: ListTile(
                            title: Text(med["name"]!),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${med["dosage"]} • ${med["time"]}"),

                                if (med["status"] == "taken")
                                  Text(
                                    "TAKEN",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (med["status"] == "missed")
                                  Text(
                                    "MISSED",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      med["status"] = "taken";
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Taken",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      med["status"] = "missed";
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Missed",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
