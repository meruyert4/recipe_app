import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OpenFridgeScreen extends StatefulWidget {
  const OpenFridgeScreen({Key? key}) : super(key: key);

  @override
  _OpenFridgeScreenState createState() => _OpenFridgeScreenState();
}

class _OpenFridgeScreenState extends State<OpenFridgeScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _ingredients = "";

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _sendImageToAPI(_image!);
    }
  }

  Future<void> _sendImageToAPI(File image) async {
    try {
      final base64Image = base64Encode(image.readAsBytesSync());
      final apiUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=AIzaSyDv70E2lYv91HWljgc8r8m5PoXUZqSIRCw';
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": "List the ingredients you see in this fridge. Answer in foolowing format: Ingredient1, ingredient2, etc. Dont write anything besides ingredients names"},
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image
                  }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _ingredients = data['candidates'][0]['content']['parts'][0]['text'];
        });
      } else {
        setState(() {
          _ingredients = "Failed to fetch ingredients. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _ingredients = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.openFridge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _getImage(ImageSource.camera),
                  child: Text(AppLocalizations.of(context)!.takePhoto),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _getImage(ImageSource.gallery),
                  child: Text(AppLocalizations.of(context)!.chooseFromGallery),
                ),
                SizedBox(height: 20),
                _image == null
                    ? Text(AppLocalizations.of(context)!.noImageSelected)
                    : Image.file(_image!),
                SizedBox(height: 20),
                _ingredients.isEmpty
                    ? Text(AppLocalizations.of(context)!.noIngredientsFound)
                    : Text(
                        '${AppLocalizations.of(context)!.ingredientsFound} \n$_ingredients',
                        textAlign: TextAlign.center,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
