import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  runApp(MyMedsApp());
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await NotificationService.init();

//   await FlutterLocalNotificationsPlugin()
//       .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin
//       >()
//       ?.requestNotificationsPermission();

//   final androidPlugin = FlutterLocalNotificationsPlugin()
//       .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin
//       >();

//   await androidPlugin?.requestNotificationsPermission();

//   await androidPlugin?.requestExactAlarmsPermission();

//   runApp(MyMedsApp());
// }

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
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  int selectedIndex = 0;

  final nameController = TextEditingController();
  final dosageController = TextEditingController();

  String selectedTime = "";

  String profileName = "";

  List<Map<String, String>> medications = [];

  @override
  void initState() {
    super.initState();
    loadMedications();
    loadProfileName();
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

  void saveMedication() async {
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
      });

      nameController.clear();
      dosageController.clear();
      selectedTime = "";
    });

    await persistMedications();
  }

  void loadMedications() async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList('meds');

    if (list != null) {
      setState(() {
        medications = list
            .map((e) => Map<String, String>.from(jsonDecode(e)))
            .toList();
      });
    }
  }

  Future<void> persistMedications() async {
    final prefs = await SharedPreferences.getInstance();

    final list = medications.map((e) => jsonEncode(e)).toList();

    await prefs.setStringList('meds', list);
  }

  Future<void> saveProfileName() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profileName', profileName);
  }

  Future<void> loadProfileName() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      profileName = prefs.getString('profileName') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomePage(),
      buildProfilePage(),

      buildMedicationPage(),

      buildHistoryPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: "Meds"),

          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// APP NAME
              const Center(
                child: Text(
                  "MyMeds",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// GREETING
              Text(
                "Welcome to Mymeds 👋",
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 5),

              Text(
                profileName.isEmpty ? "John!" : "$profileName!",

                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              /// CARD
              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6AD), Color(0xFF009E90)],
                  ),

                  borderRadius: BorderRadius.circular(25),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: const [
                        Text(
                          "Stay Healthy",
                          style: TextStyle(color: Colors.white70),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Never Miss\nYour Medication",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Icon(
                        Icons.medication,
                        color: Colors.teal,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Today's Reminder",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),
              reminderTile(Icons.wb_sunny, "Morning Medication", Colors.orange),

              reminderTile(Icons.wb_twilight, "Noon Medication", Colors.amber),

              reminderTile(
                Icons.light_mode,
                "Afternoon Medication",
                Colors.deepOrange,
              ),

              reminderTile(Icons.sunny, "Evening Medication", Colors.teal),

              reminderTile(
                Icons.nights_stay,
                "Night Medication",
                Colors.indigo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget reminderTile(IconData icon, String title, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 15),

          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget buildProfilePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 40),

            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,

              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),

            const SizedBox(height: 20),

            const Text(
              "Profile",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            TextField(
              onChanged: (value) async {
                setState(() {
                  profileName = value;
                });

                await saveProfileName();
              },
              decoration: InputDecoration(
                labelText: "Enter Your Name",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMedicationPage() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Center(
                child: Text(
                  "MyMeds",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: nameController,

                decoration: InputDecoration(
                  labelText: "Medication Name",

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: dosageController,

                decoration: InputDecoration(
                  labelText: "Dosage",

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: pickTime,

                      icon: const Icon(Icons.access_time),

                      label: Text(
                        selectedTime.isEmpty ? "Select Time" : selectedTime,
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: saveMedication,

                      icon: const Icon(Icons.save),

                      label: const Text("Save Medication"),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();

                        await prefs.remove('meds');

                        setState(() {
                          medications.clear();
                        });
                      },

                      icon: const Icon(Icons.delete),

                      label: const Text("Clear Medications"),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "Medication Schedule",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: medications.length,

                itemBuilder: (context, index) {
                  final med = medications[index];

                  return medicationCard(med);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget medicationCard(Map<String, String> med) {
    final name = med["name"] ?? "";
    final dosage = med["dosage"] ?? "";
    final time = med["time"] ?? "";

    IconData icon = Icons.wb_sunny;
    Color color = Colors.orange;
    String period = "Morning";

    final hour = int.tryParse(time.split(":")[0]) ?? 0;

    final isPM = time.contains("PM");
    if (!isPM && hour >= 5 && hour < 12) {
      period = "Morning";
      icon = Icons.wb_sunny;
      color = Colors.orange;
    } else if (isPM && hour == 12) {
      period = "Noon";
      icon = Icons.wb_twilight;
      color = Colors.amber;
    } else if (isPM && hour >= 1 && hour < 5) {
      period = "Afternoon";
      icon = Icons.light_mode;
      color = Colors.deepOrange;
    } else if (isPM && hour >= 5 && hour < 8) {
      period = "Evening";
      icon = Icons.sunny;
      color = Colors.teal;
    } else {
      period = "Night";
      icon = Icons.nights_stay;
      color = Colors.indigo;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "$dosage • $time",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                ),

                const SizedBox(height: 8),

                Text(
                  period,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const SizedBox(height: 12),

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

                if (med["status"] == "pending")
                  Text(
                    "PENDING",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          med["status"] = "taken";
                        });

                        await persistMedications();
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: const Text(
                          "Taken",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          med["status"] = "missed";
                        });

                        await persistMedications();
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: const Text(
                          "Missed",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHistoryPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            const Text(
              "Medication History",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: medications.isEmpty
                  ? const Center(
                      child: Text(
                        "No Medication History",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: medications.length,

                      itemBuilder: (context, index) {
                        final med = medications[index];

                        Color statusColor = Colors.orange;

                        if (med["status"] == "taken") {
                          statusColor = Colors.green;
                        }

                        if (med["status"] == "missed") {
                          statusColor = Colors.red;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),

                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),

                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(15),
                                ),

                                child: Icon(
                                  Icons.medication,
                                  color: statusColor,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      med["name"] ?? "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text("${med["dosage"]} • ${med["time"]}"),

                                    const SizedBox(height: 8),

                                    Text(
                                      "Status: ${med["status"]?.toUpperCase() ?? "PENDING"}",

                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
