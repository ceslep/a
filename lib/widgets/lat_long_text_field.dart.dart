import 'package:flutter/material.dart';

class LatLongTextField extends StatelessWidget {
  final TextEditingController myController; // Controlador como parámetro

  const LatLongTextField({super.key, required this.myController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: TextField(
        controller: myController,
        decoration: const InputDecoration(
          labelText: 'Latitud y longitud',
          hintText: 'Latitud y longitud',
        ),
      ),
    );
  }
}
