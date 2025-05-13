import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
// import '../../../../core/theme/theme_controller.dart';

class DocAppbar extends StatelessWidget {
  const DocAppbar({
    super.key,
    required this.addNewTask,
    required this.onSearchPressed,
  });

  final Function() addNewTask;
  final Function() onSearchPressed;

  @override
  Widget build(BuildContext context) {
    // final theme = themeSignal.watch(context);
    return AppBar(
      title: Row(
        children: [
          IconButton(
            onPressed: () {
              addNewTask();
            },
            icon: const Icon(Icons.add, color: Colors.white),
            // icon: Icon(Icons.add, color: theme.appBarTheme.iconTheme?.color),
          ),
          const Expanded(
            child: Text(
              'Doc ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            // icon: Icon(Icons.search, color: theme.appBarTheme.iconTheme?.color),
            onPressed: onSearchPressed,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}

  // void _showAddTaskDialog(BuildContext context) {
  //   final TextEditingController _taskController = TextEditingController();
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Add New Document Exchange'),
  //         content: TextField(
  //           controller: _taskController,
  //           decoration: const InputDecoration(hintText: 'Enter title name'),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               addNewTask(
  //                   _taskController.text); // Call the refactored function
  //               print("task screen");
  //               print(
  //                   "taskModel: ${selectedChannel.select((s) => s.value.toString())}");
  //               print("chatModel.....: ${widget.chatModel!.name}");
  //               final userName = Computed(() => widget.chatModel!.name);
  //               final respChannelName =
  //                   Computed(() => selectedChannel.select((s) => s.value));
  //               final respChannelNameValue = respChannelName.toString();
  //               print("respChannelNameValue: $respChannelNameValue");
  //               await fetchInitialUi(
  //                 "billalkhann@gmail.com",
  //                 "Official",
  //                 // userName.toString(),
  //                 // respChannelNameValue,
  //               );
  //               IndividualPage.globalKey.currentState?.initState();
  //               callFirstScreenMethod();
  //               // context.go('/home');

  //               Navigator.pop(context);
  //             },
  //             child: const Text('Submit'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

