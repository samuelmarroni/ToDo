import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo/components/task_dismissible.dart';
import 'package:todo/components/task_item.dart';
import 'package:todo/models/task.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Importação necessária para formatar datas

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late final FirebaseDatabase database;
  late final DatabaseReference databaseReference;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    database = FirebaseDatabase(
      databaseURL: 'https://todo-55afe-default-rtdb.firebaseio.com',
    );
    databaseReference = database.reference();
    Future.delayed(Duration(milliseconds: 1000), () {
      _selectedDayChanged(_selectedDay, _focusedDay);
    });
  }

  List<Task> tasks = [];

  String calendarToDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date); // Data formatada
  }

  String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final tomorrow = today.add(Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Hoje';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Ontem';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Amanhã';
    } else {
      return DateFormat('EEEE, d MMMM y', 'pt_BR').format(date);
    }
  }

  TextStyle dayStyle(FontWeight fontWeight) {
    return TextStyle(
      color: const Color(0XFF274659),
      fontWeight: fontWeight,
    );
  }

  void _selectedDayChanged(DateTime? selectedDay, DateTime? focusedDay) {
    if (selectedDay != null) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay ?? selectedDay;
      });
      databaseReference
          .child(calendarToDate(_selectedDay))
          .get()
          .then((DataSnapshot snapshot) {
        setState(() {
          tasks = [];
          if (snapshot.value != null) {
            var dbTasks = Map<String, dynamic>.from(snapshot.value as Map);
            dbTasks.forEach((date, task) {
              tasks.add(Task(
                title: task['title'],
                description: task['description'],
                done: task['done'],
                date: date,
              ));
            });
          }
        });
      }).catchError((error) {
        print('Erro ao obter dados do Firebase: $error');
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    databaseReference
        .child(calendarToDate(_selectedDay))
        .get()
        .then((DataSnapshot snapshot) {
      setState(() {
        tasks = [];
        if (snapshot.value != null) {
          var dbTasks = Map<String, dynamic>.from(snapshot.value as Map);
          dbTasks.forEach((date, task) {
            tasks.add(Task(
              title: task['title'],
              description: task['description'],
              done: task['done'],
              date: date,
            ));
          });
        }
      });
    }).catchError((error) {
      print('Erro ao obter dados do Firebase: $error');
    });
  }

  void removeTask(int index) {
    setState(() {
      databaseReference
          .child(calendarToDate(_selectedDay))
          .child(tasks[index].title)
          .remove();
      tasks.removeAt(index);
    });
  }

  void addTask(BuildContext context) {
    TextEditingController _taskTitleController = TextEditingController();
    TextEditingController _taskDescriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('Nova tarefa'),
          content: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _taskTitleController,
                      validator: (value) {
                        return value!.isEmpty
                            ? 'Informe o título da tarefa'
                            : null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Título',
                        icon: Icon(Icons.title),
                      ),
                    ),
                    TextFormField(
                      controller: _taskDescriptionController,
                      validator: (value) {
                        return value!.isEmpty ? 'Descreva a tarefa' : null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        icon: Icon(Icons.description),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              child: Text("Salvar"),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  databaseReference
                      .child(calendarToDate(_selectedDay))
                      .child(_taskTitleController.text)
                      .set({
                    'title': _taskTitleController.text,
                    'description': _taskDescriptionController.text,
                    'done': false,
                  });
                  setState(() {
                    tasks.add(Task(
                      title: _taskTitleController.text,
                      description: _taskDescriptionController.text,
                      date: calendarToDate(_selectedDay),
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: const Color(0XFFE9F8FF),
              title: Image.asset(
                'images/logo.png',
                height: 60, // Ajuste a altura conforme necessário
              ),
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    exit(0);
                  },
                ),
              ],
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    _onDaySelected(selectedDay, focusedDay);
                  }
                },
                locale: 'pt_BR',
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  defaultTextStyle: dayStyle(FontWeight.normal),
                  weekendTextStyle: dayStyle(FontWeight.normal),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blueGrey,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0XFF274659),
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    color: const Color(0XFF274659),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  weekdayStyle: TextStyle(
                    color: const Color(0XFF274659),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    color: const Color(0XFF274659),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  color: const Color(0XFF274659),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(50)),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20, left: 30),
                          child: Text(
                            getFormattedDate(_selectedDay), // Data formatada
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 30),
                            child: tasks.isNotEmpty
                                ? ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                return TaskDismissible(
                                  onDismiss: () {
                                    removeTask(index);
                                  },
                                  taskItem: TaskItem(tasks[index]),
                                );
                              },
                            )
                                : Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text(
                                "Nenhuma tarefa",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 20,
                                ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddTaskPage(
                  selectedDay: _selectedDay,
                  databaseReference: databaseReference,
                )),
          ).then((result) {
            if (result != null) {
              setState(() {
                tasks.add(result);
              });
            }
          });
        },
        child: Icon(CupertinoIcons.add,
            color: Theme.of(context).colorScheme.secondary),
        backgroundColor: const Color(0XFF274659),
      ),
    );
  }
}

class AddTaskPage extends StatefulWidget {
  final DateTime selectedDay;
  final DatabaseReference databaseReference;
  AddTaskPage({required this.selectedDay, required this.databaseReference});
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _taskTitleController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      widget.databaseReference
          .child(Task.calendarToDate(widget.selectedDay))
          .child(_taskTitleController.text)
          .set({
        'title': _taskTitleController.text,
        'description': _taskDescriptionController.text,
        'done': false,
      }).then((_) {
        Navigator.pop(
            context,
            Task(
              title: _taskTitleController.text,
              description: _taskDescriptionController.text,
              date: Task.calendarToDate(widget.selectedDay),
            ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Adicionar Tarefa'),
          backgroundColor: const Color(0XFFE9F8FF)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _taskTitleController,
                  maxLength: 50, // Limite máximo de 50 caracteres para o título
                  validator: (value) =>
                  value!.isEmpty ? 'Informe o título da tarefa' : null,
                  decoration: InputDecoration(labelText: 'Título'),
                ),
                SizedBox(height: 16), // Espaço entre os campos
                TextFormField(
                  controller: _taskDescriptionController,
                  maxLength: 200, // Limite máximo de 200 caracteres para a descrição
                  validator: (value) =>
                  value!.isEmpty ? 'Descreva a tarefa' : null,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
                SizedBox(height: 16), // Espaço entre os campos e o botão
                ElevatedButton(
                    onPressed: _saveTask,
                    child: Text('Salvar')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
