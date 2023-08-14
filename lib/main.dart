import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/widgets/data_table.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
//personal widgets
import './widgets/lat_long_text_field.dart.dart';
import './widgets/boton_obtener_json.dart';

const urlbase = 'https://app.iedeoccidente.com';
double latitude = 0;
double longitude = 0;
Timer? _timer;

class Coordenadas {
  final double latitude;
  final double longitude;

  Coordenadas(this.latitude, this.longitude);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    myController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      setState(() {
        localization();
      });
    });
  }

  Coordenadas coordenadas = Coordenadas(0, 0);
  final TextEditingController myController = TextEditingController();
  List<String> nombres = [];
  String jsonInfo = "";
  var loading = false;
  var loadingBtn = false;
  String dropDownValue = "";
  List dataT = [];
  void fetchDataFromJson() async {
    setState(() {
      loading = true;
      nombres.clear();
      jsonInfo = "";
    });

    final Uri url = Uri.parse('$urlbase/getPeriodos.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Limpiamos la lista actual antes de agregar nuevos nombres
        if (kDebugMode) {
          print(jsonData);
        }
        nombres.clear();
        //nombres.addAll(jsonData['periodo']);

        // Iteramos sobre los datos JSON y obtenemos los nombres
        for (var item in jsonData) {
          String nombre = item['periodo'];
          nombres.add(nombre);
        }

        // Actualizamos el widget con los nuevos datos
        // Esto es necesario para que los cambios se reflejen en la interfaz gráfica
        setState(() {
          dropDownValue = nombres.first;
          loading = false;
        });
      } else {
        if (kDebugMode) {
          print('Error al obtener los datos JSON: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error $e');
      }
      _mostrarAlert(context, 'Error', '$e');
    }

    final url2 = Uri.parse('$urlbase/getPeriodosNotas.php');
    final responseData = await http.get(url2);
    if (responseData.statusCode == 200) {
      // Limpiamos la lista actual antes de agregar nuevos nombres
      if (kDebugMode) {
        print(responseData.body);
      }
      setState(() {
        jsonInfo = responseData.body;
        loading = false;
      });
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('My Dialog'),
            content: const Text('This is a dialog.'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _mostrarAlert(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obtener Datos JSON'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
                child: RemoteImage(
              imageUrl: 'https://app.iedeoccidente.com/escudo.png',
            )),
            Padding(
                padding: const EdgeInsets.all(10),
                child: LatLongTextField(
                    key: const Key('latlongtextfield'),
                    myController: myController)),
            Padding(
                padding: const EdgeInsets.all(5),
                child: BotonObtenerJson(
                    key: const Key('botonObtenerJson'),
                    onButtonPressed: fetchDataFromJson)),
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    loadingBtn = !loadingBtn;
                    dataT.clear();
                  });
                  final data = await fetchData();
                  setState(() {
                    dataT = data;
                    loadingBtn = !loadingBtn;
                  });
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.amberAccent),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(
                          horizontal: 150, vertical: 10)),
                ),
                child: loadingBtn
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitCircle(
                            color: Colors.blue, // Color de la animación
                            size: 20.0, // Tamaño del widget
                          ),
                          Text('Datos'),
                        ],
                      )
                    : const Text('Datos')),
            const SizedBox(height: 20),
            Loading(
              isLoading: loading,
              child: const Text(""),
            ),
            DropdownButton(
              value: dropDownValue,
              items: nombres.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? value) {
                // Do something with the selected value.
                setState(() {
                  dropDownValue = value!;
                });
              },
            ),
            Expanded(child: DataTablex(jsonInfo: jsonInfo)),
            Expanded(
              child: ListView.builder(
                itemCount: nombres.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(nombres[index]),
                    onTap: () {
                      if (kDebugMode) {
                        print(nombres[index]);
                      }
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Item Seleccionado'),
                            content: Text('Has escogido ${nombres[index]}'),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Cerrar'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Card(
                    child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Estudiante Seleccionado'),
                                content: Text(
                                    'Has escogido ${dataT[index]['estudiante']}'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.pinkAccent),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.black),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(
                                  horizontal: 150, vertical: 10)),
                        ),
                        child: Text(dataT[index]['estudiante'])),
                  );
                },
                itemCount: dataT.length,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Agregamos una acción adicional al botón flotante para limpiar la lista
          setState(() {
            nombres.clear();
            jsonInfo = "";
            loading = false;
            dataT.clear();
          });
        },
        child: const Icon(Icons.clear),
      ),
    );
  }

  Future<List> fetchData() async {
    final url3 = Uri.parse('$urlbase/getNotas.php');
    final headers = {
      'Content-Type': 'application/json'
    }; // Set your desired headers
    final body = json.encode({
      'docente': '10288864',
      'nivel': '6',
      'numero': '1',
      'asignatura': 'TECNOLOG',
      'periodo': 'TRES',
      'asignacion': '1',
    });
    final response = await http.post(url3, headers: headers, body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error fetching data');
    }
  }

  Future<Coordenadas> getLocation() async {
    final Coordenadas coord0 = Coordenadas(0, 0);
    late Coordenadas coords;
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // El usuario negó el permiso de ubicación
        if (kDebugMode) {
          print("localización negada");
        }
        return coord0;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      coords = Coordenadas(position.latitude, position.longitude);
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener la ubicación: $e');
      }
    }
    return coords;
  }

  void localization() {
    getLocation().then((Coordenadas c) {
      coordenadas = c;
      setState(() {});
      String locationInfo = '${coordenadas.latitude},${coordenadas.longitude}';
      myController.text = locationInfo;
      if (kDebugMode) {
        print(locationInfo);
      }
    });
  }
}

class Loading extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const Loading({super.key, this.isLoading = false, required this.child});

  @override
  // ignore: library_private_types_in_public_api
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return widget.isLoading ? const CircularProgressIndicator() : widget.child;
  }
}

class RemoteImage extends StatelessWidget {
  final String imageUrl;

  const RemoteImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    try {
      return Center(
        child: Image.network(imageUrl),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error de imagen de red: $e');
      }
      return const Text('Error de Imagen:');
    }
  }
}
