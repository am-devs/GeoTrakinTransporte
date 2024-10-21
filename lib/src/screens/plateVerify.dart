import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocateapp/src/screens/geolocate.dart';
import 'package:http/http.dart' as http;
//Pantalla de Login para los choferes.
//esta pantalla esta en desuso ya que era cuando el proyecto tenia el alcance de que el chofer enviara su ubicacion.
class PlateScreen extends StatefulWidget {
  final String token;
  const PlateScreen({required this.token});

  @override
  _PlateScreenState createState() => _PlateScreenState(token: token);
}
class _PlateScreenState extends State<PlateScreen> {
  final TextEditingController _plateController = TextEditingController();
  late final String token;
  _PlateScreenState({required  this.token});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 189, 180, 180),
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 207, 23, 9),
        centerTitle: true,
      ),
      body: 
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Container(
              margin: EdgeInsets.only(top: 70.0),
              child: const Image(
                image: AssetImage('lib/assets/MaryLogo-removebg-preview.png'), 
                width: 200,
                height: 200,
                alignment: Alignment.topCenter,),
                ),
            TextField(
              controller: _plateController,
              cursorColor: Colors.white,
              textAlign: TextAlign.center,
              style: const TextStyle(
              color: Colors.white, // Cambia el color del texto ingresado
            ),
              decoration: const InputDecoration(
                labelText: 'Ingrese Placa del Vehiculo',
                labelStyle: TextStyle(color: Colors.white),
                floatingLabelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white), 
                  ),
                enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
                fillColor: Colors.white,
            ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loginPlate(),
              style: ElevatedButton.styleFrom(
              backgroundColor:Color.fromARGB(255, 207, 23, 9),// Color del botón
            ),
              child: const Text('Iniciar sesión', 
              style: TextStyle(
              color: Colors.white, // Color del texto
            ),),
            ),
          ],
        ),
      ),
    );
  }

    errorDialog(error) async {
      return showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error', style: TextStyle(color: Colors.white),),
                  backgroundColor: const Color.fromARGB(255, 189, 180, 180),
                  content: Text(error.toString(), style:const TextStyle(color: Colors.white),),
                  actions: [
                    TextButton(
                        style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 207, 23, 9), // Color del botón
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Cierra el diálogo
                        },
                        child: const Text('OK', style: TextStyle(color: Colors.white),),
                        ),
                  ],
                );
        },
      );
    }
    _loginPlate() async {
      final String plate = _plateController.text;
      final String apiUrl = 'https://apiubitransport.iancarina.com.ve/platelog/$plate';
      try{

        final http.Response response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization':'Bearer $token'});

        if (response.statusCode == 200) {
        // Éxito: se obtuvo el token
        final Map<String, dynamic> responseData = json.decode(response.body);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GeoLocateScreen(datos:responseData, token: token,)),
          );
        }
        else {
              errorDialog('Error en la autenticación: ${response.statusCode}');
            }
      }catch (error){
              errorDialog(error);
            }
      }

      }