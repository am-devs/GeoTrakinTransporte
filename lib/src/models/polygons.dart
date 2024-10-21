import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocateapp/src/models/globalFunctions.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

//Clase con funciones para obtener los poligonos
class PolygonsIancarina {

  List<Polygon> polygons = [];
  //Funcion para obtener los poligonos dependiendo de la compañia
  Future<List<Polygon>> getPolygonsNew( BuildContext context, String companyId, String userId) async{
        GlobalFunctions globalFunctions = GlobalFunctions();
        try{
          String urLoc = 'http://0.0.0.0:8000/getPolygons/$companyId';
          final response = await http.get(Uri.parse(urLoc),);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data != null && data is List) {
              List<Polygon> polygons = [];
             
              for (final v in data) {
                String labelString = v['name']+'('+v['total_vehicles']+')';
                Polygon polygon = Polygon(
                  label: labelString,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  isFilled: true,
                  color: Colors.green.withOpacity(0.5),
                  borderColor: Colors.green.withOpacity(0.5),
                  borderStrokeWidth: 2,
                  points: [
                    LatLng(double.parse(v['latitud1']),double.parse(v['longitud1'])),
                    LatLng(double.parse(v['latitud2']),double.parse(v['longitud2'])),
                    LatLng(double.parse(v['latitud3']),double.parse(v['longitud3'])),
                    LatLng(double.parse(v['latitud4']),double.parse(v['longitud4'])),
                    LatLng(double.parse(v['latitud5']),double.parse(v['longitud5'])),
                  ], 
                );
                polygons.add(polygon);
              } 
              return polygons; // Devuelve la lista de vehículos
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
   //Funcion para obtener los poligonos de Iancarina(no se usa)
   List<Polygon>getPolygons(){
    
    polygons.add(
      Polygon(
        label: 'Planta 1',
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        isFilled: true,
        color: Colors.green.withOpacity(0.5),
        borderColor: const Color.fromARGB(255, 63, 61, 61),
        borderStrokeWidth: 2,
        points: [
          LatLng(9.527378433555938,-69.24939353110307),
          LatLng(9.528200033993471,-69.249897087125),
          LatLng(9.527934920582794,-69.25035833352148),
          LatLng(9.527113529074484,-69.24981789597004),
          LatLng(9.527378433555938,-69.24939353110307),
        ],
      ),
    );
    polygons.add(
      Polygon(
        label: 'Vigilancia P2',
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        isFilled: true,
        color: Colors.green.withOpacity(0.5),
        borderColor: const Color.fromARGB(255, 63, 61, 61),
        borderStrokeWidth: 2,
        points: [
          LatLng(9.529262613397748,-69.24678744588802),
          LatLng(9.529659696788372,-69.2470447932341),
          LatLng(9.529214568399098,-69.24774688485712),
          LatLng(9.528829458753435,-69.24748592612538),
          LatLng(9.529262613397748,-69.24678744588802),
        ],
      ),
    );
    polygons.add(
      Polygon(
        label: 'Vigilancia',
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        isFilled: true,
        color: Colors.green.withOpacity(0.5),
        borderColor: const Color.fromARGB(255, 63, 61, 61),
        borderStrokeWidth: 2,
        points: [
          LatLng(9.527639489018668,-69.24902002495811),
          LatLng(9.527385348374025,-69.2488511168912),
          LatLng(9.527668622041617,-69.24836349621125),
          LatLng(9.527934358111892,-69.24852976298996),
          LatLng(9.527639489018668,-69.24902002495811),
        ],
      ),
    );
    polygons.add(
      Polygon(
        label: 'Patio Externo',
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        isFilled: true,
        color: Colors.green.withOpacity(0.5),
        borderColor: const Color.fromARGB(255, 63, 61, 61),
        borderStrokeWidth: 2,
        points: [
          LatLng(9.52676891107609, -69.24910760177232),
          LatLng(9.525700898963265,-69.248375890593),
          LatLng( 9.526491126142815,-69.24710957898282),
          LatLng(9.527568212969243, -69.24780015733367),
          LatLng(9.52676891107609,-69.24910760177232),
        ],
      ),
    );
    polygons.add(
      Polygon(
        label: 'Romana',
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        isFilled: true,
        color: Colors.green.withOpacity(0.5),
        borderColor: const Color.fromARGB(255, 63, 61, 61),
        borderStrokeWidth: 2,
        points: [
          LatLng(9.527867966924205,-69.24966279835459),
          LatLng(9.52744421970749,-69.24941659402167),
          LatLng(9.527632236930828,-69.24910300451704),
          LatLng(9.528064405422157,-69.24936034458538),
          LatLng(9.527867966924205,-69.24966279835459),
        ],
      ),
    );
    // polygons.add(
    //   Polygon(
    //     label: 'Planta 5',
    //     labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    //     isFilled: true,
    //     color: Colors.green.withOpacity(0.5),
    //     borderColor: const Color.fromARGB(255, 63, 61, 61),
    //     borderStrokeWidth: 2,
    //     points: [
    //       LatLng(9.526897704067096, -69.24970664870037),
    //       LatLng(9.526585670617195, -69.24949414321715),
    //       LatLng(9.52678593092375, -69.2491706626492),
    //       LatLng(9.527079335347366, -69.24939497399224),
    //       LatLng(9.526897704067096, -69.24970664870037),
    //     ],
    //   ),
    // );
     polygons.add(
      Polygon(
        label: 'Taller',
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        isFilled: true,
        color: Colors.red.withOpacity(0.5),
        borderColor: Colors.red,
        borderStrokeWidth: 2,
        points: [
          LatLng(9.527771903396058, -69.24779548701251),
          LatLng(9.526903697065677, -69.2472794692693),
          LatLng(9.527305064018535, -69.2466594640743),
          LatLng(9.52814529326902, -69.24719797234727),
          LatLng(9.527771903396058, -69.24779548701251),
        ],
      ),
    );
    polygons.add(
      Polygon(
        label: 'Planta 4',
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        color: Colors.green.withOpacity(0.5),
        isFilled: true,
        borderColor: const Color.fromARGB(255, 63, 61, 61),
        borderStrokeWidth: 2,
        points: [
          LatLng(9.52824567455157, -69.24720657057077),
          LatLng(9.527313109707137, -69.24663173665526),
          LatLng(9.527696587384128, -69.24603811943709),
          LatLng(9.528614102699294, -69.24661783545882),
          LatLng(9.52824567455157, -69.24720657057077),
        ],
        
      ),
    );
    polygons.add(
      Polygon(
        label: 'Planta 2',
        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        color: Colors.green.withOpacity(0.5),
        isFilled: true,
         borderColor: const Color.fromARGB(255, 63, 61, 61),
        borderStrokeWidth: 2,
        points: [
          LatLng(9.528852967633739, -69.24550727635732),
          LatLng(9.528375891966363, -69.24519709290462),
          LatLng(9.528945066740619, -69.24426515045718),
          LatLng(9.529408337154578, -69.24457020552293),
          LatLng(9.528852967633739, -69.24550727635732),
        ],
      ),
    );
    // polygons.add(
    //   Polygon(
    //     label: 'Planta 3',
    //     labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    //     color: Colors.green.withOpacity(0.5),
    //     isFilled: true,
    //     borderColor: const Color.fromARGB(255, 63, 61, 61),
    //     borderStrokeWidth: 2,
    //     points: [
    //       LatLng(9.52989891868188, -69.24566502896867),
    //       LatLng(9.529151406378674, -69.24516247906584),
    //       LatLng(9.529533421167045, -69.24455025459594),
    //       LatLng(9.530294991256, -69.2450190112014),
    //       LatLng(9.52989891868188, -69.24566502896867),
    //     ],
    //   ),
    // );

    return polygons;

  }


}