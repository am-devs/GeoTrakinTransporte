import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocateapp/src/models/globalFunctions.dart';
import 'package:http/http.dart' as http;
import 'package:geolocateapp/src/models/vehicle.dart';
import 'package:latlong2/latlong.dart';

//Clase que obtiene datos de ubicaciones y tickets

class CoordinatesFunctions{
  GlobalFunctions globalFunctions =GlobalFunctions();
  String tiempoTranscurrido = '';
  
  //Obtiene las coordenadas de los vehiculos
  Future<List<Vehicle>> getCoordinates(String token, BuildContext context) async {

        try {
          String urLoc = 'https://apiubitransport.iancarina.com.ve/locations';
          final response = await http.get(Uri.parse(urLoc), headers: {'Authorization':'Bearer $token'});

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if(data != null && data is List) {
              List<Vehicle> vehicles = [];
              for (final v in data) {
                Vehicle vehicle = Vehicle(
                  codSocio: v['cod_socio'], 
                  placa: v['placa'], 
                  latitud: v['latitud'],
                  longitud: v['longitud'],
                  parada: v['parada'],
                  ticket_entrada: v['ticket_entrada'],
                  fecha_ticket: v['fecha_ticket'],
                  orden_carga: v['orden_carga'],
                  tipo_viaje: v['tipo_viaje'],
                  estatus_vehicle: v['estatus_vehicle'],
                );

                if(vehicle.parada != 'No posee') vehicles.add(vehicle);
              
              }
              return vehicles; // Devuelve la lista de vehículos
            }
            else{
              return [];
            }
          }
            else{
            globalFunctions.errorDialog('Error solicitando coordenadas', context);
            return [];
            }
          
        } catch (e) {
          // Manejar otros posibles errores aquí
          globalFunctions.errorDialog('Error: $e', context);
          throw []; // Devuelve una lista vacía o maneja el error de otra manera
        }
}
 
  //Funcion que obtiene todos los tickets de la base de datos Nevada dependiendo de los permisos del usuario
  Future<List<StopVehicle>> getStops(BuildContext context, String companyId, String userId) async{
        
        try{
          String urLoc = 'http://0.0.0.0:8000/location/stop/allticketsadmin/$companyId/$userId';
          final response = await http.get(Uri.parse(urLoc),);
          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data != null && data is List) {
              List<StopVehicle> vehicles = [];
              for (final v in data) {
                String placa ='no posee';
                String parada ='no posee';
                String ticket_entrada ='no posee';
                String fecha_ticket ='no posee';
                String orden_carga ='no posee';
                String tipo_viaje ='no posee';
                String estatus_vehicle ='no posee';
                String status_parada ='no posee';
                String dateScanner ='no posee';
                String point_control_id ='no posee';
                String guia_insai = 'no posee';
                String turno ='no posee';
                String detalle_guia = 'no posee';
                String nombre_productor = 'no posee';
                bool es_materia_prima = false;

                if(v['placa'] != null){
                  placa = v['placa'];
                }

                if(v['parada'] != null){
                  parada = v['parada'];
                }
                if(v['ticket_entrada'] != null){
                  ticket_entrada = v['ticket_entrada'];
                }
                if(v['fecha_ticket'] != null){
                  fecha_ticket = v['fecha_ticket'];
                }
                if(v['orden_carga'] != null){
                  orden_carga = v['orden_carga'];
                }
                if(v['tipo_viaje'] != null){
                  tipo_viaje = v['tipo_viaje'];
                }
                if(v['estatus_vehicle'] != null){
                  estatus_vehicle = v['estatus_vehicle'];
                }
                if(v['status_parada'] != null){
                  status_parada = v['status_parada'];
                }
                if(v['dateScanner'] != null){
                  dateScanner = v['dateScanner'];
                }
                
                if(v['guia_insai'] != null){
                  guia_insai = v['guia_insai'];
                }

                if(v['tp_point_control_id'] != null){
                  point_control_id = v['tp_point_control_id'];
                }

                if(v['turno'] != null){
                  turno = v['turno'];
                }

                if(v['detalle_guia'] != null){
                  detalle_guia = v['detalle_guia'];
                }

                if(v['nombre_productor'] != null){
                  nombre_productor = v['nombre_productor'];
                }

                es_materia_prima = v['es_materia_prima'];

                StopVehicle vehicle = StopVehicle(
                  placa: placa, 
                  parada: parada,
                  ticket_entrada: ticket_entrada,
                  fecha_ticket: fecha_ticket,
                  orden_carga: orden_carga,
                  tipo_viaje: tipo_viaje,
                  estatus_vehicle: estatus_vehicle,
                  status_parada: status_parada,
                  total_time: dateScanner,
                  point_control_id: point_control_id, 
                  guia_insai: guia_insai,
                  turno: turno,
                  detalle_guia: detalle_guia,
                  nombre_productor: nombre_productor,
                  es_materia_prima: es_materia_prima
                );
                if(vehicle.parada != 'No posee' && vehicle.status_parada != 'transito'){
                  print(vehicle.point_control_id +' '+ vehicle.guia_insai + ' '+vehicle.ticket_entrada);
                  vehicles.add(vehicle);
                } 
              } 

              return vehicles; // Devuelve la lista de vehículos
            }
            else{
              return [];
            }
          }
          else{
          globalFunctions.errorDialog('Error solicitando coordenadas', context);
          return [];
          }
          
        } catch (e) {
          // Manejar otros posibles errores aquí
          globalFunctions.errorDialog('Error: $e', context);
          throw []; // Devuelve una lista vacía o maneja el error de otra manera
        }
}
  
  //funcion que agrega Latitud y longitud dependiendo del ID del poligono que tenga el ticket
  Future<List<StopVehicle>> addLatLong(BuildContext context, List<StopVehicle> vehicles, String companyId) async {
  GlobalFunctions globalFunctions = GlobalFunctions();
  
  try{
    String urLoc = 'http://0.0.0.0:8000/getPolygons/$companyId';
    final response = await http.get(Uri.parse(urLoc));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data is List) {
        List<StopVehicle> finalVehicles = [];

        for (final v in data) {
          String polygon_id = v['tp_point_control_id'];
          List<StopVehicle> vehiclesFiltered = vehicles.where((vehicle) => vehicle.point_control_id == polygon_id).toList();
          int lengthVehicles = vehiclesFiltered.length;
          if (vehiclesFiltered.isEmpty) {
            print('No existen tickets en el polígono: ' + v['tp_point_control_id']);
          } else {
            try{
              String urLoc = 'http://0.0.0.0:8000/getPositionsPolygons/$polygon_id/$lengthVehicles';
              print(urLoc);
              final response2 = await http.get(Uri.parse(urLoc));

              if (response2.statusCode == 200) {
                final data2 = json.decode(response2.body);

                if (data2 != null && data2 is List) {
                  // Itera sobre los vehículos filtrados y asigna latitud y longitud según su índice
                  for (var entry in vehiclesFiltered.asMap().entries) {
                    int index = entry.key;
                    StopVehicle stopVehicle = entry.value;
                    print(stopVehicle.ticket_entrada);
                    if (index < data2.length) {
                      String lat = data2[index]['latitud'];
                      String long = data2[index]['longitud'];

                      if(data2[index]['tp_point_control_id'] == stopVehicle.point_control_id){
                        stopVehicle.latitud = lat;
                        stopVehicle.longitud = long;
                        finalVehicles.add(stopVehicle);}

                    } else {
                      print('No hay suficientes posiciones para asignar a todos los vehículos.');
                    }
                  }
                }
              } else {
                print('No hay posiciones para hacer polígono.');
              }
            } catch (e) {
              globalFunctions.errorDialog('Error: $e', context);
              throw [];
            }
          }
        }

        return finalVehicles; // Devuelve la lista de vehículos con latitud y longitud asignada
      } else {
        return [];
      }
    } else {
      globalFunctions.errorDialog('Error solicitando coordenadas', context);
      return [];
    }
  } catch (e) {
    globalFunctions.errorDialog('Error: $e', context);
    throw []; // Manejo de errores, devuelve lista vacía o maneja el error como prefieras
  }
}
  
  //Crea los marcadores a partir de los tickets.
  List<Marker?> buildMarkersFromCoordinates(List<Vehicle> coordinates, BuildContext context) {

    return coordinates.map((coordenada) {
      String codSocio = coordenada.codSocio; 
      String placa = coordenada.placa; 
      double? lat = double.tryParse(coordenada.latitud);
      double? lon = double.tryParse(coordenada.longitud);
      String parada = coordenada.parada;
      String ticket_entrada = coordenada.ticket_entrada;
      String fecha_ticket = coordenada.fecha_ticket;
      String orden_carga = coordenada.orden_carga;
      String tipo_viaje = coordenada.tipo_viaje;
      String estatus_vehicle = coordenada.estatus_vehicle;
      if(lat != null && lon != null && (lat >= -90 && lat <= 90) && (lon >= -180 && lon <= 180)){
          
          return Marker(
            rotate: true,
            width: 80.0,
            height: 80.0,
            point: LatLng(lat, lon),
            child: GestureDetector(
              onTap: () { 
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: const Text('Información del Vehiculo', textAlign: TextAlign.center),
                      content: Container(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          Row(
                            children: [
                              Text('Código Socio: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,),),
                              Text(codSocio, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Placa: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(placa, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Parada: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(parada, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Ticket de Entrada: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(ticket_entrada, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Fecha de Ticket: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(fecha_ticket, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Orden de Carga: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(orden_carga, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Tipo Viaje: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(tipo_viaje, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Estatus Vehicle: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(estatus_vehicle, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Tiempo Total Transcurrido: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text('{$tiempoTranscurrido : $tiempoTranscurrido ? N/A}', textAlign: TextAlign.left),
                            ],
                          ),
                        ],
                        ),
                      ),
                  actions:[
                    TextButton(
                      onPressed:(){
                        Navigator.of(context).pop();
                      },
                      child: Text('Cerrar'),
                    ),
                  ],
              );
            },
          );
          },
            child: Transform.rotate(angle: 100, 
            child:const Image(
                  image: AssetImage('lib/assets/chuto.png',), 
                  width: 40,
                  height: 40,
                  ), 
            ),  
                  ),
          
        );
      }else{
        return null;
      }}).toList();
  }
}