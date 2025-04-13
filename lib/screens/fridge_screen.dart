import 'package:flutter/material.dart';

class OpenFridgeScreen extends StatelessWidget {
    const OpenFridgeScreen({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text('Open Fridge'),
            ),
            body: Center(
                child: Text('Fridge Screen Content'),
            ),
        );
    }

}