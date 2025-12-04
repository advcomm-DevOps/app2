// import 'package:flutter/material.dart';

// class AboutView extends StatelessWidget {
//   const AboutView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('About'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Text(
//               'About View',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'This is the about page of the application.',
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';

class AboutView extends StatefulWidget {
  @override
  _FileDropWidgetState createState() => _FileDropWidgetState();
}

class _FileDropWidgetState extends State<AboutView> {
  bool isDragging = false;
  String? filePath;
  int? fileSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Drag & Drop File")),
      body: Center(
        child: DropTarget(
          onDragEntered: (details) => setState(() => isDragging = true),
          onDragExited: (details) => setState(() => isDragging = false),
          onDragDone: (details) {
            setState(() => isDragging = false);
            if (details.files.isNotEmpty) {
              final file = details.files.first;
              setState(() {
                filePath = file.path;
                fileSize = File(file.path).lengthSync();
              });
              print("Dropped file: $filePath");
            }
          },
          child: Container(
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              color: isDragging ? Colors.blue.shade200 : Colors.grey.shade300,
              border: Border.all(color: Colors.black54, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: filePath == null
                ? Text(
                    "Drag a file here",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 48,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "File path:\n$filePath",
                        textAlign: TextAlign.center,
                      ),
                      Text("Size: ${fileSize ?? 0} bytes"),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
