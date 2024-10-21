import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocateapp/src/models/coordinatesFunctions.dart';
import 'package:geolocateapp/src/models/globalFunctions.dart';
import 'package:geolocateapp/src/models/polygons.dart';
import 'package:geolocateapp/src/models/vehicle.dart';
import 'package:latlong2/latlong.dart';

//import 'package:flutter_map_geojson/flutter_map_geojson.dart';

//Pantalla que muestra el Mapa y los marcadores 
class AdminScreen extends StatefulWidget{
   final Map<String, dynamic> datos;
   final String token;
   AdminScreen({required this.datos, required this.token});
   
  @override
  _AdminScreenState createState() => _AdminScreenState(datos: datos, token: token);
}


class _AdminScreenState  extends State<AdminScreen> {
  List<Vehicle> vehicles = [];  
  List<Map<String, dynamic>> poligonos = [];
  final Map<String, dynamic> datos;
  final String token;
  PolygonsIancarina listPoly = PolygonsIancarina();
  GlobalFunctions globalFunctions = GlobalFunctions();
  CoordinatesFunctions coordinatesFunctions = CoordinatesFunctions();
  final myPosition= LatLng(9.5271464, -69.2489557);
  
  _AdminScreenState({required this.datos, required  this.token});
  
  @override
    Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
      title: Text('Geolocalización', style: TextStyle(color: Colors.white),),
      backgroundColor: const Color.fromARGB(255, 207, 23, 9),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: () {
            globalFunctions.mostrarDialogoSalir(context);
          },
        ),
      ],
    ),
    body: FutureBuilder(
      future: coordinatesFunctions.getCoordinates(token, context), 
      builder: (context, snapshot){
         if (snapshot.connectionState == ConnectionState.done) {
            List<Vehicle> coordinates = snapshot.data as List<Vehicle>;
            return  FlutterMap(
            options: MapOptions(
              initialCenter:myPosition,
              minZoom: 5,
              maxZoom: 25,
              initialZoom: 13,

            ),
            children:[
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                     // additionalOptions: const {
                        //'accessToken': MAPBOX_ACCESS_TOKEN,
                        //'id': 'impulse28.83qn5egk'
                     //},
                      ),
                PolygonLayer(polygons: listPoly.getPolygons()),      
                MarkerLayer(
                      markers: coordinatesFunctions.buildMarkersFromCoordinates(coordinates, context)
                       .whereType<Marker>().toList(),
                    ),
               
            ],
            );
         }  
        else {
        return SizedBox(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color.fromARGB(255, 207, 23, 9),),
                SizedBox(height: 10), // Ajusta el espacio vertical entre el círculo de progreso y el texto
                Text(
                  'Cargando...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
        }
      }
      )
      );
    }
}
