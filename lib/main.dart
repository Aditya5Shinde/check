import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ControllerName = TextEditingController();
  final ControllerExp = TextEditingController();
  bool active = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  height: 500,
                  width: 700,
                  child: StreamBuilder(
                      stream: readUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.hasError);
                          print(snapshot.error);
                          return Text('Loading');
                        } else if (snapshot.hasData) {
                          final users = snapshot.data;
                          return ListView(
                            children: users!.map(buildUser).toList(),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
              ),
              TextField(
                textAlign: TextAlign.center,
                decoration: const InputDecoration.collapsed(hintText: 'Name'),
                controller: ControllerName,
              ),
              TextField(
                textAlign: TextAlign.center,
                decoration: const InputDecoration.collapsed(hintText: 'Exp'),
                controller: ControllerExp,
              ),
              Checkbox(
                  value: active,
                  onChanged: (bool? value) {
                    setState(() {
                      active = value!;
                    });
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 15,
                ),
                onPressed: () {
                  String name = ControllerName.text;
                  int Exp = int.parse(ControllerExp.text);
                  createUser(name: name, Exp: Exp, active: active);
                },
                child: Text("Add more employes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUser(Employee user) => Center(
        child: Card(
          elevation: 10.0,
          color: user.Exp > 5 && user.active == true
              ? Colors.greenAccent
              : Colors.blueAccent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/1869/1869679.png'),
              ),
              Text(
                'Name- ${user.name}',
                style: TextStyle(fontSize: 25, color: Colors.black),
              ),
              Text(
                ('Exp-${user.Exp.toString().isEmpty ? 'Unable to fetch' : user.Exp.toString()}'),
                style: TextStyle(fontSize: 20, color: Colors.black),
              )
            ],
          ),
        ),
      );

  // title: Text(user.name),
  // subtitle: Text(user.Exp.toString()),

  Stream<List<Employee>> readUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Employee.fromJson(doc.data())).toList());
  }

  Future createUser(
      {required String name, required int Exp, required bool active}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    final json = {
      'name': name,
      'Exp': Exp,
      'active': active,
    };
    await docUser.set(json);
  }
}

class Employee {
  late final String name;
  late final int Exp;
  late final bool active;

  Employee({required this.name, required this.Exp, required this.active});

  static Employee fromJson(Map<String, dynamic> json) {
    return Employee(
        name: json['name'] ?? 'Carlos',
        Exp: json['Exp'],
        active: json['active']);
  }
}
