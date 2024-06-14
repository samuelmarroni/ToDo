import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Task {
  late String _title;
  late String _description;
  late String _date;
  late IconData _icon;
  late Color _iconColor;
  late bool _done;

  Task({
    required String title,
    required String description,
    required String date,
    bool done = false,
  })   : _done = done,
        _icon = done ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.clock_solid,
        _iconColor = done ? Color(0xff00cf8d) : Color(0xffff9e00) {
    this.title = title;
    this.description = description;
    this.date = date;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  bool get done => _done;

  set done(bool value) {
    _done = value;
    _icon = value ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.clock_solid;
    _iconColor = value ? Color(0xff00cf8d) : Color(0xffff9e00);
  }

  Color get iconColor => _iconColor;
  IconData get icon => _icon;

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  // Método estático para formatar a data como string
  static String calendarToDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
