import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocateapp/src/models/coordinatesFunctions.dart';
import 'package:geolocateapp/src/models/globalFunctions.dart';
import 'package:geolocateapp/src/models/polygons.dart';
import 'package:geolocateapp/src/models/vehicle.dart';
import 'package:geolocateapp/src/screens/menu.dart';
import 'package:latlong2/latlong.dart';
//import 'package:flutter_map_geojson/flutter_map_geojson.dart';

//Pantalla que muestra los vehiculos en el mapa 

class StopsScreen extends StatefulWidget {
   final Map<String, dynamic> datos;
   final String userId;
   final String companyId;
   final double centerlat;
   final double centerlong;
   
   StopsScreen({required this.datos, required this.userId, required this.companyId, required this.centerlat,
   required this.centerlong});
   
   @override
  _StopsScreenState createState() => _StopsScreenState(datos: datos, userId: userId, companyId: companyId, centerlat:centerlat,
  centerlong:centerlong);
  }


class _StopsScreenState  extends State<StopsScreen> {
  List<StopVehicle> vehicles = []; 
  List<Map<String, dynamic>> poligonos = [];
  final Map<String, dynamic> datos;
  final String userId;
  final String companyId;
  final double centerlat;
  final double centerlong;
  PolygonsIancarina listPoly = PolygonsIancarina();
  List<Polygon> listPolyNew = [];
  GlobalFunctions globalFunctions = GlobalFunctions();
  CoordinatesFunctions coordinatesFunctions = CoordinatesFunctions();
  StopsFunctions stopsFunctions = StopsFunctions();
  List<int> totalsVehicles =[];
  String mapboxAccessToken='pk.eyJ1Ijoib3N3YWxkb20iLCJhIjoiY20wbWdwaWMxMDI4czJqcTJtNGxvYTc2OCJ9.0e4G333TM6R-UPrzE_863A';
  late Timer _timer;
 
  
  _StopsScreenState({required this.datos, required this.userId, required this.companyId, required this.centerlat,
   required this.centerlong});
  @override
  void initState() {
    super.initState();
    _getPolygons();
    // Iniciar un temporizador para actualizar los marcadores cada 30 segundos
    _timer = Timer.periodic(Duration(seconds: 20), (timer) {
    // Llamar a la función para obtener las coordenadas de la API
      //_updateData();
      if (mounted) {  // Verificar si el widget sigue montado
        _updateMarkers();
        _getPolygons();
      }
      
    });
  }
  //funcion que actualiza la informacion de la tabla de ticket_stop
  //es decir, actualiza la data que se mostrara en el mapa
  void  _updateData() async{
    try{
          String urLoc = 'http://0.0.0.0:8000/getcodescanners/';
          final response = await http.get(Uri.parse(urLoc),);

          if(response.statusCode == 200){
            final data = json.decode(response.body);

            if (data != null && data is List) {
                print('Sincronizacion Satisfactoria');
            // Devuelve la lista de vehículos
            }
            else{
              print('no hay data por sincronizar');
            }
          }

          else{
              print('error al realizar la sincronizacion');
          }
          
        }
        catch (e){
         print('Error: $e');
        }
  }
  //funcion que obtiene los poligonos de la compañia a mostrar y los actualiza tambien.
  void _getPolygons() async{
    List<Polygon> newPolygons = await listPoly.getPolygonsNew(context, companyId, userId);
    setState((){
      listPolyNew = newPolygons;
    });
  }
  
  // Función para actualizar los marcadores
  void _updateMarkers() async {
    // Llamar a la función para obtener las coordenadas de la API
    List<StopVehicle> newVehicles = await coordinatesFunctions.getStops(context, companyId, userId);
    newVehicles = await coordinatesFunctions.addLatLong(context, newVehicles,companyId);
    // Actualizar el estado con los nuevos vehículos obtenidos
    setState(() {
      vehicles = newVehicles;
    });
  }

  @override
  void dispose(){
    // Cancelar el temporizador cuando el widget es desmontado
    _timer?.cancel();
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      double topMargin = screenHeight * 0.05; 
      double rightMargin = screenWidth * 0.05;
      final myPosition= LatLng(centerlat, centerlong);
      return Scaffold(
      appBar: AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            // Utiliza Navigator.pop para regresar al widget anterior
            Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MenuScreen(datos: datos)),
                      );
          },
        ),
      title: Text('Geolocalizacion', style: TextStyle(color: Colors.white),),
      backgroundColor: const Color.fromARGB(255, 207, 23, 9),
      centerTitle: true,
      actions:[
        IconButton(
          icon: Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: () {
            globalFunctions.mostrarDialogoSalir(context);
          },
        ),
      ],
    ),
    body:  
    Stack(
      children: [
         FlutterMap(
            options: MapOptions(
              initialCenter:myPosition,
              minZoom: 5,
              maxZoom: 25,
              initialZoom: 19.50,
              //initialRotation: 30,
            ),
            children:[
              TileLayer(
                urlTemplate:
                    //'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken',
                    ),
                    PolygonLayer(polygons: listPolyNew),      
                    MarkerLayer(
                          markers: stopsFunctions.buildMarkersStops(vehicles, context)
                          .whereType<Marker>().toList(),
                        ),
            ],
            ),
            Positioned(
              top: topMargin,
              right: rightMargin,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white.withOpacity(0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('lib/assets/chutoPaddy.png', width: 30),
                        SizedBox(width: 5),
                        Text('PADDY'),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Image.asset('lib/assets/chuto.png', width: 30),
                        SizedBox(width: 5),
                        Text('Producto Terminado'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    ),

   
    );
  }
  }

