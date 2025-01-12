import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Picker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'File Picker Demo'),
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
  String? _fileName;
  String? _filePath;

  Future<void> _pickFile() async {
    try {
      // Add more detailed error handling
      if (!mounted) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      FilePickerResult? result = await FilePicker.platform
          .pickFiles(
        type: FileType.any,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) {
          debugPrint(status.toString());
        },
      )
          .catchError((error) {
        debugPrint('Error in file picking: $error');
        return null;
      });

      // Close loading indicator
      if (mounted) Navigator.of(context).pop();

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _fileName = result.files.first.name;
          _filePath = result.files.first.path;
        });
      }
    } catch (e) {
      debugPrint('Exception in _pickFile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Pick a File'),
            ),
            const SizedBox(height: 20),
            if (_fileName != null) ...[
              Text(
                'Selected File:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text('Name: $_fileName'),
              const SizedBox(height: 5),
              Text('Path: $_filePath'),
            ],
          ],
        ),
      ),
    );
  }
}
