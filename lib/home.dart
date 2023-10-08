import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:flutter_signature_module/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // initialize the signature controller
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  //initilize the name controller
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => log('Value changed'));
  }

  Future<void> generatePDF(String name, Uint8List signature) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      build: (context) => pw.Column(
        children: [
          pw.Text('Name: $name'),
          pw.Image(pw.MemoryImage(signature)),
        ],
      ),
    ));

    final file = File('signature.pdf');
    final bytes = await doc.save();
    await file.writeAsBytes(bytes);
  }

  Future<void> exportImage(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No content'),
        ),
      );
      return;
    }

    final Uint8List? data = await _controller.toPngBytes(
      height: (await _controller.toImage())!.height.toInt(),
      width: (await _controller.toImage())!.width.toInt(),
    );
    if (data == null) {
      return;
    }

    if (!mounted) return;

    await push(
      context,
      Scaffold(
        appBar: AppBar(
          title: const Text('PNG Image'),
        ),
        body: Center(
          child: Container(
            color: Colors.grey[300],
            child: Image.memory(data),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Demo'),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(
            height: 160,
            child: Center(
              child: Text('Big container to test scrolling issues'),
            ),
          ),
          //name text field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name and surname',
              ),
            ),
          ),
          //SIGNATURE CANVAS
          Signature(
            key: const Key('signature'),
            controller: _controller,
            height: 400,
            backgroundColor: Colors.grey[300]!,
          ),
          //OK AND CLEAR BUTTONS

          const SizedBox(
            height: 160,
            child: Center(
              child: Text('Big container to test scrolling issues'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //generate pdf with name and signature
              //generate pdf with name and signature
              IconButton(
                  onPressed: () async {
                    final name = _nameController.text;
                    final signature = await _controller.toPngBytes();

                    await generatePDF(name, signature!);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  color: Colors.blue),

              IconButton(
                icon: const Icon(Icons.undo),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.undo());
                },
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.redo());
                },
                tooltip: 'Redo',
              ),
              //CLEAR CANVAS
              IconButton(
                key: const Key('clear'),
                icon: const Icon(Icons.clear),
                color: Colors.blue,
                onPressed: () {
                  setState(() => _controller.clear());
                },
                tooltip: 'Clear',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
