import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Funcion que crea Widgets paras usar en toda la APP en el momento que se necesiten
class GlobalFunctions {
  
  //Funcion que returna el widget showDialog para Salir de la APP
  Future<void> mostrarDialogoSalir(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //No se puede cerrar tocando fuera del diálogo
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
                primary: Color.fromARGB(255, 207, 23, 9), // Color del botón
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
                primary: Color.fromARGB(255, 207, 23, 9), // Color del botón
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


  //Funcion que returna el widget showDialog para mostrar ERROR
  errorDialog(String error, BuildContext context) async {
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