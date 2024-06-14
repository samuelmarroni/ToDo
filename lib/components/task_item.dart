import 'package:flutter/material.dart';
import 'package:todo/models/task.dart';
import 'package:firebase_database/firebase_database.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  TaskItem(this.task);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  final databaseReference = FirebaseDatabase(
    databaseURL: 'https://todo-list-a8b3c-default-rtdb.firebaseio.com/',
  ).reference();

  bool showDescription = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              widget.task.icon,
              color: widget.task.iconColor,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                print("Date ${widget.task.date}");
                print("Titulo: ${widget.task.title}");

                databaseReference
                    .child(widget.task.date)
                    .child(widget.task.title)
                    .update({
                  'done': !widget.task.done,
                });

                widget.task.done = !widget.task.done;
              });
            },
          ),
          Flexible(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showDescription = !showDescription;
                });
              },
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: showDescription
                          ? Text(
                        widget.task.description,
                        key: ValueKey<String>('description'),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
