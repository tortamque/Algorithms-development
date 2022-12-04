import 'package:flutter/material.dart';
import 'pages/view_page.dart';
import 'pages/find_page.dart';
import 'pages/add_page.dart';
import 'pages/remove_page.dart';
import 'pages/edit_page.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(title: 'Labwork 3'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;
  @override
  State<MainPage> createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  var navigationBarIndex = 0;

  final pages = [
    const ViewPage(),
    const FindPage(),
    const AddPage(),
    const RemovePage(),
    const EditPage(),
  ];

  Color? colorAppbar(){
    if(navigationBarIndex < 1 || navigationBarIndex == 4){
      return Colors.blue;
    }
    else if(navigationBarIndex == 2){
      return Colors.green;
    }
    else if(navigationBarIndex == 3){
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: colorAppbar()
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.shifting,
        currentIndex: navigationBarIndex,
        onTap: (value) => setState(() {
          navigationBarIndex = value;
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye_outlined),
            label: "View",
            backgroundColor: Colors.blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.find_in_page),
            label: "Find",
            backgroundColor: Colors.blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add,),
            label: "Add",
            backgroundColor: Colors.green
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove),
            label: "Remove",
            backgroundColor: Colors.red
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: "Edit",
            backgroundColor: Colors.blue
          ),
        ],
      ),
      body: pages[navigationBarIndex]
    );
  }
}
