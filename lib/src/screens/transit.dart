import 'package:flutter/material.dart';
import 'package:geolocateapp/src/models/globalFunctions.dart';
import 'package:geolocateapp/src/models/vehicle.dart';
import 'package:geolocateapp/src/screens/menu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Pantalla que muestra los vehiculos en transitos(esta pantalla se creo cuando el alcance del proyecto era IANCARINA)
class TransitPage extends StatefulWidget{
  final String token;
  final Map<String, dynamic> datos;
  TransitPage({required this.datos, required this.token});

  @override
  _TransitPageState createState() => _TransitPageState(datos: datos, token: token);
}

class _TransitPageState extends State<TransitPage> {
  final String token;
  GlobalFunctions globalFunctions = GlobalFunctions();
  final Map<String, dynamic> datos;
  _TransitPageState({required this.datos, required this.token});
  bool _isLoading = true;
  List<StopVehicle> newVehicles=[];

  @override
  void initState() {
    super.initState();
    getStops(token, context);
  }
  //funcion que obtiene los tickets
  Future<void> getStops(String token, BuildContext context) async{
    try {
      //String urLoc = 'https://apiubitransport.iancarina.com.ve/location/stop/alltickets';
      String urLoc = 'http://0.0.0.0:8000/location/stop/allticketsadmin';
      final response = await http.get(Uri.parse(urLoc), headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data is List) {
          List<StopVehicle> vehicles = [];
          for (final v in data){
            StopVehicle vehicle = StopVehicle(
              placa: v['placa'],
              parada: v['parada'],
              ticket_entrada: v['ticket_entrada'],
              fecha_ticket: v['fecha_ticket'],
              orden_carga: v['orden_carga'],
              tipo_viaje: v['tipo_viaje'],
              estatus_vehicle: v['estatus_vehicle'],
              status_parada: v['status_parada'],
              total_time: v['dateScanner'],
              point_control_id: v['tp_point_control_id'],
              guia_insai: v['guia_insai'],
              turno: v['turno'],
              detalle_guia: v['detalle_guia'],
              nombre_productor: v['nombre_productor'],
              es_materia_prima: v['es_materia_prima']
            );

            if (vehicle.parada != 'No posee' && vehicle.status_parada == 'transito') {
              vehicles.add(vehicle);
            }
          }                               
          setState(() {
            newVehicles = vehicles;
            _isLoading = false;
          });
        }
      } else {
        globalFunctions.errorDialog('Error solicitando coordenadas', context);
      }
      } catch (e) {
        globalFunctions.errorDialog('Error: $e', context);
        throw []; // Devuelve una lista vacía o maneja el error de otra manera
      }
  }
  //funcion que obtiene datos del conductor
  Future<String> getDriver(String ticket) async {
    try {
      String urLoc = 'https://apiubitransport.iancarina.com.ve/driverTicket/$ticket';
      final response = await http.get(Uri.parse(urLoc));
      var driverName = '';
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        driverName = data['username'];
        return driverName;
      } else {
        return driverName;
      }
    } catch (e) {
      globalFunctions.errorDialog('Error: $e', context);
      throw []; // Devuelve una lista vacía o maneja el error de otra manera
    }
  }
  //funcion que obtiene datos del recorrido de la data
  Future<String> fetchRecorridoData(String ticket) async{
    final response = await http.get(
      Uri.parse('https://apiubitransport.iancarina.com.ve/location/stop/getracking/$ticket'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );
    var ultimo_marcaje = '';
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      data as List;
      dynamic ultimoMarc = data.last;
      ultimo_marcaje = ultimoMarc['date_created'];
      return ultimo_marcaje;
    } else {
      return ultimo_marcaje;
    }
  }
  //funcion que obtiene calcula el tiempo transcurrido
  String calcularTiempoTranscurrido(String recorridoData) {
    if (recorridoData.isEmpty) {
      return 'No hay tiempos registrados';
    }

    // Dividir la cadena en fecha y hora
    List<String> partes = recorridoData.split(', ');

    // Verificar si hay dos partes (fecha y hora)
    if (partes.length != 2) {
      return 'Formato de fecha y hora inválido';
    }

    // Analizar la parte de la fecha
    String fechaStr = partes[0];
    List<String> partesFecha = fechaStr.split('-');
    if (partesFecha.length != 3) {
      return 'Formato de fecha inválido';
    }

    int year = int.parse(partesFecha[2]);
    int month = int.parse(partesFecha[1]);
    int day = int.parse(partesFecha[0]);

    // Analizar la parte de la hora
    String horaStr = partes[1];
    List<String> partesHora = horaStr.split(':');
    if (partesHora.length != 3) {
      return 'Formato de hora inválido';
    }

    int hour = int.parse(partesHora[0]);
    int minute = int.parse(partesHora[1]);
    int second = int.parse(partesHora[2]);

    // Crear un objeto DateTime con la fecha y la hora
    DateTime tiempoInicial = DateTime(year, month, day, hour, minute, second);

    // Obtener el momento actual
    DateTime ahora = DateTime.now();

    // Calcular la diferencia de tiempo entre el primer tiempo y el momento actual
    Duration diferencia = ahora.difference(tiempoInicial);

    // Formatear la diferencia de tiempo como una cadena con dos dígitos para minutos y segundos
    String horas = diferencia.inHours.toString();
    String minutos = diferencia.inMinutes.remainder(60).toString().padLeft(2, '0');
    String segundos = diferencia.inSeconds.remainder(60).toString().padLeft(2, '0');
    String diferenciaFormateada = '$horas:$minutos:$segundos';

    return diferenciaFormateada;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 189, 180, 180),
      appBar: AppBar(
        title: Text(
          'ChoferApp',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 207, 23, 9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen(datos: datos,)),
            );
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : newVehicles.isEmpty
              ? Center(
                  child: Text(
                    'No hay vehiculos en transitos.',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: newVehicles.map((item) {
                        return cardBuild(item, context);
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
  //funcion que crea el widget que muestra la informacion del ticket
  Widget cardBuild(dynamic vehicle, BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Future.wait([getDriver(vehicle.ticket_entrada), fetchRecorridoData(vehicle.ticket_entrada)]),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: Center(child: Text('Error al obtener los datos')),
          );
        } else {
          String driver = snapshot.data?[0] ?? 'Desconocido';
          String ultimo_marcaje = snapshot.data?[1] ?? 'Desconocido';
          String tiempoTranscurrido = calcularTiempoTranscurrido(vehicle.total_time);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                // Acción cuando se toca la tarjeta
              },
              child: ListTile(
                title: Text(
                  'Ticket de Entrada: ${vehicle.ticket_entrada}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Placa: ${vehicle.placa}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Conductor: $driver',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tiempo Recorrido: $tiempoTranscurrido',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Último Marcaje: $ultimo_marcaje',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
