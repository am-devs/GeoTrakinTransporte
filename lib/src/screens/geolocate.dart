import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocateapp/src/services/locateServices.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocateScreen extends StatefulWidget{
  final Map<String, dynamic> datos;
  final String token;

  GeoLocateScreen({required this.datos, required this.token});
  
   @override
  _GeoLocateScreenState createState() => _GeoLocateScreenState(datos: datos, token: token);
}
  //pantalla que obtiene la posicion del chofer y la muestra
  class _GeoLocateScreenState extends State<GeoLocateScreen>{
  final Map<String, dynamic> datos;
  final String token;
  late Timer timer;
  _GeoLocateScreenState({required this.datos, required  this.token});
  StreamSubscription<Position>? positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    obtenerPermisosYUbicacion();
    // Inicia el temporizador para actualizar la posición cada 5 segundos
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      obtenerYMostrarPosicion();
    });
  }
              
  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    timer.cancel();
    super.dispose();
  }

    Future<void> obtenerPermisosYUbicacion() async {
      var status = await Permission.location.status;
      var services = false;
      LocateServices servicesLocate = LocateServices();
       try{
        bool  status_services = await servicesLocate.statusServices();
        if (status_services)  services=true; 
        }catch(error){
          _mostrarDialogo(context, error);
        }

      if (status.isGranted && services) {
        // Permiso concedido, puedes obtener la ubicación
        obtenerYMostrarPosicion();
      } else {
        // Si el permiso no está concedido, solicítalo
        await Permission.location.request();
      }
    }


  Future<void> obtenerYMostrarPosicion()async{
    final String url = 'https://apiubitransport.iancarina.com.ve/ubicacion';
    var error ='Error de conexión. Verifica la placa ingresada.';
      try{
        LocateServices servicesLocate = LocateServices();
        //NevadaConn nevadaConn = NevadaConn();
        positionStreamSubscription?.cancel();
        positionStreamSubscription = servicesLocate.getPositionStream().listen((Position position){
        print('Posición: ${position.latitude}, ${position.longitude}');
        setState(() {
          datos['latitud'] = position.latitude;
          datos['longitud'] = position.longitude;
        });
      });

      } catch (error) {
        
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error al obtener la posición', style: TextStyle(color: Colors.white),),
            backgroundColor: const Color.fromARGB(255, 207, 23, 9),
            content: Text(error.toString(), style:TextStyle(color: Colors.white),),
            actions: [
              TextButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 207, 23, 9), // Color del botón
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  child: Text('OK'),
                  ),
            ],
          );
        },
      );
    }
    var date = DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
    final http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':'Bearer $token'
        },
        body: jsonEncode(<String, String>{
            'cod_socio': datos['code'],
            'nombre_socio': datos['username'],
            'placa': datos['plate_vehicle'],
            'latitud': datos['latitud'].toString(),
            'longitud': datos['longitud'].toString(),
            'fecha': date.toString()
          }),
          );
        print(response.body);
       Map<String, dynamic> bodyrequest = json.decode(response.body);
        if(response.statusCode == 200){
          print(bodyrequest); 
        }
        if(response.statusCode != 200) {
          error = bodyrequest['detail'].toString();
          showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color.fromARGB(255, 189, 180, 180),
            title: Text('Error', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
            content: Text(error, style: TextStyle(color: Colors.white),),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 207, 23, 9),// Color del botón
              ),
                onPressed: () => Navigator.pop(context),
                child: Text('Aceptar', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
          );
          }
    }
    
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GeoLocalización', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 207, 23, 9),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              _mostrarDialogoSalir(context);
            },
          ),
        ],
      ),
      
      body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 65.0),
                child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      ListTile(
                         title: Text(
                        'Código de Socio: ${datos['code']}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nombre de Socio: ${datos['username']}', style: TextStyle(fontSize: 16.0)),
                          Text('Placa: ${datos['plate_vehicle']}', style: TextStyle(fontSize: 16.0)),
                          Text('Latitud: ${datos['latitud']}', style: TextStyle(fontSize: 16.0)),
                          Text('Longitud: ${datos['longitud']}', style: TextStyle(fontSize: 16.0)),
                        ],
                      ),
                      )
                    ],
                ), 
                ),
              ),
              ],
            ),
        );
  }

  }

  void _mostrarDialogo(BuildContext context, error) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,),
              backgroundColor: Color.fromARGB(255, 189, 180, 180),
              content: Text('$error'),
              actions: [
                TextButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 207, 23, 9), // Color del botón
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }

  Future<void> _mostrarDialogoSalir(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera del diálogo
      builder: (BuildContext context) {
        return AlertDialog(
        title: Text(
          '¿Realmente quieres salir?',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromARGB(255, 189, 180, 180),
        content: ButtonBar(
          alignment: MainAxisAlignment.center, // Centra los botones
          children: [
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 207, 23, 9), // Color del botón
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              // Color del botón
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 207, 23, 9), // Color del botón
              ),
              child: Text(
                'Salir',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                SystemNavigator.pop();// Cierra la App
              },
            ),
          ],
        ),
      );
      },
      );
    }


 