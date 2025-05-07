import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Pokemon {
  int? id;
  String? nombre;
  List<String> tipos = [];
  String? color;
  int? peso;
  int? altura;
  String? habitat;
  int? etapaEvolutiva;
  
  Pokemon();

  Pokemon.desdeAPI(datos) {
    id = datos['id'];
    nombre = datos['name'];
    peso = datos['weight'];
    altura = datos['height'];
    
    // Obtener tipos
    for (var tipo in datos['types']) {
      tipos.add(tipo['type']['name']);
    }
  }

  static Future<Pokemon> obtenerPokemonCompleto(int id) async {
    try {
      var respuesta = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id/'));
      
      if (respuesta.statusCode == 200) {
        var datos = json.decode(respuesta.body);
        var pokemon = Pokemon.desdeAPI(datos);
        
        var respuestaEspecie = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id/'));
        if (respuestaEspecie.statusCode == 200) {
          var datosEspecie = json.decode(respuestaEspecie.body);
          pokemon.color = datosEspecie['color']['name'];
          pokemon.habitat = datosEspecie['habitat']?['name'] ?? 'desconocido';
        
          var cadenaEvolutiva = datosEspecie['evolution_chain']['url'];
          var respuestaEvolucion = await http.get(Uri.parse(cadenaEvolutiva));
          if (respuestaEvolucion.statusCode == 200) {
            var datosEvolucion = json.decode(respuestaEvolucion.body);
            pokemon.etapaEvolutiva = await obtenerEtapaEvolutiva(datosEvolucion['chain'], pokemon.nombre!);
          }
        }

        return pokemon;
      } else {
        throw('No se pudo cargar el Pokémon');
      }
    } catch (e) {
      print('Error: $e');
      exit(0);
    }
  }

    static Future<int> obtenerEtapaEvolutiva(var cadena, String nombrePokemon) async {
    int etapa = 1;
    
    while (cadena['evolves_to'] != null && cadena['evolves_to'].isNotEmpty) {

      if (cadena['species']['name'] == nombrePokemon.toLowerCase()) {
        return etapa;
      }
      
      for (var evolucion in cadena['evolves_to']) {
        if (evolucion['species']['name'] == nombrePokemon.toLowerCase()) {
          return etapa + 1;
        }
      }
      
      for (var evolucion in cadena['evolves_to']) {
        var resultado = await obtenerEtapaEvolutiva(evolucion, nombrePokemon);
        if (resultado > etapa) {
          return resultado;
        }
      }
      
      cadena = cadena['evolves_to'][0];
      etapa++;
    }
    
    return etapa;
  }

  static Future<Pokemon> obtenerPokemonCompletoPorNombre(String nombre) async {
  try {
    var respuesta = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${nombre.toLowerCase()}/'));
    
    if (respuesta.statusCode == 200) {
      var datos = json.decode(respuesta.body);
      int id = datos['id'];
      
      return await obtenerPokemonCompleto(id);
    } else {
      throw('Pokémon no encontrado');
    }
  } catch (e) {
    throw('Error al buscar el Pokémon: $e');
  }
}
}