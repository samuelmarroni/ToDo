import 'package:flutter/material.dart';
import 'package:todo/colors/principal_color.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todo/screens/to_do_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Certifica que o binding foi inicializado antes do código async
  await initializeDateFormatting();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: PrincipalGreyColor.color,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0XFF274659),
            secondary: const Color(0XFFE9F8FF)
        ),
      ),
      home: ToDoListPage(),
    );
  }
}