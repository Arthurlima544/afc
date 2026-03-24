import 'package:afc/domain/usecase/categorisation_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategorizationMatcher.match', () {
    // ── Food delivery ──────────────────────────────────────────────────────

    test('iFood → Alimentação, high confidence', () {
      final CategorizationMatch? m = CategorizationMatcher.match('IFOOD*RESTAURANTE');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Alimentação');
      expect(m.confidence, greaterThanOrEqualTo(0.9));
    });

    test('Uber Eats → Alimentação (more specific than bare UBER)', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('UBER EATS PAGAMENTO');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Alimentação');
      expect(m.confidence, greaterThanOrEqualTo(0.95));
    });

    // ── Supermarkets ──────────────────────────────────────────────────────

    test('Carrefour → Alimentação', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('CARREFOUR BAIRRO SP');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Alimentação');
    });

    test('Mercado Livre → Outros (e-commerce, not grocery)', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('MERCADO LIVRE BR');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Outros');
    });

    test('generic MERCADO → Alimentação, lower confidence', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('SUPERMERCADO EXTRA');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Alimentação');
    });

    // ── Restaurants ───────────────────────────────────────────────────────

    test('McDonalds → Restaurantes', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('MCDONALD\'S 0123');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Restaurantes');
    });

    test('Burger King → Restaurantes', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('BURGER KING DELIVERY');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Restaurantes');
    });

    test('lowercase pizza → Restaurantes (case-insensitive)', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('pizza artesanal joão');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Restaurantes');
    });

    // ── Transport ─────────────────────────────────────────────────────────

    test('Uber ride → Transporte', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('UBER * VIAGEM');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Transporte');
    });

    test('GASOLINA → Transporte', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('POSTO GASOLINA BR');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Transporte');
    });

    test('IPVA → Transporte, max confidence', () {
      final CategorizationMatch? m = CategorizationMatcher.match('IPVA 2025 SP');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Transporte');
      expect(m.confidence, greaterThanOrEqualTo(0.99));
    });

    // ── Health ────────────────────────────────────────────────────────────

    test('Drogasil → Saúde', () {
      final CategorizationMatch? m = CategorizationMatcher.match('DROGASIL 0456');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Saúde');
    });

    test('SMARTFIT → Saúde', () {
      final CategorizationMatch? m = CategorizationMatcher.match('SMARTFIT UNIDADE');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Saúde');
    });

    // ── Subscriptions ─────────────────────────────────────────────────────

    test('Netflix → Assinaturas', () {
      final CategorizationMatch? m = CategorizationMatcher.match('NETFLIX.COM');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Assinaturas');
    });

    test('Spotify → Assinaturas', () {
      final CategorizationMatch? m = CategorizationMatcher.match('SPOTIFY AB');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Assinaturas');
    });

    // ── Housing ───────────────────────────────────────────────────────────

    test('IPTU → Moradia', () {
      final CategorizationMatch? m = CategorizationMatcher.match('IPTU 2025');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Moradia');
    });

    test('CEMIG → Moradia', () {
      final CategorizationMatch? m = CategorizationMatcher.match('CEMIG ENERGIA');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Moradia');
    });

    // ── Education ─────────────────────────────────────────────────────────

    test('Udemy → Educação', () {
      final CategorizationMatch? m = CategorizationMatcher.match('UDEMY INC');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Educação');
    });

    // ── Income ────────────────────────────────────────────────────────────

    test('salary payment → Salário', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('PAGAMENTO DE SALÁRIO');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Salário');
    });

    test('freelance → Freelance', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('TRANSFERÊNCIA FREELANCE');
      expect(m, isNotNull);
      expect(m!.categoryName, 'Freelance');
    });

    // ── No-match / low confidence ─────────────────────────────────────────

    test('unknown title → null', () {
      final CategorizationMatch? m =
          CategorizationMatcher.match('ALGUM ESTABELECIMENTO DESCONHECIDO');
      expect(m, isNull);
    });

    // ── Best-match selection ──────────────────────────────────────────────

    test('picks higher confidence when multiple rules match', () {
      // "MCDONALD" (0.99) and "RESTAURANTE" (0.90) both match — pick 0.99
      final CategorizationMatch? m =
          CategorizationMatcher.match('MCDONALD\'S RESTAURANTE SP');
      expect(m, isNotNull);
      expect(m!.confidence, 0.99);
    });
  });
}
