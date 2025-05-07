import 'pokemon.dart';
import 'dart:math';
import 'dart:io';
import 'usuario.dart';

class Juego {
  Pokemon? pokemonObjetivo;
  int intentos = 0;
  bool adivinado = false;
  final Usuario usuario = Usuario();

  Future<void> iniciarAplicacion() async {
    await mostrarMenuPrincipal();
  }

  Future<void> mostrarMenuPrincipal() async {
    while (true) {
      print('''
--- MENÚ PRINCIPAL ---
1. Registrar usuario
2. Iniciar sesión
3. Jugar
4. Salir
''');

      final opcion = stdin.readLineSync();

      switch (opcion) {
        case '1':
          await Usuario.registro();
          break;
        case '2':
          final loginExitoso = await usuario.loggin();
          if (loginExitoso) {
            print('Sesión iniciada');
          } else {
            print(' Usuario o contraseña incorrectos');
          }
          break;
        case '3':
          if (usuario.logueado) {
            await iniciarJuego();
          } else {
            print('Acceso denegado: Debes iniciar sesion primero');
          }
          break;
        case '4':
          print('Saliendo...');
          exit(0);
        default:
          print('Opcion no valida');
      }
    }
  }

  iniciarJuego() async {
    print('''
      --- ADIVINA EL POKÉMON ---
              Reglas:
- Adivina Pokémon de la 1ra generación (1-151)
- ✅ = Característica correcta
- ❌ = Característica incorrecta
- ❌⬆ = El Pokémon objetivo es mayor
- ❌⬇ = El Pokémon objetivo es menor
''');

    Random random = Random();
    int aleatorio = random.nextInt(151) + 1;
    pokemonObjetivo = await Pokemon.obtenerPokemonCompleto(aleatorio);
    adivinado = false;
    intentos = 0;

    print('Escribe el nombre de un Pokémon de la primera generación:');
    
    while (adivinado == false) {
      final respuesta = stdin.readLineSync()??'';
      
      if (respuesta.isEmpty) {
        print('Escribe un nombre válido');
        continue;
      }

      try {
        await comprobarIntento(respuesta);
      } catch (e) {
        print('Error: ${(e)}');
      }
    }

    print('Intentos totales: $intentos');
    print('Presiona Enter para volver al menú...');
    stdin.readLineSync();
  }

  comprobarIntento(String nombrePokemon) async {
    intentos++;
    
    try {
      final pokemonAdivinado = await Pokemon.obtenerPokemonCompletoPorNombre(nombrePokemon);
      
      if (pokemonAdivinado.nombre?.toLowerCase() == pokemonObjetivo?.nombre?.toLowerCase()) {
        adivinado = true;
        print('Has adivinado el Pokemon');
        mostrarPokemon(pokemonObjetivo!);
      } else {
        print('Comparación con ${pokemonAdivinado.nombre?.toUpperCase()}:');
        mostrarComparacion(pokemonAdivinado);
        print('Sigue intentando...');
      }
    } catch (e) {
      print('Pokemon no encontrado. Intenta con otro nombre.');
    }
  }

  void mostrarComparacion(Pokemon adivinado) {
    for (int i = 0; i < 2; i++) {
      final tipo = i < adivinado.tipos.length ? adivinado.tipos[i] : '';
      final tipoObjetivo = i < pokemonObjetivo!.tipos.length ? pokemonObjetivo!.tipos[i] : '';
      
      if (i == 0) print('Tipo: ${tipo == tipoObjetivo ? '✅' : '❌'}');
      if (i == 1 && tipo.isNotEmpty) print('Tipo 2: ${tipo == tipoObjetivo ? '✅' : '❌'}');
    }
    
    print('Color: ${adivinado.color == pokemonObjetivo!.color ? '✅' : '❌'}');
    
    if (adivinado.altura == pokemonObjetivo!.altura) {
      print('Altura: ✅');
    } else {
      print('Altura: ❌${adivinado.altura! > pokemonObjetivo!.altura! ? '⬇' : '⬆'}');
    }
    
    if (adivinado.peso == pokemonObjetivo!.peso) {
      print('Peso: ✅');
    } else {
      print('Peso: ❌${adivinado.peso! > pokemonObjetivo!.peso! ? '⬇' : '⬆'}');
    }
    
    print('Habitat: ${adivinado.habitat == pokemonObjetivo!.habitat ? '✅' : '❌'}');
    print('Etapa evolutiva: ${adivinado.etapaEvolutiva == pokemonObjetivo!.etapaEvolutiva ? '✅' : '❌'}');
  }

  void mostrarPokemon(Pokemon pokemon) {
    final alturaCm = pokemon.altura! * 10;
    final pesoKg = pokemon.peso! / 10;
    
    print('${pokemon.nombre?.toUpperCase()}');
    print('Tipos: ${pokemon.tipos.join(', ')}');
    print('Color: ${pokemon.color}');
    print('Altura: ${alturaCm.toStringAsFixed(1)} cm');
    print('Peso: ${pesoKg.toStringAsFixed(1)} kg');
    print('Habitat: ${pokemon.habitat}');
    print('Etapa evolutiva: ${pokemon.etapaEvolutiva}');
  }
}