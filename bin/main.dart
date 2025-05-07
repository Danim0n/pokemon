import 'juego.dart';
import 'database.dart';
import 'dart:io';

void main() async {
  try {
    await DataBase.instalarBBDD();
    Juego juego = Juego();
    await juego.iniciarAplicacion();
  } catch (e) {
    print('Error inicial: $e');
    return;
  }
}