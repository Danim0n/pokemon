import 'pokemon.dart';
import 'dart:math';

class JuegoPokedle {
  Pokemon? pokemonObjetivo;
  int intentos = 0;
  bool adivinado = false;

  Future<void> iniciar() async {
    print('Adivina el Pokémon (1ra generación)');
    print('''                        --- REGLAS ---
Elije un pokemon de la primera generacion (Los primeros 151).
Segun sus caracteristicas se comparara con un pokemon elejido aleatoriamente.
En el caso de que alguna de sus caracteristicas sea correcta se maracara con un ✅.
Si por el contrario no coincide se monstrara ❌.
Si el pokemon elejido aleatoriamente tiene caracteristicas superiores al ingresado por el usuario se mostrara ❌⬆️ o ❌⬇️ si son inferiores.
''');
    
    var random = Random();
    int idAleatorio = random.nextInt(151) + 1;
    
    pokemonObjetivo = await Pokemon.obtenerPokemonCompleto(idAleatorio);
  }

  Future<void> comprobarIntento(String nombrePokemon) async {
    intentos++;
    
    try {
      var pokemonAdivinado = await Pokemon.obtenerPokemonCompletoPorNombre(nombrePokemon);
      
      if (pokemonAdivinado.nombre?.toLowerCase() == pokemonObjetivo?.nombre?.toLowerCase()) {
        adivinado = true;
        print('¡Correcto! ¡Has adivinado el Pokémon!');
        mostrarPokemon(pokemonObjetivo!);
        print('Intentos: $intentos');
      } else {
        print('Comparación con ${pokemonAdivinado.nombre?.toUpperCase()}:');
        mostrarComparacion(pokemonAdivinado);
      }
    } catch (e) {
      print('Pokémon no encontrado. Intenta de nuevo.');
    }
  }

  void mostrarComparacion(Pokemon adivinado) {

    for (int i = 0; i < 2; i++) {
      String tipo = i < adivinado.tipos.length ? adivinado.tipos[i] : '';
      String tipoObjetivo = i < pokemonObjetivo!.tipos.length ? pokemonObjetivo!.tipos[i] : '';
      
      if (i == 0) print('Tipo: ${tipo == tipoObjetivo ? '✅' : '❌'}');
      if (i == 1 && tipo.isNotEmpty) print('Tipo 2: ${tipo == tipoObjetivo ? '✅' : '❌'}');
    }
    
    print('Color: ${adivinado.color == pokemonObjetivo!.color ? '✅' : '❌'}');
    
    if (adivinado.altura == pokemonObjetivo!.altura) {
      print('Altura: ✅');
    } else {
      print('Altura: ❌${adivinado.altura! > pokemonObjetivo!.altura! ? ' ⬇' : ' ⬆'}');
    }
    
    if (adivinado.peso == pokemonObjetivo!.peso) {
      print('Peso: ✅');
    } else {
      print('Peso: ❌${adivinado.peso! > pokemonObjetivo!.peso! ? ' ⬇' : ' ⬆'}');
    }
    
    print('Habitat: ${adivinado.habitat == pokemonObjetivo!.habitat ? '✅' : '❌'}');
    
    print('Etapa: ${adivinado.etapaEvolutiva == pokemonObjetivo!.etapaEvolutiva ? '✅' : '❌'}');
  }

  static void mostrarPokemon(Pokemon pokemon) {
    double alturaCm = pokemon.altura! * 10;
    double pesoKg = pokemon.peso! / 10;
    
    print('--- ${pokemon.nombre?.toUpperCase()} ---');
    print('Tipos: ${pokemon.tipos.join(', ')}');
    print('Color: ${pokemon.color}');
    print('Altura: ${alturaCm.toStringAsFixed(1)} cm'); 
    print('Peso: ${pesoKg.toStringAsFixed(1)} kg'); 
    print('Habitat: ${pokemon.habitat}');
    print('Etapa evolutiva: ${pokemon.etapaEvolutiva}');
  }
}