import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String _baseUrl =
      'http://172.20.10.2:5000'; // Update with correct server IP

  // Method to send the image and process the response
  Future<String> processImage(Uint8List imageBytes) async {
    try {
      // Prepare the multipart request
      var request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/process_image'));

      // Add the image file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // Field name that the server expects for the file
          imageBytes,
          filename: 'image.jpg', // Optional filename for the image
          contentType:
              MediaType('image', 'jpeg'), // Specify the content type (JPEG)
        ),
      );

      // Send the request
      var response = await request.send();

      // Check if the response is successful
      if (response.statusCode == 200) {
        // If successful, convert the response body stream into a string
        final responseBody = await response.stream.bytesToString();

        // Decode the JSON response from the server
        final result = jsonDecode(responseBody);

        // Return the result (assuming the server returns a 'result' field)
        return result['result'];
      } else {
        // If the response code is not 200, throw an exception
        throw Exception(
            'Failed to process image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Return a specific error message for troubleshooting
      throw Exception('Error processing image: $e');
    }
  }
}
