import 'dart:convert';
import 'package:flutter/material.dart';

class DataTablex extends StatefulWidget {
  final String jsonInfo;
  const DataTablex({Key? key, required this.jsonInfo}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _DataTablexState createState() => _DataTablexState();
}

class _DataTablexState extends State<DataTablex> {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Ind')),
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('Seleted')),
      ],
      rows: widget.jsonInfo != ""
          ? (json.decode(widget.jsonInfo) as List<dynamic>).map((data) {
              return DataRow(cells: [
                DataCell(Text(data['ind'])),
                DataCell(Text(data['nombre'])),
                DataCell(Text(data['selected'])),
              ]);
            }).toList()
          : [],
    );
  }
}
