import 'dart:io';
import 'database.dart';

class Usuario {
  String? _user;
  String? _password;
  bool logueado = false;

  String get user => _user!;
  String get password => _password!;

  set user(String user) {
    _user = user;
  }

  set password(String password) {
    _password = password;
  }

  static registro() async {
    bool creado = false;
    do {
      print('--- REGISTRO ---');
      stdout.writeln('Nombre de usuario:');
      final nombre = stdin.readLineSync()?.trim() ?? '';
      stdout.writeln('Contraseña:');
      final contrasena = stdin.readLineSync()?.trim() ?? '';

      if (nombre.isEmpty || contrasena.isEmpty) {
        print('Introduce los datos');
        continue;
      }

      if (await existeUsuario(nombre)) {
        print('El usuario ya existe');
      } else {
        final usuario = Usuario();
        usuario.user = nombre;
        usuario.password = contrasena;
        creado = await guardarUsuario(usuario);
        if (creado) {
          print('Registrado con exito');
        }
      }
    } while (creado == false);
  }

  Future<bool> loggin() async {
    logueado = false;
    print('--- INICIO DE SESIÓN ---');
    stdout.writeln('Usuario:');
    final nombre = stdin.readLineSync()?.trim() ?? '';
    stdout.writeln('Contraseña:');
    final contrasena = stdin.readLineSync()?.trim() ?? '';

    final conn = await DataBase.obtenerConexion();
    try {
      final resultado = await conn.query(
        'SELECT * FROM usuarios WHERE nombre = ? AND password = ?',
        [nombre, contrasena]
      );

      if (resultado.isNotEmpty) {
        _user = nombre;
        _password = contrasena;
        logueado = true;
        return true;
      }
      return false;
    } finally {
      await conn.close();
    }
  }

  static Future<bool> existeUsuario(String nombre) async {
    final conn = await DataBase.obtenerConexion();
    try {
      final resultado = await conn.query(
        'SELECT * FROM usuarios WHERE nombre = ?',
        [nombre]
      );
      return resultado.isNotEmpty;
    } finally {
      await conn.close();
    }
  }

  static Future<bool> guardarUsuario(Usuario usuario) async {
    final conn = await DataBase.obtenerConexion();
    try {
      await conn.query(
        'INSERT INTO usuarios (nombre, password) VALUES (?, ?)',
        [usuario.user, usuario.password]
      );
      return true;
    } catch (e) {
      print('Error al registrar: $e');
      return false;
    } finally {
      await conn.close();
    }
  }
}