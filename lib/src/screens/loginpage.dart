import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocateapp/src/screens/menu.dart';
import 'package:geolocateapp/src/screens/plateVerify.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
//flutter run -d chrome --web-browser-flag "--disable-web-security" comando para correr en web sin restricciones de seguridad


//Pantalla de Login
class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late List<dynamic> datos = [];
  Map<String, dynamic> dataLog = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 189, 180, 180),
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 207, 23, 9),
        centerTitle: true,
      ),
      body: 
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Container(
              margin: const EdgeInsets.only(top: 70.0),
              child: const Image(
                image: AssetImage('lib/assets/MaryLogo-removebg-preview.png'), 
                width: 200,
                height: 200,
                alignment: Alignment.topCenter,),
                ),
            TextField(
              controller: _codeController,
              cursorColor: Colors.white,
              textAlign: TextAlign.center,
              style: const TextStyle(
              color: Colors.white, // Cambia el color del texto ingresado
            ),
              decoration: const InputDecoration(
                labelText: 'Usuario',
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
            TextField(
              controller: _passwordController,
              cursorColor: Colors.white,
              textAlign: TextAlign.center,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              style: const TextStyle(
              color: Colors.white, // Cambia el color del texto ingresado
            ),
              decoration: const InputDecoration(
                labelText: 'Clave',
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
              onPressed: () => _login(),
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
      //funcion que hace peticion de verificacion de usuario
      Future<void> _login() async{
      String username =_codeController.text;
      String password =_passwordController.text;
      //Request desde movil
      String apiUrl = 'http://0.0.0.0:8000/loginAdmin/$username/$password';
      var response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if(response.statusCode != 200){
              errorDialog('Error al ingresar al sistema, revise las credenciales.');
      }
      
      if(response.statusCode == 200){
          print('RESPUESTA: '+response.body);  
          List<dynamic> dataLogList = json.decode(response.body);
          dataLog = dataLogList[0];
          Navigator.pushReplacement(
              context,
            MaterialPageRoute(builder: (context) => MenuScreen(datos:dataLog,)),
          );

          if(response.statusCode != 200){
          errorDialog('Error al ingresar al sistema, revise las credenciales.');
          }
      }
      }
      errorDialog(String error) async{
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
      }