import 'package:flutter/material.dart';
import 'package:todo/components/task_item.dart';

class TaskDismissible extends StatefulWidget {
  final Function onDismiss;
  final TaskItem taskItem;

  TaskDismissible({
    required this.onDismiss,
    required this.taskItem,
  });

  @override
  _TaskDismissibleState createState() => _TaskDismissibleState();
}

class _TaskDismissibleState extends State<TaskDismissible> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        widget.onDismiss();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tarefa removida!")),
        );
      },
      // Show a red background as the item is swiped away.
      background: Container(color: Colors.red),
      child: widget.taskItem,
    );
  }
}
