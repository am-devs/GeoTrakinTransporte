import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocateapp/src/models/globalFunctions.dart';
import 'package:geolocateapp/src/screens/admin.dart';
import 'package:geolocateapp/src/screens/stops.dart';
import 'package:geolocateapp/src/screens/transit.dart';
import 'package:geolocateapp/src/models/vehicle.dart';
import 'package:http/http.dart' as http;

//Pantalla de Menu principal
class MenuScreen extends StatefulWidget {
   final Map<String, dynamic> datos;
   MenuScreen({required this.datos});

  @override
  _MenuScreenState createState() => _MenuScreenState(datos: datos);
}

class _MenuScreenState extends State<MenuScreen> {
  final Map<String, dynamic> datos;
  List<data_company> companies = [];
  GlobalFunctions globalFunctions =GlobalFunctions(); 
  String userId = '';
  _MenuScreenState({required this.datos});

  @override
  void initState() {
    super.initState();

    // Usa Future.delayed para asegurarte de que el widget esté completamente construido
    Future.delayed(Duration.zero, () {
      _updateMarkers();
    });
  }
  //funcuion que actualiza los marcadores
  void _updateMarkers() async {
    // Llamar a la función para obtener las coordenadas de la API
    List<data_company> newCompanies = await getCompanies(context);
    // Actualizar el estado con los nuevos vehículos obtenidos
    setState(() {
      companies = newCompanies;
    });
    }

  //funcion que obtiene las compañias que tiene permiso el usuario
  Future<List<data_company>> getCompanies(BuildContext context) async {
  try{ 
     userId = datos['id'].toString();
    
    String urLoc = 'http://0.0.0.0:8000/getCompanies/$userId';
    final response = await http.get(Uri.parse(urLoc),);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('BODY: ' + response.body);
      if (data != null && data is List) {
        List<data_company> companies = [];
        for (final v in data) {
          data_company company = data_company(
            companyId: v['company_id'], 
            name: v['name'], 
            latitud:  double.parse(v['latitud']),
            longitud: double.parse(v['longitud']),
          );
          companies.add(company);
         
        }
        return companies; // Devuelve la lista de vehículos
      } else {
        return [];
      }
    } else {
      globalFunctions.errorDialog('Error al obtener las compañías', context);
      return [];
    }
  } catch (e) {
    // Manejar otros posibles errores aquí
    globalFunctions.errorDialog('Error: $e', context);
    return []; // Devuelve una lista vacía o maneja el error de otra manera
  }
  }
  


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color.fromARGB(255, 189, 180, 180),
    appBar: AppBar(
      title: const Text(
        'Menu Administrador',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 207, 23, 9),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: companies.map((company) {
                return Container(
                  width: 800, // Establece el ancho que desees
                  child: Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute( 
                            builder: (context) => StopsScreen(datos: datos, userId: userId, 
                            companyId: company.companyId, centerlat: company.latitud, centerlong:company.longitud,),
                         ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_rounded,
                              size: 100,
                              color: Color.fromARGB(255, 207, 23, 9),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'MAPA ${company.name}',
                              style: TextStyle(fontSize: 40),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  ),
  );
}
  
}

