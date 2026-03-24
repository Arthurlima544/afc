// ---------------------------------------------------------------------------
// Result type
// ---------------------------------------------------------------------------

/// The result of a categorisation match.
class CategorizationMatch {
  const CategorizationMatch({
    required this.categoryName,
    required this.confidence,
  });

  /// The AFC category name (e.g. 'Alimentação', 'Transporte').
  final String categoryName;

  /// Confidence in [0.0, 1.0].  ≥ 0.8 = green, 0.5–0.8 = amber, < 0.5 = red.
  final double confidence;
}

// ---------------------------------------------------------------------------
// Rule table
// ---------------------------------------------------------------------------

class _Rule {
  const _Rule(this.keyword, this.categoryName, this.confidence);

  final String keyword; // uppercase substring to match
  final String categoryName;
  final double confidence;
}

// More-specific rules must appear before generic ones
// (e.g. 'MERCADO LIVRE' before 'MERCADO', 'UBER EATS' before 'UBER').
const List<_Rule> _kRules = <_Rule>[
  // ── Food delivery ────────────────────────────────────────────────────────
  _Rule('UBER EATS', 'Alimentação', 0.95),
  _Rule('IFOOD', 'Alimentação', 0.95),
  _Rule('RAPPI', 'Alimentação', 0.90),
  // ── Supermarkets ─────────────────────────────────────────────────────────
  _Rule('MERCADO LIVRE', 'Outros', 0.80), // e-commerce, not grocery
  _Rule('MERCADOPAGO', 'Outros', 0.80),
  _Rule('PÃO DE AÇÚCAR', 'Alimentação', 0.95),
  _Rule('CARREFOUR', 'Alimentação', 0.95),
  _Rule('ATACADÃO', 'Alimentação', 0.95),
  _Rule('ATACADAO', 'Alimentação', 0.95),
  _Rule('ASSAI', 'Alimentação', 0.90),
  _Rule('HORTIFRUTI', 'Alimentação', 0.90),
  _Rule('SUPERMERCADO', 'Alimentação', 0.90),
  _Rule('MERCADO', 'Alimentação', 0.75),
  // ── Restaurants ──────────────────────────────────────────────────────────
  _Rule('MCDONALDS', 'Restaurantes', 0.99),
  _Rule('MCDONALD', 'Restaurantes', 0.99),
  _Rule('BURGER KING', 'Restaurantes', 0.99),
  _Rule('KFC', 'Restaurantes', 0.95),
  _Rule('SUBWAY', 'Restaurantes', 0.95),
  _Rule('PIZZA HUT', 'Restaurantes', 0.99),
  _Rule('PIZZA', 'Restaurantes', 0.80),
  _Rule('CHURRASCARIA', 'Restaurantes', 0.90),
  _Rule('SUSHI', 'Restaurantes', 0.85),
  _Rule('LANCHONETE', 'Restaurantes', 0.90),
  _Rule('PADARIA', 'Restaurantes', 0.85),
  _Rule('RESTAURANTE', 'Restaurantes', 0.90),
  // ── Transport ────────────────────────────────────────────────────────────
  _Rule('UBER', 'Transporte', 0.95),
  _Rule('99POP', 'Transporte', 0.95),
  _Rule('CABIFY', 'Transporte', 0.95),
  _Rule('INDRIVER', 'Transporte', 0.90),
  _Rule('BILHETE ÚNICO', 'Transporte', 0.99),
  _Rule('METRÔ', 'Transporte', 0.90),
  _Rule('METRO', 'Transporte', 0.85),
  _Rule('ÔNIBUS', 'Transporte', 0.85),
  _Rule('ONIBUS', 'Transporte', 0.85),
  _Rule('COMBUSTÍVEL', 'Transporte', 0.90),
  _Rule('COMBUSTIVEL', 'Transporte', 0.90),
  _Rule('GASOLINA', 'Transporte', 0.90),
  _Rule('IPVA', 'Transporte', 0.99),
  _Rule('DETRAN', 'Transporte', 0.90),
  // ── Health ───────────────────────────────────────────────────────────────
  _Rule('DROGASIL', 'Saúde', 0.99),
  _Rule('ULTRAFARMA', 'Saúde', 0.99),
  _Rule('PACHECO', 'Saúde', 0.90),
  _Rule('FARMÁCIA', 'Saúde', 0.90),
  _Rule('FARMACIA', 'Saúde', 0.90),
  _Rule('DROGARIA', 'Saúde', 0.90),
  _Rule('UNIMED', 'Saúde', 0.99),
  _Rule('AMIL', 'Saúde', 0.90),
  _Rule('PLANO DE SAUDE', 'Saúde', 0.99),
  _Rule('HOSPITAL', 'Saúde', 0.90),
  _Rule('CLÍNICA', 'Saúde', 0.85),
  _Rule('CLINICA', 'Saúde', 0.85),
  _Rule('LABORATÓRIO', 'Saúde', 0.85),
  _Rule('LABORATORIO', 'Saúde', 0.85),
  _Rule('SMARTFIT', 'Saúde', 0.99),
  _Rule('ACADEMIA', 'Saúde', 0.85),
  // ── Subscriptions ────────────────────────────────────────────────────────
  _Rule('NETFLIX', 'Assinaturas', 0.99),
  _Rule('SPOTIFY', 'Assinaturas', 0.99),
  _Rule('YOUTUBE PREMIUM', 'Assinaturas', 0.99),
  _Rule('AMAZON PRIME', 'Assinaturas', 0.99),
  _Rule('DISNEY+', 'Assinaturas', 0.99),
  _Rule('DISNEY', 'Assinaturas', 0.95),
  _Rule('HBO MAX', 'Assinaturas', 0.99),
  _Rule('HBO', 'Assinaturas', 0.90),
  _Rule('GLOBOPLAY', 'Assinaturas', 0.99),
  _Rule('TWITCH', 'Assinaturas', 0.90),
  _Rule('ADOBE', 'Assinaturas', 0.95),
  _Rule('GITHUB', 'Assinaturas', 0.90),
  _Rule('MICROSOFT', 'Assinaturas', 0.80),
  _Rule('APPLE', 'Assinaturas', 0.80),
  _Rule('GOOGLE', 'Assinaturas', 0.75),
  // ── Housing / utilities ──────────────────────────────────────────────────
  _Rule('ALUGUEL', 'Moradia', 0.95),
  _Rule('CONDOMÍNIO', 'Moradia', 0.95),
  _Rule('CONDOMINIO', 'Moradia', 0.95),
  _Rule('IPTU', 'Moradia', 0.99),
  _Rule('ENEL', 'Moradia', 0.95),
  _Rule('CEMIG', 'Moradia', 0.99),
  _Rule('COPEL', 'Moradia', 0.99),
  _Rule('SABESP', 'Moradia', 0.99),
  _Rule('COPASA', 'Moradia', 0.99),
  _Rule('ENERGIA', 'Moradia', 0.80),
  _Rule('INTERNET', 'Assinaturas', 0.80),
  _Rule('CLARO', 'Assinaturas', 0.80),
  _Rule('VIVO', 'Assinaturas', 0.80),
  // ── Telecoms ─────────────────────────────────────────────────────────────
  _Rule('TIM ', 'Assinaturas', 0.80),
  _Rule('OI ', 'Assinaturas', 0.75),
  // ── Education ────────────────────────────────────────────────────────────
  _Rule('ALURA', 'Educação', 0.99),
  _Rule('UDEMY', 'Educação', 0.99),
  _Rule('COURSERA', 'Educação', 0.99),
  _Rule('FACULDADE', 'Educação', 0.90),
  _Rule('UNIVERSIDADE', 'Educação', 0.90),
  _Rule('ESCOLA', 'Educação', 0.85),
  _Rule('MENSALIDADE', 'Educação', 0.75),
  _Rule('CURSO', 'Educação', 0.75),
  // ── Income ───────────────────────────────────────────────────────────────
  _Rule('PAGAMENTO DE SALÁRIO', 'Salário', 0.99),
  _Rule('PAGAMENTO DE SALARIO', 'Salário', 0.99),
  _Rule('SALÁRIO', 'Salário', 0.95),
  _Rule('SALARIO', 'Salário', 0.95),
  _Rule('FOLHA DE PAGAMENTO', 'Salário', 0.99),
  _Rule('FREELA', 'Freelance', 0.85),
  _Rule('FREELANCE', 'Freelance', 0.90),
];

// ---------------------------------------------------------------------------
// Matcher
// ---------------------------------------------------------------------------

/// Matches a transaction title against Brazilian merchant patterns and
/// returns the most confident [CategorizationMatch], or `null` when no rule
/// reaches a confidence of at least 0.5.
class CategorizationMatcher {
  const CategorizationMatcher._();

  static CategorizationMatch? match(String title) {
    final String upper = title.toUpperCase();
    CategorizationMatch? best;

    for (final _Rule rule in _kRules) {
      if (upper.contains(rule.keyword)) {
        if (best == null || rule.confidence > best.confidence) {
          best = CategorizationMatch(
            categoryName: rule.categoryName,
            confidence: rule.confidence,
          );
        }
      }
    }

    if (best != null && best.confidence < 0.5) {
      return null;
    }
    return best;
  }
}
