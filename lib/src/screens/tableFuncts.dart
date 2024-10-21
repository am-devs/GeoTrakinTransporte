import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocateapp/src/models/vehicle.dart';

//codigo que tiene funciones que crean widgets para el mapa principal y sus objetos
class HtmlFunct {
  late Future<List<dynamic>> recorridoData;
  late Future<List<dynamic>> planificacionData;
  late Future<List<dynamic>> validationData;

  //funcion que calcula el recorrido del vehiculo
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
  print(ahora);
  // Calcular la diferencia de tiempo entre el primer tiempo y el momento actual
  Duration diferencia = ahora.difference(tiempoInicial);
  
  // Formatear la diferencia de tiempo como una cadena con dos dígitos para minutos y segundos
  String horas = diferencia.inHours.toString();
  String minutos = diferencia.inMinutes.remainder(60).toString().padLeft(2, '0');
  String segundos = diferencia.inSeconds.remainder(60).toString().padLeft(2, '0');
  String diferenciaFormateada = '$horas:$minutos:$segundos';
  
  return diferenciaFormateada;
} 
  //funcion que combina la funcion del recorrido con la de la planificacion para dibujar el widget de la planificacion
  List<ScanStatus> combineData(List<dynamic> recorridoData, List<String> processedPlanificacionData){
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
  //funcion que procesa la data de la planificacion
  List<String> processPlanificacionData(List<dynamic> planificacionData){
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

  //funcion para obtener la planificacion de una orden de carga
  Future<List<dynamic>> fetchPlanning(String ordenCarga) async {
    String urLoc = 'https://apiubitransport.iancarina.com.ve/location/stop/getplanning/$ordenCarga';
    print(urLoc);
    final response = await http.get(Uri.parse(urLoc),);
    if (response.statusCode == 200) {
      print(response);
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load planning data');
    }
  } 
  //funcion para obtener el recorrido de un ticket
  Future<List<dynamic>> fetchRecorridoData(String ticket) async{
    final response = await http.get(Uri.parse('http://0.0.0.0:8000/location/stop/getrackingadmin/$ticket'),);
    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recorrido data');
    }
  }
  //funcion que crea el widget de la tabla de planificacion 
  Widget tablePlanification(BuildContext context, String ticket) {

    return FutureBuilder<List<dynamic>>(
    future: fetchRecorridoData(ticket),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        List<dynamic> recorridoData = snapshot.data!;
        String tiempo_transcurrido = calcularTiempoTranscurrido(recorridoData);
                 return DataTable(
                      columnSpacing: 22,
                      // Define las columnas de la tabla
                      columns:[
                        DataColumn(label: Text('Punto Escaner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Fecha', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tiempo' ,style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ],
                      
                      rows: [
                      ...recorridoData.map((item) {
                        return DataRow(cells: [
                          DataCell(Text(item['status_scanner'].toString(), style: TextStyle(fontSize: 12),)), 
                          DataCell(Text(item['date_created'].toString(), style: TextStyle(fontSize: 12),)),
                          DataCell(Text(item['time_spent'].toString(), style: TextStyle(fontSize: 12),)),
                        ]);
                      }).toList(),
                      DataRow(cells: [
                        DataCell(Text('', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataCell(Text('Total Tiempo:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataCell(Text('$tiempo_transcurrido', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ]),
                    ],
                    );     
      }
    },
  ); 
  }
  //funcion que crea el widget de la tabla del estado de la planificacion
  Widget tablaEstado(BuildContext context, String ticket, String orden_carga){
    return FutureBuilder<List<dynamic>>(
      
    future: fetchPlanning(orden_carga),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }else {
       List<dynamic> planningData = snapshot.data!;
       List<String> processesPlaning = processPlanificacionData(planningData);


        return FutureBuilder<List<dynamic>>(
          future: fetchRecorridoData(ticket),
          builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        List<dynamic> recorridoData = snapshot.data!;
        List<ScanStatus> combine_data = combineData(recorridoData, processesPlaning);
                 return Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 22,
                      // Define las columnas de la tabla
                      columns: [
                        DataColumn(label: Text('Planificacion', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),)),
                        DataColumn(label: Text('Validacion', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),),
                        DataColumn(label: Text('Estado' ,style: TextStyle(fontSize: 12,  fontWeight: FontWeight.bold),)),
                      ],
                       rows: List<DataRow>.generate(
        // Determina la longitud de las filas usando la longitud máxima entre planningData y combine_data
                        max(planningData.length, combine_data.length),
                        (index) {
                          //Obtén los datos de planningData si están disponibles
                          dynamic planningCell = index < planningData.length;

                          if(planningCell){
                            var point_scanner =  planningData[index]['punto_escaner'].toString();
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
                             planningCell = DataCell(Text(
                                point_scanner, 
                                style: TextStyle(fontSize: 12)));
                          }
                          else{
                           planningCell = DataCell(Text('')); 
                          }
                        

                          // Obtén los datos de combine_data si están disponibles
                          var combineCell = index < combine_data.length
                              ? DataCell(Text(combine_data[index].puntoEscanner.toString(), style: TextStyle(fontSize: 12)))
                              : DataCell(Text('')); // Celda vacía si no hay más datos en combine_data
                          
                          dynamic statusCell = index < combine_data.length;
                           if (combine_data[index].status.toString() == 'OK'){
                            statusCell = DataCell(Icon(Icons.check, color: Colors.green[400]),);
                            }

                            if (combine_data[index].status.toString() == 'EN ESPERA'){
                            statusCell = DataCell(Icon(Icons.dangerous_outlined, color: Colors.red[400]),);
                            }

                          // Devuelve una fila con las celdas correspondientes
                          return DataRow(cells: [planningCell, combineCell, statusCell]);
                        },
                      ),
                                    
                                  ),
                                ),
                              );
                    }
                  },
                  );                                   
      }
    },
  );
  }



}