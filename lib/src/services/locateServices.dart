import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocateServices{
  ///Determina la posicion actual del dispositivo
  ///Cuando los servicios de localizacion no estan disponibles o los permisos son denegados
  ///El Futuro devuelve un Error
    Future<bool> statusServices() async{
    bool serviceEnabled;
    LocationPermission permission;

    // Prueba si la localizacion esta disponible
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // si la localizacion no esta disponible no puede seguir
      // accecidendo a la posicion y peticiones del usuario de la
      // aplicacion para permitir servicios de localizacion
      return Future.error('Servicio de localizacion no disponible.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Denegado permiso de Localizacion');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Permiso de localizacion permanentemente denegado.');
    }

    return serviceEnabled;
  }  

//stream que toma la posicion del dispositivo
    Stream<Position> getPositionStream() {
      try {
      return Geolocator.getPositionStream(
        desiredAccuracy: LocationAccuracy.high,
        distanceFilter: 1,
        intervalDuration: const Duration(seconds: 20),
        forceAndroidLocationManager: true,
      );
    } catch (error) {
      print('Error en la obtención de la posición: $error');
      throw error;
    }
    }
}