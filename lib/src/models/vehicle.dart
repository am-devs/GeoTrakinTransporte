import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocateapp/src/screens/view_route.dart';
import 'package:geolocateapp/src/screens/tableFuncts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocateapp/src/models/globalFunctions.dart';
import 'dart:convert';

//Archivo que tiene casi todos los modelos usados en la APP

class Vehicle {
  final String codSocio;
  final String placa;
  final String latitud;
  final String longitud;
  final String parada;
  final String ticket_entrada;
  final String fecha_ticket;
  final String orden_carga;
  final String tipo_viaje;
  final String estatus_vehicle;

  Vehicle({
    required this.codSocio,
    required this.placa,
    required this.latitud,
    required this.longitud,
    required this.parada,
    required this.ticket_entrada,
    required this.fecha_ticket,
    required this.orden_carga,
    required this.tipo_viaje,
    required this.estatus_vehicle,
  });
}
 
class StopVehicle {
  final String placa;
  late String latitud;
  late String longitud;
  final String total_time;
  late double orientacion;
  final String parada;
  final String ticket_entrada;
  final String fecha_ticket;
  final String orden_carga;
  final String tipo_viaje;
  final String estatus_vehicle;
  final String status_parada;
  final String point_control_id;
  final String guia_insai;
  final String turno;
  final String detalle_guia;
  final String nombre_productor;
  final bool es_materia_prima;
  
  
  StopVehicle({
    required this.placa,
    required this.parada,
    required this.ticket_entrada,
    required this.fecha_ticket,
    required this.orden_carga,
    required this.tipo_viaje,
    required this.estatus_vehicle,
    required this.status_parada,
    required this.total_time,
    required this.point_control_id,
    required this.guia_insai,
    required this.turno,
    required this.detalle_guia,
    required this.nombre_productor,
    required this.es_materia_prima
  });
}



class ParadaData {
  final double latitud;
  final double longitud;
  final double orientacion;
  
  ParadaData(this.latitud, this.longitud, this.orientacion);
}

class data_company {
  final String companyId;
  final String name;
  final double latitud;
  final double longitud;
  
  data_company({required this.companyId, required this.name, required this.latitud,required this.longitud});
}

class ScanStatus {
  final String puntoEscanner;
  final String status;

  ScanStatus(this.puntoEscanner, this.status);
}

class StopsFunctions{
  GlobalFunctions globalFunctions = GlobalFunctions();
  HtmlFunct htmlfunct = HtmlFunct();
  
  //Funcion para crear marcadores desde una lista de tickets
  List<Marker?> buildMarkersStops(List<StopVehicle> coordinates,BuildContext context){
 
  //funcion para calcular el tiempo transcurrido por el recorrido del ticket 
  String calcularTiempoTranscurrido(String recorridoData){
  if (recorridoData.isEmpty) {
    return 'No hay tiempos registrados';
  }

  // Dividir la cadena en fecha y hora
  List<String> partes = recorridoData.split(', ');

  // Verificar si hay dos partes (fecha y hora)
  if (partes.length != 2) {
    return 'Formato de fecha y hora inválido';
  }

  // Analizar la parte de la fecha
  String fechaStr = partes[0];
  List<String> partesFecha = fechaStr.split('-');
  if (partesFecha.length != 3) {
    return 'Formato de fecha inválido';
  }

  int year = int.parse(partesFecha[2]);
  int month = int.parse(partesFecha[1]);
  int day = int.parse(partesFecha[0]);

  //Analizar la parte de la hora
  String horaStr = partes[1];
  List<String> partesHora = horaStr.split(':');
  if (partesHora.length != 3) {
    return 'Formato de hora inválido';
  }

  int hour = int.parse(partesHora[0]);
  int minute = int.parse(partesHora[1]);
  int second = int.parse(partesHora[2]);

  // Crear un objeto DateTime con la fecha y la hora
  DateTime tiempoInicial = DateTime(year, month, day, hour, minute, second);
  
  // Obtener el momento actual
  DateTime ahora = DateTime.now();
  
  // Calcular la diferencia de tiempo entre el primer tiempo y el momento actual
  Duration diferencia = ahora.difference(tiempoInicial);
  
  // Formatear la diferencia de tiempo como una cadena con dos dígitos para minutos y segundos
  String horas = diferencia.inHours.toString();
  String minutos = diferencia.inMinutes.remainder(60).toString().padLeft(2, '0');
  String segundos = diferencia.inSeconds.remainder(60).toString().padLeft(2, '0');
  String diferenciaFormateada = '$horas:$minutos:$segundos';
  
  return diferenciaFormateada;
}

  return coordinates.map((coordenada) {
      
      String placa = coordenada.placa;
      //String parada = coordenada.parada;
      String ticket_entrada = coordenada.ticket_entrada;
      String fecha_ticket = coordenada.fecha_ticket;
      String orden_carga = coordenada.orden_carga;
      String tipo_viaje = coordenada.tipo_viaje;
      String estatus_vehicle = coordenada.estatus_vehicle;
      String status_parada = coordenada.status_parada;
      String tiempo_total = coordenada.total_time;
      String guia_insai = coordenada.guia_insai;
      String turno = coordenada.turno;
      String detalle_guia = coordenada.detalle_guia;
      String nombre_productor = coordenada.nombre_productor;
      bool es_materia_prima = coordenada.es_materia_prima;
      String imagePath = es_materia_prima ? 'lib/assets/chutoPaddy.png' : 'lib/assets/chuto.png';
      
      coordenada.orientacion=100;
      String tiempoTranscurrido = calcularTiempoTranscurrido(tiempo_total);
      double? lat = double.tryParse(coordenada.latitud);
      double? lon = double.tryParse(coordenada.longitud);
     
      //paradaData = getListParada(paradaData, coordenada.status_parada, indiceParada);

       if (lat != null && lon != null && (lat >= -90 && lat <= 90) && (lon >= -180 && lon <= 180)) {
        Size screenSize = MediaQuery.of(context).size;
         return Marker(
            rotate: true,
            width: 40.0,
            height: 40.0,
            point: LatLng(lat, lon),
            child: Builder(
              builder:(context){
              return GestureDetector(
              onTap:  (){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    BuildContext alertDialogContext = context;
                    return AlertDialog(
                      title: const Text('Información del Vehiculo', textAlign: TextAlign.center),
                      content: Container(
                        child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          Row(
                           crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Turno: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(turno, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Placa: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(placa, textAlign: TextAlign.left),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     Text('Parada: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                          //     Text(parada, textAlign: TextAlign.left),
                          //   ],
                          // ),
                          Row(
                            children: [
                              Text('Ticket de Entrada: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(ticket_entrada, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Nro de Guia: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(guia_insai, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Detalle de Guia: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(detalle_guia, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Productor: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(nombre_productor, textAlign: TextAlign.left),
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
                              Text('Posicion Escaner: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(status_parada, textAlign: TextAlign.left),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Total Tiempo: ', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold,)),
                              Text(tiempoTranscurrido, textAlign: TextAlign.left),
                            ],
                          ),
                        ],
                        ),
                      ),
                  actions:[
                  ElevatedButton(
                  onPressed:(){
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text('Recorrido', textAlign: TextAlign.center),
                          contentPadding: EdgeInsets.zero,
                          content: Container(
                            width: 700, // Mantenemos el ancho fijo
                            height: 500, // Mantenemos la altura fija
                            child: Row(
                              children: <Widget>[
                                 Expanded(
                                  child: ListView(
                                    padding: EdgeInsets.only(top: 0), // Ajusta el espacio en la parte superior
                                    children: <Widget>[
                                      Center(
                                      child:
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido al inicio del eje transversal (superior)
                                        children: <Widget>[
                                          htmlfunct.tablePlanification(context, ticket_entrada),
                                        ],
                                      ),
                                      ),
                                    ],
                                  ),
                                ),
                                //Column(
                                //      children: <Widget>[
                                //        htmlfunct.tablaEstado(context, ticket_entrada, orden_carga),
                                //      ],
                                //    ),
                                  
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text('Recorrido'),
                ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cerrar'),
                    ),
                  ],
              );
            },
          );
          },
            child: Transform.rotate(angle: coordenada.orientacion, 
            child:Image(
                  image: AssetImage(imagePath, ), 
                  width: 40,
                  height: 40,
                  ), 
            ), 
                  );
              },

            ),
            
            
            
        );
    // Puedes agregar condiciones para otras paradas si es necesario
  }}).toList();
}

// void trackingVehicle(String ticket_entrada, String token, String orden_carga, context){
//   Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => RecorridoDialog(token: token, ticket: ticket_entrada, orden_carga:orden_carga,)),
//                       );
// }
void getListParada(StopVehicle vehicle, int index){
    List<ParadaData> listaromana=[
    ParadaData(9.527690997151893, -69.24946270581961, 210.0),
    ParadaData(9.527791589757882, -69.249274488535, 210.0),
    ParadaData( 9.52818521059703,-69.24950965246975, 210.0),
    ParadaData(9.528111403370815, -69.24970659900781, 210.0),
    ParadaData(9.528515400621956,  -69.24971841579996, 210.0),
    ParadaData(9.528433821145924, -69.24991536228032, 210.0),
];

List<ParadaData> listtaller=[
    ParadaData(9.52785124363642,  -69.24714682435737, 210.0), 
    ParadaData(9.527788464406854, -69.2473059606875, 210.0),
    ParadaData(9.527692222737443, -69.24748478555757, 210.0),
    ParadaData(9.527590702554093, -69.24766036069532, 210.0),
    ParadaData(9.527582861321164, -69.24697687673736, 210.0),
    ParadaData(9.527512877507348, -69.24713374157226, 210.0),
    ParadaData(9.527417110159945, -69.24732795517735, 210.0),
    ParadaData(9.527325026145476, -69.24752216878306, 210.0),
    ParadaData(9.527319423902298, -69.24678068362105, 210.0),
    ParadaData(9.527236146242657, -69.24694083296218, 210.0),
    ParadaData(9.5271413819856, -69.24715048300916, 210.0),
    ParadaData(9.527063847573842, -69.24733101499369, 210.0),
];

List<ParadaData> listavigilancia=[
    ParadaData(9.527661927775881,-69.24889537976912, 180.1), 
    ParadaData(9.527571056945902,-69.24883601262403, 180.1), 
    ParadaData(9.527785089959693,-69.24866663632129, 180.1), 
    ParadaData(9.527707545892099,-69.24859725806066, 180.1),
    ParadaData(9.527843533126713,-69.24838101306545, 180.1),
    ParadaData(9.527915356239305,-69.24844551765187, 180.1), 
    ParadaData(9.528063480895256,-69.24825305541299, 180.1), 
    ParadaData(9.527969084842212,-69.2481739852748, 180.1), 
    ParadaData(9.528168137446087,-69.24807410732572, 180.1), 
    ParadaData(9.528075793509771,-69.24800336035997, 180.1),
    ParadaData(9.528384574266155, -69.24825580923543, 210.0),
    ParadaData(9.52857776434763, -69.24835257177286, 210.0),
];

List<ParadaData> vigilancia2=[
    ParadaData(9.529307089029189,-69.24719369970107,1), 
    ParadaData(9.529180954963735,-69.24709421989942,1), 
    ParadaData(9.529172636050262,-69.24740166313963,1), 
    ParadaData(9.5290451018342,-69.24730871126889,1), 
    ParadaData( 9.529061410546419,-69.24758995858018,1), 
    ParadaData(9.528948149629372,-69.24752085831093,1), 
    ParadaData(9.528940139240618,-69.24778236150803,1), 
    ParadaData(9.52885271424634,-69.24771888063377,1), 
    ParadaData(9.528836953322084,-69.24795302556618,1), 
    ParadaData(9.528723902592176,-69.24788192298786,1),
    ParadaData(9.528729838964239,-69.24812690233279,1),
    ParadaData(9.528642234281023,-69.24807367320432,1),
];

List<ParadaData> listp1=[
    ParadaData(9.527343745480081, -69.24952691934908, 1.0),
    ParadaData(9.52744847121248,  -69.24959013529202, 1.0),
    ParadaData(9.527553196911938, -69.24965335123494, 1.0), 
    ParadaData(9.52765636118167, -69.24971696880911, 1.0),
    ParadaData(9.52776108681735, -69.24978018475127, 1.0),
    ParadaData(9.527865416330897, -69.2498418174571, 1.0),
    ParadaData(9.527970537993127, -69.2499066166371, 1.0),
    ParadaData(9.52807428478934, -69.24996924177634, 1.0),
    ParadaData(9.527207217833038, -69.24976172463055, 1.0),
    ParadaData(9.527414129204075, -69.24988796734388, 1.0),
    ParadaData(9.527310382207318, -69.24982534220467, 1.0),
    ParadaData(9.527521395057875, -69.24995137245855, 1.0),
    ParadaData(9.527626120734993, -69.2500145884015,1.0),
    ParadaData(9.52773026372681, -69.25007879677861, 1.0),
    ParadaData(9.527834010596749, -69.25014142191857, 1.0),
    ParadaData(9.52793873617793, -69.25020463786075, 1.0),
];

List<ParadaData> listp2=[
   ParadaData(9.529252857481268, -69.24450778081004, 210),
    ParadaData(9.529183912583022,  -69.24461965949084, 210),
    ParadaData(9.529114967670864, -69.2447315381716, 210),
    ParadaData(9.529046022744765, -69.24484341685243, 210),
    ParadaData(9.52897257153677, -69.24495628322227, 210),
    ParadaData(9.528909856475067,-69.24506437724732, 210),
    ParadaData(9.528836421399973,-69.24517721738958, 210),
    ParadaData(9.528769208020606,-69.2452862861563, 210),
    ParadaData(9.529017602028887,-69.24435723967811, 210),
    ParadaData(9.528942136853772,-69.2444673023071, 210),
    ParadaData(9.52887560265728,-69.24457526898223, 210),
    ParadaData(9.528807362441981,-69.2446860040334, 210),
    ParadaData(9.528737416206894,-69.24479950746053, 210),
    ParadaData(9.528671894839732,-69.2449120280959, 210),
    ParadaData(9.528596519682083,-69.2450219474404, 210),
    ParadaData(9.528529993234756,-69.2451299014315, 210),

 
];

List<ParadaData> listp3=[
    ParadaData(9.530094498410591, -69.24531623461966, 1.0), 
    ParadaData(9.529763438122686, -69.24595446726109, 1.0),
    ParadaData(9.530256520035763, -69.24442454515335, 1.0),
    ParadaData(9.530086495335127, -69.24434577693836, 1.0),
    ParadaData(9.529953976427649, -69.2442577129398, 1.0),
    ParadaData(9.530068952027165, -69.24488765054194, 1.0),
    ParadaData(9.52992409785773,  -69.24476668949566, 1.0),
    ParadaData(9.529783504045596, -69.24465436852488, 1.0),
    ParadaData(9.530290493580665, -69.24541901513592, 1.0),
    ParadaData(9.529941139315838, -69.24605838037785, 1.0),
    ParadaData(9.530473691082932, -69.2455356558587, 1.0),
    ParadaData(9.530132858048361, -69.24618366146154, 1.0),
];

List<ParadaData> listp4=[
    ParadaData(9.528123102897467, -69.24708032710242, 210.0), 
    ParadaData(9.528247406652568, -69.2468426467663, 210.0),  
    ParadaData(9.52835040115825, -69.24661937129957, 210.0),  
    ParadaData(9.527672057462993, -69.24678142607381, 210.0), 
    ParadaData(9.527821222160824, -69.24652934086944, 210.0), 
    ParadaData(9.527931319872152, -69.24632047027154, 210.0),
    ParadaData(9.528189937870152,  -69.24696211086955, 210.0),
    ParadaData(9.528314236934833, -69.24671003512626, 210.0),
    ParadaData(9.527884369141802,-69.24643695307164, 210.0),
    ParadaData( 9.527739353378934,-69.24667064829127, 210.0),
    ParadaData(9.528492916762517,-69.24645270780579, 210.0),
    ParadaData(9.528037153540183, -69.24615074207227, 210.0),

];
// List<ParadaData> listp5=[
//     ParadaData(9.526780738451876,-69.24958451216308, 100.0), 
//     ParadaData(9.526588597168214,-69.24944651964987, 100.0),
//     ParadaData(9.52673084286144,-69.24924141022854, 180.0),
//     ParadaData(9.526636969786779,-69.24992658296192, 1.0),
//     ParadaData(9.526467859099327,-69.24981965497327, 1.0),
// ];

List<ParadaData> listpatio=[
    ParadaData(9.527445568399244,-69.2477929251861, 100.0), 
    ParadaData(9.527385492399105,-69.24789041156026, 100.0),
    ParadaData(9.52732789157551,-69.24798938255319, 100.0),
    ParadaData(9.527265340367109,-69.24808538430852, 100.0),
    ParadaData(9.52720526433528,-69.24818287068264, 100.0),
    ParadaData(9.527145188292835,-69.24828035705679, 100.0),
    ParadaData(9.527085112239845,-69.24837784343025, 100.0),
    ParadaData(9.52702653807755,-69.24847289264528, 100.0),
    ParadaData(9.52696496010212,-69.24857281617855, 100.0),
    ParadaData(9.52690488401744,-69.24867030255268, 100.0),
    ParadaData(9.52714733560613,-69.24761401772874, 100.0),
    ParadaData(9.527089478677937,-69.24770790309393, 100.0),
    ParadaData(9.527031069809823,-69.24780805133327, 100.0),
    ParadaData(9.526970797769792,-69.24790048845796, 100.0),
    ParadaData(9.526909973788776,-69.24799918845679, 100.0),
    ParadaData( 9.526854514193047,-69.24809455081741, 100.0),
    ParadaData(9.526792776330197,-69.2481893665033, 100.0),
    ParadaData(9.526733435831034,-69.24828565918531, 100.0),
    ParadaData(9.526674095320217,-69.24838195186733, 100.0),
    ParadaData(9.526614754799112,-69.24847824454935, 100.0),
    ParadaData(9.526861959524112, -69.24744600127902, 100.0),
    ParadaData(9.526800955645882,-69.24753975291591, 100.0),
    ParadaData(9.526742321336982,-69.24763489965305, 100.0),
    ParadaData(9.526683687018064,-69.24773004639017, 100.0),
    ParadaData(9.526625052689027,-69.2478251931273, 100.0),
    ParadaData(9.52656641834993, -69.24792033986445, 100.0),
    ParadaData(9.526507784000728,-69.2480154866016, 100.0),
    ParadaData(9.526451478516833, -69.24811209449683, 100.0),
    ParadaData(9.526390515272183,-69.24820578007588, 100.0),
    ParadaData(9.526334198137988,-69.24830240684474, 100.0),
    ParadaData(9.526576298502334,-69.2472778172102, 100.0),
    ParadaData(9.526514935455026, -69.2473702121637, 100.0),
    ParadaData(9.526458675231865,-69.24746674349869, 100.0),
    ParadaData(9.526398586923449,-69.24756424956496, 100.0),
    ParadaData(9.526341429741379,-69.24765699923691, 100.0),
    ParadaData(9.526280467721818,-69.24775068591521, 100.0),
    ParadaData(9.526221850762994,-69.2478458043531, 100.0),
    ParadaData(9.526163233794122,-69.247940922791, 100.0),
    ParadaData(9.526104616815246,-69.24803604122884, 100.0),
    ParadaData(9.526049781410066,-69.24813026038589, 100.0),
    ParadaData(9.526292723308927,-69.24710979273742, 100.0),
    ParadaData(9.52623260622461,-69.24720312660428, 100.0),
    ParadaData(9.526176346098907,-69.24729965770346, 100.0),
    ParadaData(9.526115372280557,-69.24739336348, 100.0),
    ParadaData(9.526056755293396,-69.24748848191788, 100.0),
    ParadaData(9.525998138296202,-69.24758360035575, 100.0),
    ParadaData(9.525941854885161, -69.24768016917987, 100.0),
    ParadaData(9.525880904271617,-69.24777383723153, 100.0),
    ParadaData(9.525822287244225,-69.24786895566939, 100.0),
    ParadaData(9.525765986368128,-69.24796555278714, 100.0),
  ];

  if(vehicle.status_parada =="taller"){
     vehicle.latitud = listtaller[index].latitud.toString();
    vehicle.longitud = listtaller[index].longitud.toString();
    vehicle.orientacion = listtaller[index].orientacion;
  }

  if(vehicle.status_parada =="patio"){
     vehicle.latitud = listpatio[index].latitud.toString();
    vehicle.longitud = listpatio[index].longitud.toString();
    vehicle.orientacion = listpatio[index].orientacion;
  }

  if(vehicle.status_parada == 'vigilancia'){
    vehicle.latitud = listavigilancia[index].latitud.toString();
    vehicle.longitud = listavigilancia[index].longitud.toString();
    vehicle.orientacion = listavigilancia[index].orientacion;
  }

  if(vehicle.status_parada == 'vigilancia2'){
    vehicle.latitud = vigilancia2[index].latitud.toString();
    vehicle.longitud = vigilancia2[index].longitud.toString();
    vehicle.orientacion = vigilancia2[index].orientacion;
  }

  if(vehicle.status_parada == 'romana'){
    vehicle.latitud = listaromana[index].latitud.toString();
    vehicle.longitud = listaromana[index].longitud.toString();
    vehicle.orientacion = listaromana[index].orientacion;
  }

  if(vehicle.status_parada =="p1"){
     vehicle.latitud = listp1[index].latitud.toString();
     vehicle.longitud = listp1[index].longitud.toString();
     vehicle.orientacion = listp1[index].orientacion;
  }

    if(vehicle.status_parada =="p2"){
      vehicle.latitud = listp2[index].latitud.toString();
      vehicle.longitud = listp2[index].longitud.toString();
      vehicle.orientacion = listp2[index].orientacion;
   }

   if(vehicle.status_parada =="p3"){
      vehicle.latitud = listp3[index].latitud.toString();
      vehicle.longitud = listp3[index].longitud.toString();
      vehicle.orientacion = listp3[index].orientacion;
   }

  if(vehicle.status_parada =="p4"){
      vehicle.latitud = listp4[index].latitud.toString();
      vehicle.longitud = listp4[index].longitud.toString();
      vehicle.orientacion = listp4[index].orientacion;
   }

  //  if(vehicle.status_parada =="p5"){
  //     vehicle.latitud = listp5[index].latitud.toString();;
  //     vehicle.longitud = listp5[index].longitud.toString();;
  //     vehicle.orientacion = listp5[index].orientacion;
  //  }

}

}  