import 'package:flutter/material.dart';

class BotonObtenerJson extends StatefulWidget {
  final VoidCallback onButtonPressed;

  const BotonObtenerJson({Key? key, required this.onButtonPressed})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BotonObtenerJsonState createState() => _BotonObtenerJsonState();
}

class _BotonObtenerJsonState extends State<BotonObtenerJson> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onButtonPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.red),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(horizontal: 150, vertical: 10)),
      ),
      child: const Text('Obtener Datos JSON'),
    );
  }
}
