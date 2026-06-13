import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acesso tipado as variaveis do `.env`. Carregado uma vez no `main` antes de
/// `runApp`. Centraliza as chaves para o resto do app nao mexer no dotenv direto.
class Env {
  const Env._();

  static String get apiBaseUrl => dotenv.get('API_BASE_URL');
}
