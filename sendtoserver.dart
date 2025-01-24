import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Image Upload Example'),
        ),
        body: ImageUploadForm(),
      ),
    );
  }
}

class ImageUploadForm extends StatefulWidget {
  @override
  _ImageUploadFormState createState() => _ImageUploadFormState();
}

class _ImageUploadFormState extends State<ImageUploadForm> {
  File? _image;
  final picker = ImagePicker();

  // Pick an image from the gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Send the image to the Flask backend
  Future<void> _uploadImage() async {
    if (_image == null) return;

    // Prepare the request
    var uri = Uri.parse('http://127.0.0.1:5000/process_image');
    var request = http.MultipartRequest('POST', uri);

    // Attach the image file to the request
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    // Send the request
    var response = await request.send();

    // Check if the request was successful
    if (response.statusCode == 200) {
      print('Image uploaded successfully!');
      final responseData = await response.stream.bytesToString();
      print(responseData); // Handle the response from Flask here
    } else {
      print('Image upload failed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_image != null)
          Image.file(_image!, height: 200)
        else
          Text('No image selected'),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Pick an image'),
        ),
        ElevatedButton(
          onPressed: _uploadImage,
          child: Text('Upload Image'),
        ),
      ],
    );
  }
}
