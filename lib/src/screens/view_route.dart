import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocateapp/src/models/vehicle.dart';
//pantalla que muestra el recorrido de los vehiculos
class RecorridoScreen extends StatefulWidget {
  final String token;
  final String ticket;
  final String orden_carga;
  RecorridoScreen({required this.token, required this.ticket, required this.orden_carga});

  @override
  _RecorridoScreenState createState() => _RecorridoScreenState(token: token, ticket:ticket, orden_carga:orden_carga);
}

class _RecorridoScreenState extends State<RecorridoScreen> {
  final String token;
  final String ticket;
  final String orden_carga;
  late Future<List<dynamic>> recorridoData;
  late Future<List<dynamic>> planificacionData;
  late Future<List<dynamic>> validationData;
  
//Pantalla qye 
  _RecorridoScreenState({required this.token, required  this.ticket, required this.orden_carga});

  @override
  void initState() {
    super.initState();
    recorridoData = fetchRecorridoData(ticket);
    planificacionData = fetchPlanning(orden_carga);
  }
//calcula el tiempo del ticket a traves de su recorrido
 String calcularTiempoTranscurrido(List<dynamic> recorridoData) {
  if (recorridoData.isEmpty) {
    return 'No hay tiempos registrados';
  }

  // Obtener la primera cadena de fecha y hora de la lista
  String primerTiempo = recorridoData.first['date_created'];
  
  // Dividir la cadena en fecha y hora
  List<String> partes = primerTiempo.split(', ');

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
 
  //combina la data del recorrido con la planificacion de la orden de carga
  Future<List<ScanStatus>> combineData(List<dynamic> recorridoData, List<String> processedPlanificacionData) async {
    List<ScanStatus> combinedList = [];

    for (var item in processedPlanificacionData) {
      var scanStatus = recorridoData.firstWhere(
        (element) => element['status_scanner'] == item,
        orElse: () => null,
      );

      String status = scanStatus != null ? 'OK' : 'EN ESPERA';

      combinedList.add(ScanStatus(item, status));
    }

    return combinedList;
  }
  //procesa la planificacion de la orden de carga
  Future<List<String>> processPlanificacionData(List<dynamic> planificacionData) async {
  List<String> processedList = [];
  

    for (var item in planificacionData) {
      String puntoEscanner = item['punto_escaner'];
      
      if (puntoEscanner == 'p1' && !processedList.contains('vigilancia')) {
        processedList.add('vigilancia');
      } 
      if ((puntoEscanner == 'p2' || puntoEscanner == 'p3') && !processedList.contains('vigilancia2')) {
        processedList.add('vigilancia2');
      }
      if (puntoEscanner == 'p4') {
        processedList.add('p4');
        //print('p4 no se agrega');
      } 
    }
    
    return processedList;
  }
  //funcion que obtiene la planificacion de la orden de carga
  Future<List<dynamic>> fetchPlanning(String ordenCarga) async {
    
    String urLoc = 'https://apiubitransport.iancarina.com.ve/location/stop/getplanning/$orden_carga';
    print(urLoc);
    final response = await http.get(Uri.parse(urLoc),
    headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':'Bearer $token'
        },);
    if (response.statusCode == 200) {
      print(response);
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load planning data');
    }
  } 
  //funcion que obtiene el recorrido del ticket
  Future<List<dynamic>> fetchRecorridoData(String ticket) async {
    final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve/location/stop/getracking/$ticket'),
    headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':'Bearer $token'
        },);
    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recorrido data');
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recorrido'),
        centerTitle: true,
      ),
      
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([recorridoData, planificacionData]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text(" "));
          } else {
            List<dynamic> recorrido = snapshot.data![0];
            List<dynamic> planificacion = snapshot.data![1];
            String tiempoTranscurrido = calcularTiempoTranscurrido(recorrido);
            return SingleChildScrollView(
              child: Column(
                children:[
                  Container(
                    //width: 400,
                   
                    child: Row(
                    children: [
                    SizedBox(width: 120,),
                    Expanded(
                      //flex: 1,
                      child: Text(
                        'PUNTO ESCANER',
                        //textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        //overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      //flex: 1,
                      child: Text(
                        'FECHA',
                       // textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        //overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      //flex: 1,
                      child: Text(
                        'TIEMPO TRANSCURRIDO',
                        //textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  ),
                  ),
                 SingleChildScrollView(
                    child: Container(
                      height: 400,
                      child: ListView.builder(
                        itemCount: recorrido.length,
                        itemBuilder: (BuildContext context, int index) {
                          var recorridoItem = recorrido[index];
                          return Row(
                            children: <Widget>[
                              SizedBox(width: 120,),
                              Expanded(
                                child: Text(
                                  recorridoItem['status_scanner'] ?? 'Valor predeterminado',
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  recorridoItem['date_created'] ?? 'Valor predeterminado',
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  recorridoItem['time_spent'] ?? 'Valor predeterminado',
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 50,),
                  Row(
                        children: <Widget>[
                          SizedBox(width: 130,),
                          Expanded(
                            child: Text(
                              '             ',
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'TIEMPO TOTAL TRANSCURRIDO:',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${tiempoTranscurrido}',
                              style: TextStyle(fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                  ),
                  SizedBox(height: 100,),
                  Row(
                      children: <Widget>[
                        SizedBox(width: 130,),
                        Expanded(
                          child: Text(
                            'PLANIFICACION', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'VALIDACION', 
                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: 
                          Center(child: Text(
                            'ESTADO', 
                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),),
                          
                        ),
                      ],
                    ),
                    Container(
                    height: 150,
                    child: ListView.builder(
                      itemCount: planificacion.length,
                      itemBuilder: (BuildContext context, int index) {
                        var planificacionItem = planificacion[index];
                        var point_scanner = planificacionItem['punto_escaner'];
                        if (point_scanner == 'p1')
                          point_scanner = 'Planta 1';
                        if (point_scanner == 'p2')
                          point_scanner = 'Planta 2';
                        if (point_scanner == 'p3')
                          point_scanner = 'Planta 3';
                        if (point_scanner == 'p4')
                          point_scanner = 'Planta 4';
                        if (point_scanner == 'p5')
                          point_scanner = 'Planta 5';

                        return Row(
                          children: <Widget>[
                            SizedBox(width: 130),
                            Expanded(
                              flex: 1, // Primer Expanded
                              child: Text(
                                point_scanner ?? 'N/A',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            SizedBox(width: 20), // Espacio entre los dos Expanded
                            Expanded(
                              flex: 2, // Segundo Expanded
                              child: FutureBuilder<List<String>>(
                                future: processPlanificacionData([planificacionItem]),
                                builder: (context, processedSnapshot) {
                                  if (processedSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (processedSnapshot.hasError) {
                                    return Center(
                                        child: Text("Error: ${processedSnapshot.error}"));
                                  } else if (!processedSnapshot.hasData ||
                                      processedSnapshot.data!.isEmpty) {
                                    return Center(child: Text(" "));
                                  } else {
                                    return FutureBuilder<List<ScanStatus>>(
                                      future: combineData(recorrido, processedSnapshot.data!),
                                      builder: (context, combinedSnapshot) {
                                        if (combinedSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator());
                                        } else if (combinedSnapshot.hasError) {
                                          return Center(
                                              child: Text("Error: ${combinedSnapshot.error}"));
                                        } else if (!combinedSnapshot.hasData ||
                                            combinedSnapshot.data!.isEmpty) {
                                          return Center(child: Text(" "));
                                        } else {
                                          List<ScanStatus> combinedData =
                                              combinedSnapshot.data!;
                                          return Column(
                                            children: combinedData.map((scanStatus) {
                                              return Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1, // Tercer Expanded
                                                    child: Text(
                                                      scanStatus.puntoEscanner,
                                                      style: TextStyle(fontSize: 20,),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(width: 20), // Espacio entre el texto y el icono
                                                  if (scanStatus.status == 'OK')
                                                  Expanded(
                                                    //flex: 1,
                                                    child: Icon(Icons.check, color: Colors.green[400]),),
                                                    
                                                  if (scanStatus.status == 'EN ESPERA')
                                                    Expanded(
                                                      //flex: 1,
                                                      child:  Icon(Icons.dangerous_outlined, color: Colors.red[400]),)
                                                ],
                                              );
                                            }).toList(),
                                          );
                                        }
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
