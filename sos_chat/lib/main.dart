import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency SOS',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: EmergencySosScreen(),
    );
  }
}

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {

  late SharedPreferences sharedPreferences;
  List<Map<String, String>> contactDataList = [];

  @override
  void initState() {
    super.initState();
    initialiseSharedPref();
  }

  void initialiseSharedPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadContacts();
  }

  loadContacts() async {
    List<String>? names =
        sharedPreferences.getStringList('contact_names') ?? [];
    List<String>? numbers =
        sharedPreferences.getStringList('contact_numbers') ?? [];

    setState(() {
      contactDataList = List.generate(names.length, (index) {
        return {'name': names[index], 'number': numbers[index]};
      });
    });
  }

  addContacts(String name, String number) async {
    setState(() {
      contactDataList.add({'name': name, 'number': number});
    });

    List<String> names =
    contactDataList.map((contact) => contact['name']!).toList();
    List<String> numbers =
    contactDataList.map((contact) => contact['number']!).toList();

    await sharedPreferences.setStringList('contact_names', names);
    await sharedPreferences.setStringList('contact_numbers', numbers);
  }

  showAddContactDialog() {
    String name = '';
    String number = '';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          title: const Text('Add New Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    labelText: "Enter Name",
                    prefixIcon: const Icon(Icons.person),
                    contentPadding: const EdgeInsets.all(10)),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .015),
              TextFormField(
                keyboardType: TextInputType.phone,
                onChanged: (value) => number = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    labelText: "Enter Number",
                    prefixIcon: const Icon(Icons.phone_rounded),
                    contentPadding: const EdgeInsets.all(10)),
              ),

            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty &&
                    number.isNotEmpty &&
                    contactDataList.length < 3) {
                  addContacts(name, number);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  deleteContact(int index) async {
    setState(() {
      contactDataList.removeAt(index);
    });

    List<String> names =
    contactDataList.map((contact) => contact['name']!).toList(); // Corrected 'name' key access
    List<String> numbers =
    contactDataList.map((contact) => contact['number']!).toList(); // Corrected 'number' key access

    await sharedPreferences.setStringList('contact_names', names);
    await sharedPreferences.setStringList('contact_numbers', numbers);
  }

  showDeleteContactDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            title: const Text('Delete Contact'),
            content:
            const Text('Are you sure you want to delete this contact?'),
            actions: [
              TextButton(
                  onPressed: () {
                    deleteContact(index);
                    Navigator.pop(context);
                  },
                  child: const Text("Delete")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"))
            ],
          );
        });
  }

  callNumber(number) async {
    await FlutterPhoneDirectCaller.callNumber("+91$number");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7F9),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image:
                        const AssetImage('assets/image/shield_check.png'),
                        height: MediaQuery.of(context).size.height * .04,
                        width: MediaQuery.of(context).size.width * .08,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * .028),
                      const Text(
                        'Emergency SOS',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .06),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: const Color(0xffE8E8E8),
                    ),
                    height: MediaQuery.of(context).size.height * .062,
                    width: MediaQuery.of(context).size.width * .65,
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4.5),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.local_hospital_outlined,
                                size: 30, color: Colors.red),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * .09),
                        const Text(
                          "Call Ambulance",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .022),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: const Color(0xffE8E8E8),
                    ),
                    height: MediaQuery.of(context).size.height * .062,
                    width: MediaQuery.of(context).size.width * .65,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: InkWell(
                            onTap: () {
                              FlutterPhoneDirectCaller.callNumber(
                                  '+917058779253');
                            },
                            child: const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              backgroundImage:
                              AssetImage('assets/image/sos.png'),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * .09),
                        const Text(
                          "Emergency Call",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .017),
                  const Text(
                    'Swipe to call Emergency Service',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .032),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * .31,
                      width: MediaQuery.of(context).size.width * .65,
                      child: ListView.builder(
                          itemCount: contactDataList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                showDeleteContactDialog(index);
                              },
                              onTap: () {
                                // call method callNumber()
                                callNumber(contactDataList[index]['number']!);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    color: const Color(0xffE8E8E8)),
                                height: MediaQuery.of(context).size.height * .062,
                                width: MediaQuery.of(context).size.width * .65,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4.5),
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.phone_outlined,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width: MediaQuery.of(context).size.width * .15),
                                    Text(
                                      contactDataList[index]['name']!,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300),
                                    )
                                  ],
                                ),
                              ),
                            );
                          })),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: TextButton(
                        onPressed: () {
                          if (contactDataList.length > 2) {
                            Get.snackbar('Alert!',
                                "You can't add more than 3 Emergency Contacts");
                          } else {
                            showAddContactDialog();
                          }
                        },
                        child: const Icon(Icons.add_call, size: 60)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}