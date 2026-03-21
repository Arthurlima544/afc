import '../domain/entity/category_entity.dart';

const Map<String, List<String>> _categoryKeywords = <String, List<String>>{
  'alimentação': <String>[
    'ifood',
    'rappi',
    'uber eats',
    'mcdonalds',
    'burger king',
    'subway',
    'pizza',
    'restaurante',
    'supermercado',
    'mercado',
    'padaria',
    'açaí',
    'hortifruti',
  ],
  'transporte': <String>[
    'uber',
    '99app',
    'cabify',
    'taxi',
    'metro',
    'onibus',
    'ônibus',
    'combustivel',
    'gasolina',
    'posto',
    'estacionamento',
    'pedagio',
  ],
  'saúde': <String>[
    'farmacia',
    'farmácia',
    'drogaria',
    'hospital',
    'clinica',
    'médico',
    'medico',
    'dentista',
    'unimed',
    'consulta',
  ],
  'lazer': <String>[
    'netflix',
    'spotify',
    'amazon prime',
    'disney',
    'cinema',
    'teatro',
    'ingresso',
    'show',
    'steam',
  ],
  'salário': <String>[
    'salario',
    'salário',
    'pagamento',
    'pgto',
    'deposito',
    'ted recebido',
    'pix recebido',
  ],
};

String? suggestCategoryUuid(
  String description,
  List<CategoryEntity> categories,
) {
  final String lowerDesc = description.toLowerCase();
  for (final CategoryEntity category in categories) {
    final String lowerName = category.name.toLowerCase();
    final List<String>? keywords = _categoryKeywords[lowerName];
    if (keywords == null) {
      continue;
    }
    for (final String keyword in keywords) {
      if (lowerDesc.contains(keyword)) {
        return category.uuid;
      }
    }
  }
  return null;
}
